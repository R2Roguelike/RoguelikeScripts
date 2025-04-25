global function Legion_RegisterMods

void function Legion_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("mag_dump")
        mod.name = "Mag Dump"
        mod.abbreviation = "MD"
        mod.description = "<cyan>+1 Power Shot Charge</> Power Shot <red>depletes 30% of ammo left</>, but <cyan>gains +20% damage bonus. This increases by 0.5% for each bullet in the mag.</>"
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("stat_belt")
        mod.name = "Stats to Bullets"
        mod.abbreviation = "StB"
        mod.description = "<cyan>+1 Power Shot charge.</> Gain mag size from investing in the <cyan>Energy</> stat.\n\n<note>+1 bullet per energy, up to 20. +1 bullet per 2 energy, up to 100.</>"
        mod.cost = 1
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("mag_cap")
        mod.name = "Bullet Condenser"
        mod.abbreviation = "BC"
        mod.description = "<cyan>+20 Mag Size.</> Mag size is capped at 150. Each bullet above the cap is converted to +DMG%.\n\n<note>+0.5% DMG per bullet up to 75, +0.1% for every bullet above 75.</>"
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("focus_crystal")
        mod.name = "Focus Crystal"
        mod.abbreviation = "FC"
        mod.description = "<cyan>+20 mag size.</>\n\n<daze>Close Range Mode</>: deal 20% bonus damage to enemies within 15m.\n" +
        "<red>Long Range Mode</>: deal 30% more crit damage."
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("swap_load")
        mod.name = "swapload"
        mod.abbreviation = "Sl"
        mod.description = "<cyan>+1 power shot charge.</> <cyan>On Ammo Swap</>: if you have less than 20 bullets left, <cyan>restore ammo to full</>."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("shotgun_mode")
        mod.name = "Alt Mode: Shotgun"
        mod.abbreviation = "A:S"
        mod.description = "<cyan>+20 Mag Size.</>\n\n<daze>Close Range Mode's Primary Fire</> transforms into an automatic shotgun. <red>Consumes 6 ammo per shot.</>"
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("marksman_mode")
        mod.name = "Alt Mode: Marksman"
        mod.abbreviation = "A:M"
        mod.description = "<cyan>+20 Mag Size.</>\n\n<red>Long Range Mode's Primary Fire</> fires 10 bullets at once, as one big bullet. <red>Consumes 10 ammo per shot.</>"
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("ready_up")
        mod.name = "Lightweight Alloys"
        mod.abbreviation = "LA"
        mod.description = "<cyan>+20 mag size.</>\n\nPredator Cannon: Move faster while in ADS. Enter ADS much quicker."
        mod.cost = 1
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("consumption")
        mod.name = "Bullet Overload"
        mod.abbreviation = "BO"
        mod.description = "<cyan>+20 mag size.</>\n\nPredator Cannon: +100% bullet consumption, +25% damage."
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("power_back")
        mod.name = "Physics Power"
        mod.abbreviation = "PP"
        mod.description = "<cyan>+1 power shot charge.</>\n\nIf Close Range Power Shot hits no enemies, it knocks you back and 50% of the cooldown is restored."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("charge_power")
        mod.name = "Power Charge"
        mod.abbreviation = "PC"
        mod.description = "<cyan>+1 power shot charge.</>\n\nReduces your power shot <cyan>cooldown</> for every power shot charge you have."
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