
local myname, Cork = ...
if Cork.MYCLASS ~= "PALADIN" then return end


-- Auras
Cork:GenerateAdvancedSelfBuffer("Aura", {465, 7294, 19746, 19891, 32223})


-- Seals
Cork:GenerateAdvancedSelfBuffer("Seal", {20154, 20165, 31801, 20164})


-- Righteous Fury
local spellname, _, icon = GetSpellInfo(25780)
Cork:GenerateSelfBuffer(spellname, icon)
