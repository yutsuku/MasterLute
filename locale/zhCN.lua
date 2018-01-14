local _G = getfenv();
local MasterLute = _G.MasterLute;
local zhCN = MasterLute.Locale:new();
local L = zhCN.Strings;

MasterLute.Locales = MasterLute.Locales or MasterLute.LocaleTable:new(zhCN);
MasterLute.Locales["zhCN"] = zhCN;

L["Naxxramas"] 			= "纳克萨玛斯";
L["Ahn'Qiraj"] 			= "安其拉";
L["Blackwing Lair"] 	= "黑翼之巢";
L["Molten Core"] 		= "熔火之心";
L["Ruins of Ahn'Qiraj"] = "安其拉废墟";
L["Zul'Gurub"] 			= "祖尔格拉布";
L["Onyxia's Lair"] 		= "奥妮克希亚的巢穴";