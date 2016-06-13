if _G["ADDONS"] == nil then _G["ADDONS"] = {}; end

_G["ADDONS"]["BETTERCHATFILTER"] = {};
BETTERCHATFILTER = _G["ADDONS"]["BETTERCHATFILTER"];

function BETTERCHATFILTER_ON_INIT(addon, frame)
	BETTERCHATFILTER.addon = addon;
	BETTERCHATFILTER.frame = frame;
	
	BETTERCHATFILTER.init();
end

BETTERCHATFILTER.filteredWords = {
	{bad = "([aA])([nN])([aA])([lL])"									, good = "%1%2*%4"},
	{bad = "([aA])([sS])([sS])"											, good = "*%2%3"},
	{bad = "([bB])([dD])([sS])([mM])"									, good = "%1%2.%3%4"},
	{bad = "([bB])([uU])([tT])([tT])"									, good = "%1*%3%4"},
	{bad = "([cC])([oO])([cC])([kK])"									, good = "%1*%3%4"},
	{bad = "([cC])([uU])([mM])"											, good = "%1*%3"},
	{bad = "([dD])([aA])([mM])([nN])"									, good = "%1*%3%4"},
	{bad = "([eE])([sS])([cC])([oO])([rR])([tT])"						, good = "%1%2%3*%5%6"},
	{bad = "([fF])([uU])([cC])([kK])"									, good = "%1*%3%4"},
	{bad = "([gG])([aA])([yY])"											, good = "*%2%3"},
	{bad = "([lL])([eE])([sS])([bB])([iI])([aA])([nN])"					, good = "%1%2%3%4%5*%7"},
	{bad = "([lL])([oO])([lL])([iI])([tT])([aA])"						, good = "%1*%3%4%5%6"},
	{bad = "([nN])([iI])([pP])([pP])([lL])([eE])"						, good = "%1*%3%4%5%6"},
	{bad = "([pP])([aA])([nN])([tT])([iI])([eE])([sS])"					, good = "%1*%3%4%5%6%7"},
	{bad = "([pP])([aA])([nN])([tT])([yY])"								, good = "%1*%3%4%5"},
	{bad = "([sS])([eE])([mM])([eE])([nN])"								, good = "%1*%3%4%5"},
	{bad = "([sS])([eE])([xX])"											, good = "%1*%3"},
	{bad = "([sS])([hH])([iI])([bB])([aA])([rR])([iI])"					, good = "%1%2*%4%5%6%7"},
	{bad = "([sS])([hH])([iI])([tT])"									, good = "%1%2*%4"},
	{bad = "([sS])([pP])([iI])([cC])"									, good = "%1%2*%4"},
	{bad = "([tT])([iI])([tT])"											, good = "%1*%3"},
};

-- ===========================================================

function BETTERCHATFILTER.init()
	if (BETTERCHATFILTER.isLoaded ~= true) then
		CHAT_SYSTEM("Better Chat Filter loaded!");
		
		BETTERCHATFILTER.isLoaded = true;
	end
	
	local g = _G["ADDONS"]["BETTERCHATFILTER"];
		
	g.addon:RegisterMsg("GAME_START_3SEC", "BETTERCHATFILTER_3SEC");
end

function BETTERCHATFILTER_3SEC()
	
	
	local chatframe = ui.GetFrame("chat");
	local mainchat = GET_CHILD(chatframe, "mainchat", "ui::CEditControl");
	
	mainchat:SetTypingScp("BETTERCHATFILTER_TYPING_IN_CHAT");
end

function BETTERCHATFILTER_TYPING_IN_CHAT(parent, ctrl)	
	parent:CancelReserveScript("BETTERCHATFILTER_SEARCH_FOR_FILTERED_WORDS");
	parent:ReserveScript("BETTERCHATFILTER_SEARCH_FOR_FILTERED_WORDS", 0.3, 1);
end

function BETTERCHATFILTER_SEARCH_FOR_FILTERED_WORDS()
	local chatframe = ui.GetFrame("chat");
	local mainchat = GET_CHILD(chatframe, "mainchat", "ui::CEditControl");
	
	local chattext = mainchat:GetText();
	
	for i = 1, #BETTERCHATFILTER.filteredWords do
		local fwordobj = BETTERCHATFILTER.filteredWords[i];
		
		local status, err = pcall(function() chattext = string.gsub(chattext, fwordobj.bad, fwordobj.good) end);
		if (status == true) then
			--CHAT_SYSTEM("Everything good");
			mainchat:SetText(chattext);
		else
			CHAT_SYSTEM("Error: " .. err);
			CHAT_SYSTEM("Bad word: " .. fwordobj.bad);
		end
	end
	
	--CHAT_SYSTEM(chattext);
end

-- FOR TEST ONLY
--if (DEVLOADER.isLoaded == true) then
--	BETTERCHATFILTER_3SEC();
--end