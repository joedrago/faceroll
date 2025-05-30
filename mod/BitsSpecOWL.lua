-----------------------------------------------------------------------------------------
-- Boomkin

local _, Faceroll = ...

-- /dump C_Spell.GetSpellInfo("Incarnation: Chosen of Elune").spellID
-- -> 102560: Whirling Stars
-- -> 390414: Orbital Strike


local eclipseWrathDeadzone = Faceroll.deadzoneCreate("Wrath", 0.3, 1)

Faceroll.trackBuffs({
    ["lunareclipse"] = { ["name"]="Eclipse (Lunar)" },
    ["dreamstate"] = { ["name"]="Dreamstate" },
})

local function calcBits()
    local bits = 0

    local hasOrbitalStrike = false
    if C_Spell.GetSpellInfo("Incarnation: Chosen of Elune").spellID == 390414 then
        hasOrbitalStrike = true
    end

    local wrathCastCount = C_Spell.GetSpellCastCount("Wrath")
    if wrathCastCount == 1 then
        Faceroll.deadzoneUpdate(eclipseWrathDeadzone)
    end

    if Faceroll.getBuffRemaining("lunareclipse") > 1.0 then
        bits = bits + 0x1
    end

    if Faceroll.isDotActive("Moonfire") <= 0.3 then
        bits = bits + 0x2
    end
    if Faceroll.isDotActive("Sunfire") <= 0.3 then
        bits = bits + 0x4
    end

    if Faceroll.isSpellAvailable("Fury of Elune") then
        bits = bits + 0x8
    end

    if Faceroll.isSpellAvailable("Warrior of Elune") then
        bits = bits + 0x10
    end

    if Faceroll.getBuffStacks("dreamstate") > 0 then
        bits = bits + 0x20
    end

    local ap = UnitPower("player", Enum.PowerType.LunarPower)
    if ap >= 36 then
        bits = bits + 0x40
    end
    if ap >= 45 then
        bits = bits + 0x80
    end
    if ap >= 75 then
        bits = bits + 0x100
    end

    if Faceroll.deadzoneActive(eclipseWrathDeadzone) then
        bits = bits + 0x200
    end

    if Faceroll.isSpellAvailable("Incarnation: Chosen of Elune") and not hasOrbitalStrike then
        bits = bits + 0x400
    end

    local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
    local base = isGliding and forwardSpeed or GetUnitSpeed("player")
    local movespeed = Round(base / 7 * 100)
    if movespeed > 0 then
        bits = bits + 0x800
    end

    if Faceroll.debug then
        local o = ""
        local dztext = "F"
        if Faceroll.deadzoneActive(eclipseWrathDeadzone) then
            dztext = "T"
        end
        o = o .. "Wrath Deadzone   :\n"
        o = o .. "active           : " .. dztext .. "\n"
        o = o .. "spellName        : " .. eclipseWrathDeadzone.spellName .. "\n"
        o = o .. "castTimeRemaining: " .. eclipseWrathDeadzone.castTimeRemaining .. "\n"
        o = o .. "duration         : " .. eclipseWrathDeadzone.duration .. "\n"
        o = o .. "endTime          : " .. eclipseWrathDeadzone.endTime .. "\n"
        Faceroll.setDebugText(o)
    end

    return bits
end

Faceroll.registerSpec("DRUID-1", calcBits)
