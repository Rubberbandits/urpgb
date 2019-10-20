kingston = kingston or {};
kingston.gui = kingston.gui or {};
kingston.gui.classes = kingston.gui.classes or {};

function kingston.gui.RegisterSkin( szClassName, nSkinStruct )
 
	kingston.gui.classes[szClassName] = nSkinStruct;

end

function kingston.gui.FindFunc( nPanel, szFunctionType, szClass )

	if( !kingston.gui.classes[nPanel:GetSkin().Name] ) then return end
	kingston.gui.classes[nPanel:GetSkin().Name][szFunctionType..szClass]( nPanel, nPanel, nPanel:GetWide(), nPanel:GetTall() );

end

local s_Meta = FindMetaTable( "Panel" ); -- since we need to add new method to panel class

function s_Meta:SetUVSkin( szClass )

	if( kingston.gui.classes[szClass] ) then

		self.UVSkin = szClass;
		
	end

end

function s_Meta:GetUVSkinStruct()

	if( self.UVSkin and kingston.gui.classes[self.UVSkin] ) then
	
		return kingston.gui.classes[self.UVSkin];
		
	end

end