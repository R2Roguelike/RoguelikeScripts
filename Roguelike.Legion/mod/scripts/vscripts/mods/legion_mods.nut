global function Legion_RegisterMods

void function Legion_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("mag_dump")
        mod.name = "Mag Dump"
        mod.abbreviation = "MD"
        mod.description = "<cyan>+1 Power Shot Charge</> Power Shot <red>depletes 30% of ammo left,</> but <cyan>gains +20% DMG.</> This increases by 0.5% <cyan>for every bullet left.</>"
        mod.shortdesc = "Power Shot consumes more ammo for <cyan>+DMG%."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("gun_shield_shield")
        mod.name = "Shields to Shields"
        mod.abbreviation = "StS"
        mod.description = "<cyan>+25 Mag Size.</>\n\n-40% DMG Taken while Gun Shield is active. If your gun shield is hit, gain a<cyan> +20% DMG</> buff."
        mod.shortdesc = "Gain DMG Resist during Gun Shield.\nWhen Gun Shield takes DMG, gain <cyan>+DMG%."
        mod.cost = 1
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("stat_belt")
        mod.name = "Stats to Bullets"
        mod.abbreviation = "StB"
        mod.description = "<cyan>+1 Power Shot charge.</> Gain mag size from investing in the <cyan>Energy</> stat.\n\n<note>+1 bullet per energy, up to 30. Above 30, +1 bullet per 2 energy.</>"
        mod.shortdesc = "The <cyan>Energy</> stat grants Mag Size."
        mod.cost = 1
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("mag_cap")
        mod.name = "Bullet Condenser"
        mod.abbreviation = "BC"
        mod.description = "<cyan>+25 Mag Size.</> Each bullet above 150 is converted to +DMG%.\n\n<note>+0.5% DMG per bullet up to 75, +0.1% for every bullet above 75.</>"
        mod.shortdesc = "High mag size grants <cyan>+DMG%."
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("focus_crystal")
        mod.name = "Focus Crystal"
        mod.abbreviation = "FC"
        mod.description = "<cyan>+25 Mag Size.</>\n\n<daze>Close Range Mode</>: +15% Crit Rate.\n" +
        "<red>Long Range Mode</>: +30% Crit DMG."
        mod.shortdesc = "<daze>Close Range Mode gains Crit Rate.</>\nLong Range Mode gains Crit DMG."
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("swap_load")
        mod.name = "Swapload"
        mod.abbreviation = "Sl"
        mod.description = "<cyan>+1 Power Shot charge.</> <cyan>On Ammo Swap</>: if you have less than 20 bullets left, <cyan>restore ammo to full.</>"
        mod.shortdesc = "Ammo Swap at low ammo reloads your weapon."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("shotgun_mode")
        mod.name = "Alt Mode: Shotgun"
        mod.abbreviation = "A:S"
        mod.description = "<cyan>+25 Mag Size.</>\n\n<daze>Close Range Mode's Primary Fire</> transforms into an automatic shotgun. <red>Consumes 6 ammo per shot.</>"
        mod.shortdesc = "Close Range Mode transforms."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("marksman_mode")
        mod.name = "Alt Mode: Marksman"
        mod.abbreviation = "A:M"
        mod.description = "<cyan>+25 Mag Size.</>\n\n<red>Long Range Mode's Primary Fire</> fires 10 bullets at once, as one big bullet. <red>Consumes 10 ammo per shot.</>"
        mod.shortdesc = "Long Range Mode transforms."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("ready_up")
        mod.name = "Lightweight Alloys"
        mod.abbreviation = "LA"
        mod.description = "<cyan>+25 Mag Size.</>\n\nPredator Cannon: ADS is faster in every way. Reload Speed increases with Mag Size."
        mod.shortdesc = "ADS is much faster in every way.\nReload Speed increases with Mag Size."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("consumption")
        mod.name = "Bullet Overload"
        mod.abbreviation = "BO"
        mod.description = "<cyan>+25 Mag Size.</>\n\nPredator Cannon: +100% bullet consumption, +25% damage."
        mod.shortdesc = "Predator Cannon consumes more ammo\nfor <cyan>+DMG%."
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("charge_power")
        mod.name = "Power Charge"
        mod.abbreviation = "PC"
        mod.description = "<cyan>+1 Power Shot charge.</>\n\nReduces your power shot <cyan>cooldown</> for every power shot charge you have.\n\n" +
                          "If <daze>Close Range Power Shot</> <red>misses,</> it knocks you back and 50% of the cooldown is restored.\n" +
                          "If <red>Long Range Power Shot</> <cyan>hits,</> Offensive cooldowns are reduced by 10% for each enemy hit."
        mod.shortdesc = "Power Shot cooldown <cyan>decreased for\nevery charge you have."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("shield_threat")
        mod.name = "Threatening Shield"
        mod.abbreviation = "TS"
        mod.description = "<cyan>+1 Power Shot charge.</>\n\nIf your gun shield is destroyed, <cyan>restore 100% of Predator Cannon ammo </>and<cyan> 2 Power Shot charges.</>"
        mod.shortdesc = "If Gun Shield is destroyed, <cyan>restore\n2 Power Shots and reload your weapon."
        mod.cost = 2
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("long_range_ammo")
        mod.name = "Efficency"
        mod.abbreviation = "Eff"
        mod.description = "<cyan>+25 Mag Size.</>\n\n<red>Long Range</> Mode consumes 50% less ammo. <daze>Close Range</> mode has a 25% chance to fire an <cyan>additional time.</>"
        mod.shortdesc = "<daze>Close Range Mode sometimes fires twice.</>\nLong Range Mode consumes less ammo."
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("support_puncture")
        mod.name = "Fear of the Unknown"
        mod.abbreviation = "FoU"
        mod.description = "<cyan>+1 Power Shot charge.</>\n\nGain an additional<cyan> +25% Crit DMG</> against <red>Punctured</> targets, when using your <cyan>other loadout.</>"
        mod.shortdesc = "<cyan>Gain Crit DMG</> when using your other loadout\nagainst punctured targets."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = false
    mod.loadouts = [PRIMARY_LEGION]
    mod.isTitan = true

    return mod
}