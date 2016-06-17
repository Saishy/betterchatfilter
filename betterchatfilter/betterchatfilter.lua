if _G["ADDONS"] == nil then _G["ADDONS"] = {}; end

_G["ADDONS"]["BETTERCHATFILTER"] = {};
BETTERCHATFILTER = _G["ADDONS"]["BETTERCHATFILTER"];

function BETTERCHATFILTER_ON_INIT(addon, frame)
	BETTERCHATFILTER.addon = addon;
	BETTERCHATFILTER.frame = frame;
		
	if (BETTERCHATFILTER.isLoaded ~= true) then
		CHAT_SYSTEM("Better Chat Filter loaded!");
		
		BETTERCHATFILTER.isLoaded = true;
	end
	
	addon:RegisterMsg("GAME_START_3SEC", "BETTERCHATFILTER_3SEC");
end


function BETTERCHATFILTER_3SEC()
	local chatframe = ui.GetFrame("chat");
	local mainchat = GET_CHILD(chatframe, "mainchat", "ui::CEditControl");
	
	mainchat:SetTypingScp("BETTERCHATFILTER_TYPING_IN_CHAT");
end

function BETTERCHATFILTER_TYPING_IN_CHAT(parent, ctrl)	
	BETTERCHATFILTER_SEARCH_FOR_FILTERED_WORDS();
	--parent:CancelReserveScript("BETTERCHATFILTER_SEARCH_FOR_FILTERED_WORDS");
	--parent:ReserveScript("BETTERCHATFILTER_SEARCH_FOR_FILTERED_WORDS", 0.1, 1);
end

function BETTERCHATFILTER_SEARCH_FOR_FILTERED_WORDS()
	local chatframe = ui.GetFrame("chat");
	local mainchat = GET_CHILD(chatframe, "mainchat", "ui::CEditControl");
	
	local chattext = mainchat:GetText();
	local badword = IsBadString(chattext);
	
	if badword ~= nil then
		badword = badword:sub(1,9); -- limit to 9 characters because of pattern referencing limits ( %1-9 )

		local escaped = BETTERCHATFILTER.patternEscape(badword);
		local capture = BETTERCHATFILTER.caseInsensitiveCapture(escaped);
		local goodword = BETTERCHATFILTER.getGood(badword);

		chattext = chattext:gsub(capture, goodword)
		mainchat:SetText(chattext);
	end
end

BETTERCHATFILTER.censorChar = '*';

function BETTERCHATFILTER.getGood(str)
	local _str = BETTERCHATFILTER.patternEscape(str);
	if _str:match("%%") or _str:match("\\") or _str:match("%(") then
		return BETTERCHATFILTER.censorChar:rep(#str);
	end

	local trailingSpace = '';

	if str:match("[^\128-\191][\128-\191]*$") == ' ' then 
		trailingSpace = ' ';
		str = str:sub(1, #str-1);
	end

	local multi = #str-6;
	if multi < 1 then multi = 1 end;

	local pos = math.floor(#str/2) - math.floor(multi/2);

	_str = '';
	for i=1, #str do
		if i <= pos or i > pos+multi then
			_str = _str .. '%' .. i;
		else
			_str = _str .. BETTERCHATFILTER.censorChar;
		end
	end

	_str = _str .. trailingSpace;

	return _str;
end

function BETTERCHATFILTER.caseInsensitiveCapture(pattern)

	-- find an optional '%' (group 1) followed by any character (group 2)
	local p = pattern:gsub("(%%?)(.)", function(percent, letter)
		if percent ~= "" or not letter:match("%a") then
			-- if the '%' matched, or `letter` is not a letter, return "as is"
			return '[' .. percent .. letter .. ']';
		else
			-- else, return a case-insensitive character class of the matched letter
			return string.format("[%s%s]", letter:lower(), letter:upper())
		end
	end)
	return p:gsub("(%[.-])", "(%1)")
end

BETTERCHATFILTER.escapeMatches =
{
	["^"] = "%^";
	["$"] = "%$";
	["("] = "%(";
	[")"] = "%)";
	["%"] = "%%";
	["."] = "%.";
	["["] = "%[";
	["]"] = "%]";
	["*"] = "%*";
	["+"] = "%+";
	["-"] = "%-";
	["?"] = "%?";
}

function BETTERCHATFILTER.patternEscape(s)
	return (s:gsub(".", BETTERCHATFILTER.escapeMatches))
end

-- FOR TEST ONLY
--if (DEVLOADER.isLoaded == true) then
--	BETTERCHATFILTER_3SEC();
--end 
