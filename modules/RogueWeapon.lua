
local myname, Cork = ...
if Cork.MYCLASS ~= "ROGUE" then return end

local myname, Cork = ...
local UnitAura = Cork.UnitAura or UnitAura
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local f, elapsed = CreateFrame("Frame"), 0

local MAINHAND, OFFHAND, RANGED = GetInventorySlotInfo("MainHandSlot"), GetInventorySlotInfo("SecondaryHandSlot"), GetInventorySlotInfo("RangedSlot")
local IconLine = Cork.IconLine

local spellidlist = { 3408, 2823, 8679, 5761, 13219, }
local poisonranklist = {
	["Crippling Poison"] = { 3775 },
	["Deadly Poison"] = { 2892, 2893, 8984, 8985, 20844, 22053, 22054, 43232, 43233 },
	["Instant Poison"] = { 6947, 6949, 6950, 8926, 8927, 8928, 21927, 43230, 43231 },
	["Mind-numbing Poison"] = { 5237 },
	["Wound Poison"] = { 10918, 10920, 10921, 10922, 22055, 43234, 43235 },
}

local buffnames, icons = {}, {}
for _,id in pairs(spellidlist) do
	local spellname, _, icon = GetSpellInfo(id)
	buffnames[id], icons[spellname] = spellname, icon
end
Cork.defaultspc["Temp Enchant-enabled"] = UnitLevel("player") >= 10
Cork.defaultspc["Temp Enchant-mainspell"], Cork.defaultspc["Temp Enchant-offspell"], Cork.defaultspc["Temp Enchant-rangedspell"] = buffnames[spellidlist[1]], buffnames[spellidlist[1]], buffnames[spellidlist[1]]

local dataobj = ldb:NewDataObject("Cork Temp Enchant", {type = "cork"})

function dataobj:Scan() if Cork.dbpc["Temp Enchant-enabled"] then f:Show() else f:Hide(); dataobj.mainhand, dataobj.offhand, dataobj.ranged = nil end end

function dataobj:CorkIt(frame)
	if self.mainhand then
		for _,id in ipairs(poisonranklist[Cork.dbpc["Temp Enchant-mainspell"]]) do
			if (GetItemCount(id) or 0) > 0 then return frame:SetManyAttributes("type1", "macro", "macrotext1", "/use item:"..id.."\n/use 16") end
		end
	end
	if self.offhand then
		for _,id in ipairs(poisonranklist[Cork.dbpc["Temp Enchant-offspell"]]) do
			if (GetItemCount(id) or 0) > 0 then return frame:SetManyAttributes("type1", "macro", "macrotext1", "/use item:"..id.."\n/use 17") end
		end
	end
	if self.ranged then
		for _,id in ipairs(poisonranklist[Cork.dbpc["Temp Enchant-rangedspell"]]) do
			if (GetItemCount(id) or 0) > 0 then return frame:SetManyAttributes("type1", "macro", "macrotext1", "/use item:"..id.."\n/use 18") end
		end
	end
end

local offhands = {INVTYPE_WEAPON = true, INVTYPE_WEAPONOFFHAND = true, INVTYPE_THROWN = true}
f:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < 0.5 then return end
	elapsed = 0

	local zzz = (IsResting() and not Cork.db.debug)
	local main, _, _, offhand, _, _, ranged = GetWeaponEnchantInfo()

	local icon = icons[Cork.dbpc["Temp Enchant-mainspell"]]
	dataobj.mainhand = not main and not zzz and GetInventoryItemLink("player", MAINHAND) and IconLine(icon, INVTYPE_WEAPONMAINHAND)

	local offlink = GetInventoryItemLink("player", OFFHAND)
	local offweapon = offlink and offhands[select(9, GetItemInfo(offlink))]
	local icon = icons[Cork.dbpc["Temp Enchant-offspell"]]
	dataobj.offhand = not offhand and not zzz and offweapon and IconLine(icon, INVTYPE_WEAPONOFFHAND)

	local rangedlink = GetInventoryItemLink("player", RANGED)
	local rangedweapon = rangedlink and offhands[select(9, GetItemInfo(rangedlink))]
	local icon = icons[Cork.dbpc["Temp Enchant-rangedspell"]]
	dataobj.ranged = not ranged and not zzz and rangedweapon and IconLine(icon, INVTYPE_THROWN)
end)

----------------------
--      Config      --
----------------------

local frame = CreateFrame("Frame", nil, Cork.config)
frame:SetWidth(1) frame:SetHeight(1)
dataobj.configframe = frame
frame:Hide()

frame:SetScript("OnShow", function()
	local EDGEGAP, ROWHEIGHT, ROWGAP, GAP = 16, 18, 2, 4
	local buffbuttons, buffbuttons2, buffbuttons3 = {}, {}, {}

	local function OnClick(self)
		Cork.dbpc["Temp Enchant-"..(self.isRanged and "rangedspell" or self.isOffhand and "offspell" or "mainspell")] = self.buff
		for buff,butt in pairs(self.isRanged and buffbuttons3 or self.isOffhand and buffbuttons2 or buffbuttons) do butt:SetChecked(butt == self) end
		dataobj:Scan()
	end

	local function OnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.buff)
	end
	local function OnLeave() GameTooltip:Hide() end

	local function MakeButt(buff, isOffhand, isRanged)
		local butt = CreateFrame("CheckButton", nil, frame)
		butt:SetWidth(ROWHEIGHT) butt:SetHeight(ROWHEIGHT)

		local tex = butt:CreateTexture(nil, "BACKGROUND")
		tex:SetAllPoints()
		tex:SetTexture(icons[buff])
		tex:SetTexCoord(4/48, 44/48, 4/48, 44/48)
		butt.icon = tex

		butt:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
		butt:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
		butt:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")

		butt.buff, butt.isOffhand, butt.isRanged = buff, isOffhand, isRanged
		butt:SetScript("OnClick", OnClick)
		butt:SetScript("OnEnter", OnEnter)
		butt:SetScript("OnLeave", OnLeave)

		return butt
	end

	local lasticon
	for _,id in ipairs(spellidlist) do
		local buff = buffnames[id]
		local butt = MakeButt(buff)
		if lasticon then lasticon:SetPoint("RIGHT", butt, "LEFT", -ROWGAP, 0) end
		buffbuttons[buff], lasticon = butt, butt
	end
	for i,id in ipairs(spellidlist) do
		local buff = buffnames[id]
		local butt = MakeButt(buff, true)
		lasticon:SetPoint("RIGHT", butt, "LEFT", i == 1 and -ROWHEIGHT or -ROWGAP, 0)
		buffbuttons2[buff], lasticon = butt, butt
	end
	for i,id in ipairs(spellidlist) do
		local buff = buffnames[id]
		local butt = MakeButt(buff, false, true)
		lasticon:SetPoint("RIGHT", butt, "LEFT", i == 1 and -ROWHEIGHT or -ROWGAP, 0)
		buffbuttons3[buff], lasticon = butt, butt
	end
	lasticon:SetPoint("RIGHT", 0, 0)

	local function Update(self)
		for buff,butt in pairs(buffbuttons) do
			butt:SetChecked(Cork.dbpc["Temp Enchant-mainspell"] == buff)
			butt:Enable()
			butt.icon:SetVertexColor(1.0, 1.0, 1.0)
		end

		for buff,butt in pairs(buffbuttons2) do
			butt:SetChecked(Cork.dbpc["Temp Enchant-offspell"] == buff)
			butt:Enable()
			butt.icon:SetVertexColor(1.0, 1.0, 1.0)
		end

		for buff,butt in pairs(buffbuttons3) do
			butt:SetChecked(Cork.dbpc["Temp Enchant-rangedspell"] == buff)
			butt:Enable()
			butt.icon:SetVertexColor(1.0, 1.0, 1.0)
		end
	end

	frame:SetScript("OnShow", Update)
	Update(frame)
end)
