require("mysqloo")

urpgb = urpgb or {}
urpgb.database = urpgb.database or {}

urpgb.database.queue = urpgb.database.queue or {}
urpgb.database.registered_databases = urpgb.database.registered_databases or {}
urpgb.database.registered_transactions = urpgb.database.registered_transactions or {}
urpgb.database.auth_info = urpgb.database.auth_info or {}

urpgb.database.transaction_time = 10

/* Main functions */

-- Creates database object and adds it to our table
function urpgb.database.initalize(identifier, host, username, password, database, port, on_success, on_failure, instant)
	local database = mysqloo.connect(host, username, password, database, port)
	database.onConnected = function(db)
		urpgb.debug.log(Color(0,255,0), "Database \"%s\" successfully connected!\n", identifier)
		hook.Run("urpgb_database_connected", identifier)
		
		if on_success then
			on_success(db)
		end
	end
	database.onConnectionFailed = function(db, err)
		urpgb.debug.log(Color(255,0,0), "Database \"%s\" failed to connect!\n", identifier)
		
		if on_failure then
			on_failure(db)
		end
	end
	
	if instant then
		database.no_transactions = instant
	end
	
	urpgb.database.registered_databases[identifier] = database
	
	return database
end

-- Connects to a database or all registered databases if argument is absent
function urpgb.database.connect(identifier)
	if !identifier then
		for k,v in next, urpgb.database.registered_databases do
			v:connect()
		end
	else
		urpgb.database.get_database(identifier):connect()
	end
end

-- Disconnect from a database
function urpgb.database.disconnect(identifier)
	local database = urpgb.database.get_database(identifier)
	if !database then
		error("urpgb.database: No database found!")
	end
	
	database:disconnect(true)
end

function urpgb.database.process_query_args(args)
	if !args then
		error("urpgb.database: Arguments are invalid or there are no entries to process!")
	end
	
	local ret = {}
	for k,v in next, args do
		local data_type = type(v)
		
		if data_type == "number" then
			ret[#ret + 1] = { "Number", v }
		elseif data_type == "string" then
			ret[#ret + 1] = { "String", v }
		elseif data_type == "bool" then
			ret[#ret + 1] = { "Boolean", v }
		elseif data_type == "table" then
			ret[#ret + 1] = { "String", util.TableToJSON(v) }
		end
	end
	
	return ret
end

function urpgb.database.process_queue(identifier)
	local database = urpgb.database.get_database(identifier)
	local transaction = urpgb.database.registered_transactions[identifier]
	
	if !transaction then return end
	if !transaction:getQueries() then return end
	
	transaction:start()
	urpgb.database.registered_transactions[identifier] = database:createTransaction()
	urpgb.database.registered_transactions[identifier].onSuccess = function(tr)
		urpgb.debug.log(Color(255,0,255), "Transaction %s successfully processed.\n", identifier)
	end
	urpgb.database.registered_transactions[identifier].onError = function(tr, err)
		urpgb.debug.log(Color(255,0,255), "Transaction %s failed! (%s)\n", identifier, err)
	end

	urpgb.debug.log(Color(255,0,255), "Processing queue for %s.\n", identifier)
end

function urpgb.database.add_to_queue(identifier, query)
	if !urpgb.database.registered_transactions[identifier] then
		urpgb.database.registered_transactions[identifier] = urpgb.database.get_database(identifier):createTransaction()
		urpgb.database.registered_transactions[identifier].onSuccess = function(tr)
			urpgb.debug.log(Color(255,0,255), "Transaction %s successfully processed.\n", identifier)
		end
		urpgb.database.registered_transactions[identifier].onError = function(tr, err)
			urpgb.debug.log(Color(255,0,255), "Transaction %s failed! (%s)\n", identifier, err)
		end
	end
	
	local transaction = urpgb.database.registered_transactions[identifier]
	transaction:addQuery(query)
	
	urpgb.debug.log(Color(255,0,255), "Query added to %s's current transaction.\n", identifier)
end

/* Retrieve data functions */

function urpgb.database.get_database(identifier)
	local database = urpgb.database.registered_databases[identifier]
	if !database then
		error("urpgb.database: Invalid database specified!")
	end

	return database
end

/* Commit data functions */

function urpgb.database.commit_data(identifier, query, ...)
	local database = urpgb.database.get_database(identifier)
	
	local args = urpgb.database.process_query_args({...})
	if !args then
		error("urpgb.database: Error parsing query arguments!")
	end
	
	local count = {}
	local q_obj = database:prepare(query)
	for k,v in next, args do
		count[v[1]] = (count[v[1]] or 0) + 1
	
		q_obj["set"..v[1]](q_obj, count[v[1]], v[2])
	end
	
	q_obj.onSuccess = function(q)
		urpgb.debug.log(Color(0,255,0), "Successfully committed query for %s.\n", identifier)
	end
	q_obj.onError = function(q, err)
		urpgb.debug.log(Color(255,0,0), "Error in query for %s, error: %s\n", identifier, err)
	end
	
	urpgb.database.add_to_queue(identifier, q_obj)
	urpgb.debug.log(Color(255,0,255), "Committing data to %s, Query structure: %s\n", identifier, query)
end

function urpgb.database.query(identifier, query, ...)
	local database = urpgb.database.get_database(identifier)
	local args = urpgb.database.process_query_args({...})
	if !args then
		error("urpgb.database: Error parsing query arguments!")
	end

	local q_obj = database:prepare(query)
	
	local count = {}
	for k,v in next, args do
		count[v[1]] = (count[v[1]] or 0) + 1
	
		q_obj["set"..v[1]](q_obj, count[v[1]], v[2])
	end
	
	local cr = coroutine.running()

	if not cr then
		q_obj:start()
		q_obj:wait()

		local err = q_obj:error()

		if #err > 0 then
			error(string.format("Query failed: %s (%s)", str, err))
		else
			local data = q_obj:getData()
			data.last_insert = q_obj:lastInsert()
			
			urpgb.debug.log(Color(0,255,0), "Query successfully executed for %s.\n", identifier)
			
			return data
		end
	end

	function q_obj:onSuccess()
		local data = self:getData()

		data.last_insert = self:lastInsert()

		local ok, res = coroutine.resume(cr, data)

		if not ok then
			print(res)
			error()
			return
		end
		
		urpgb.debug.log(Color(0,255,0), "Query successfully executed for %s.\n", identifier)
	end

	q_obj:start()

	return coroutine.yield()
end

/* QOL Functions */

function urpgb.database.create_table(identifier, table_name, structure)
	local database = urpgb.database.get_database(identifier)
	
	local q_obj = database:query(string.format("CREATE TABLE %s ( id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (id) );", table_name))
	local t_obj = urpgb.database.registered_transactions[identifier] or database:createTransaction()
	t_obj.onSuccess = function(self, data)
		urpgb.debug.log(Color(0,255,0), "Table %s successfully created in %s.\n", table_name, identifier)
	end
	t_obj.onError = function(self, err)
		urpgb.debug.log(Color(255,0,0), "Error creating table %s in %s. (%s)\n", table_name, identifier, err)
	end
	t_obj:addQuery(q_obj)
	
	if structure then
		for k,v in next, structure do
			local q_obj = database:query(string.format("ALTER TABLE %s ADD %s %s;", table_name, v[1], v[2]))
			t_obj:addQuery(q_obj)
		end
	end
	
	t_obj:start()
end

/* Hooks */
hook.Add("urpgb_loading_complete", "initialize_databases", function()
	if urpgb.database.databases_initalized then return end
	if table.Count(urpgb.database.auth_info) == 0 then
		error("urpgb.database: No database information!")
	end

	for k,v in next, urpgb.database.auth_info do
		urpgb.database.initalize(k, v.host, v.username, v.password, v.database, v.port or 3306, v.on_success, v.on_failure)
	end
	
	hook.Run("urpgb_databases_initialized")
	urpgb.database.databases_initalized = true
end)

hook.Add("urpgb_databases_initialized", "connect_databases", function()
	for k,v in next, urpgb.database.registered_databases do
		v:connect()
	end
end)

hook.Add("Think", "urpgb_database_think", function()
	if !urpgb.database.next_transaction then
		urpgb.database.next_transaction = CurTime()
	end
	
	if urpgb.database.next_transaction <= CurTime() then
		for k,v in next, urpgb.database.registered_databases do
			if v.no_transactions then continue end
			
			urpgb.database.process_queue(k)
		end
	
		urpgb.database.next_transaction = CurTime() + urpgb.database.transaction_time
	end
end)

hook.Add("ShutDown", "urpgb_database_disconnect", function()
	for k,v in next, urpgb.database.registered_databases do
		urpgb.database.disconnect(k)
	end
end)