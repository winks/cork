
local myname, Cork = ...
if Cork.MYCLASS ~= "WARRIOR" then return end


-- Battle Shout
local shout = Cork:GenerateAdvancedSelfBuffer("Shouts", {6673, 469}, true)

-- Vigilance
local spellname, _, icon = GetSpellInfo(59665)
Cork:GenerateLastBuffedBuffer(spellname, icon)
