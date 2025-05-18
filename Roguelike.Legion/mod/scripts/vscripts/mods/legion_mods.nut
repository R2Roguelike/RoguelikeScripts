global function Legion_RegisterMods

void function Legion_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("mag_dump")
        mod.name = "Mag Dump"
        mod.abbreviation = "MD"
        mod.description = "<cyan>+1 Power Shot Charge</> Power Shot <red>depletes 30% of ammo left</>, but <cyan>gains +20% DMG</>. This increases by 0.5% <cyan>for every bullet left</>."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("gun_shield_shield")
        mod.name = "Shields to Shields"
        mod.abbreviation = "StS"
        mod.description = "<cyan>+20 Mag Size.</>\n\n-40% DMG Taken while Gun Shield is active. If your gun shield is hit, gain a<cyan> +20% DMG</> buff."
        mod.cost = 1
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("stat_belt")
        mod.name = "Stats to Bullets"
        mod.abbreviation = "StB"
        mod.description = "<cyan>+1 Power Shot charge.</> Gain mag size from investing in the <cyan>Energy</> stat.\n\n<note>+1 bullet per energy, up to 20. Above 20, +1 bullet per 2 energy, up to 100.</>"
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
        mod.description = "<cyan>+20 mag size.</>\n\n<daze>Close Range Mode</>: +20% DMG against enemies within 15m.\n" +
        "<red>Long Range Mode</>: +30% Crit DMG."
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("swap_load")
        mod.name = "swapload"
        mod.abbreviation = "Sl"
        mod.description = "<cyan>+1 Power Shot charge.</> <cyan>On Ammo Swap</>: if you have less than 20 bullets left, <cyan>restore ammo to full</>."
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
        RoguelikeMod mod = NewMod("charge_power")
        mod.name = "Power Charge"
        mod.abbreviation = "PC"
        mod.description = "<cyan>+1 Power Shot charge.</>\n\nReduces your power shot <cyan>cooldown</> for every power shot charge you have.\n\n" +
                          "If <daze>Close Range Power Shot</> <red>misses</>, it knocks you back and 50% of the cooldown is restored.\n" +
                          "If <red>Long Range Power Shot</> <cyan>hits</>, Offensive cooldowns are reduced by 10% for each enemy hit."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("power_shield")
        mod.name = "Power Shield"
        mod.abbreviation = "PS"
        mod.description = "<cyan>+1 Power Shot charge.</>\n\nIf your gun shield is destroyed, <cyan>restore 100% of Predator Cannon ammo </>and<cyan> all Power Shot charges</>."
        mod.cost = 1
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("long_range_ammo")
        mod.name = "Efficency"
        mod.abbreviation = "Eff"
        mod.description = "<cyan>+20 Mag Size.</>\n\n<red>Long Range</> Mode consumes 50% less ammo. <daze>Close Range</> mode has a 25% chance to fire an <cyan>additional time</>."
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("support_puncture")
        mod.name = "Fear of the Unknown"
        mod.abbreviation = "FoU"
        mod.description = "<cyan>+1 Power Shot charge.</>\n\nGain an additional<cyan> +25% Crit DMG</> against <red>Punctured</> targets, when using your <cyan>other loadout</>."
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