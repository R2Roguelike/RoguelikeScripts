global function Legion_RegisterMods

global const string LEGION_POWER_SHOT_CHARGE = "legion_power_shot"

void function Legion_RegisterMods()
{
    Roguelike_RegisterTag( LEGION_POWER_SHOT_CHARGE, "+2 Power Shot charges." )
    {
        RoguelikeMod mod = NewMod("mag_dump")
        mod.name = "Mag Dump"
        mod.abbreviation = "MD"
        mod.description = "<cyan>+1 Power Shot Charge</>\n\nPower Shot <red>consumes 50 ammo,</> but <cyan>gains +20% DMG.</> This increases by 0.4% <cyan>for every bullet left.</>"
        mod.shortdesc = "Power Shot consumes more ammo for <cyan>+DMG%."
        mod.tags = [LEGION_POWER_SHOT_CHARGE]
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("gun_shield_shield")
        mod.name = "Shields to Shields"
        mod.abbreviation = "StS"
        mod.description = "<cyan>+25% Mag Size.</>\n\n-40% DMG Taken while Gun Shield is active. If your gun shield is hit, gain a<cyan> +20% DMG</> buff."
        mod.shortdesc = "Gain DMG Resist during Gun Shield.\nWhen Gun Shield takes DMG, gain <cyan>+DMG%."
        mod.statModifiers = [NewStatModifier("mag_size_titan", 0.25)]
        mod.cost = 1
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("stat_belt")
        mod.name = "Stats to Bullets"
        mod.abbreviation = "StB"
        mod.description = "You also gain mag size from investing in the <cyan>Duration</> stat.\n\n<note>+1% Duration = +1 Mag Size.</>"
        mod.shortdesc = "The <cyan>Duration</> stat grants Mag Size."
        mod.tags = [LEGION_POWER_SHOT_CHARGE]
        mod.cost = 1
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("mag_cap")
        mod.name = "Bullet Condenser"
        mod.abbreviation = "BC"
        mod.description = "<cyan>+25% Mag Size.</>\n\nEach bullet above 150 is converted to +DMG%.\n\n<note>+0.5% DMG per bullet up to 75, +0.1% for every bullet above 75.</>"
        mod.shortdesc = "High mag size grants <cyan>+DMG%."
        mod.statModifiers = [NewStatModifier("mag_size_titan", 0.25)]
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("focus_crystal")
        mod.name = "Focus Crystal"
        mod.abbreviation = "FC"
        mod.description = "<cyan>+25% Mag Size.</>\n\n<daze>Close Range Mode</>: +15% DMG.\n" +
        "<red>Long Range Mode</>: +30% Crit DMG."
        mod.shortdesc = "<daze>Close Range Mode gains +DMG%.</>\nLong Range Mode gains Crit DMG."
        mod.statModifiers = [NewStatModifier("mag_size_titan", 0.25)]
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
        mod.description = "<cyan>+25% Mag Size.</>\n\n<daze>Close Range Mode's Primary Fire</> transforms into an automatic shotgun. <red>Consumes 6 ammo per shot.</>"
        mod.shortdesc = "Close Range Mode transforms."
        mod.statModifiers = [NewStatModifier("mag_size_titan", 0.25)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("marksman_mode")
        mod.name = "Alt Mode: Marksman"
        mod.abbreviation = "A:M"
        mod.description = "<cyan>+25% Mag Size.</>\n\n<red>Long Range Mode's Primary Fire</> fires 10 bullets at once, as one big bullet. <red>Consumes 10 ammo per shot.</>"
        mod.shortdesc = "Long Range Mode transforms."
        mod.statModifiers = [NewStatModifier("mag_size_titan", 0.25)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("ready_up")
        mod.name = "Lightweight Alloys"
        mod.abbreviation = "LA"
        mod.description = "<cyan>+25% Mag Size.</>\n\nPredator Cannon: ADS is faster in every way."
        mod.shortdesc = "ADS is much faster in every way."
        mod.statModifiers = [NewStatModifier("mag_size_titan", 0.25)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("consumption")
        mod.name = "Bullet Overload"
        mod.abbreviation = "BO"
        mod.description = "<cyan>+25% Mag Size.</>\n\nPredator Cannon: +100% bullet consumption, +25% damage."
        mod.shortdesc = "Predator Cannon consumes more ammo\nfor <cyan>+DMG%."
        mod.statModifiers = [NewStatModifier("mag_size_titan", 0.25)]
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("charge_power")
        mod.name = "Power Charge"
        mod.abbreviation = "PC"
        mod.description = "Reduces your power shot <cyan>cooldown</> for every power shot charge you have.\n\n" +
                          "If <daze>Close Range Power Shot</> <red>misses,</> it knocks you back and 50% of the cooldown is restored.\n" +
                          "If <red>Long Range Power Shot</> <cyan>hits,</> Offensive cooldowns are reduced by 10% for each enemy hit."
        mod.shortdesc = "Power Shot cooldown <cyan>decreased for\nevery charge you have."
        mod.tags = [LEGION_POWER_SHOT_CHARGE]
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("shield_threat")
        mod.name = "Threatening Shield"
        mod.abbreviation = "TS"
        mod.description = "If your gun shield is destroyed, <cyan>restore 100% of Predator Cannon ammo </>and<cyan> 2 Power Shot charges.</>"
        mod.shortdesc = "If Gun Shield is destroyed, <cyan>restore\n2 Power Shots and reload your weapon."
        mod.tags = [LEGION_POWER_SHOT_CHARGE]
        mod.cost = 2
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("long_range_ammo")
        mod.name = "Efficency"
        mod.abbreviation = "Eff"
        mod.description = "<cyan>+25% Mag Size.</>\n\n<red>Long Range</> Mode Base DMG increases with <cyan>Ability Power</>. <daze>Close Range</> mode has a 25% chance to fire an <cyan>additional time.</>"
        mod.shortdesc = "<daze>Close Range Mode sometimes fires twice.</>\nLong Range Mode DMG scales with <cyan>Ability Power</>."
        mod.statModifiers = [NewStatModifier("mag_size_titan", 0.25)]
        mod.abilityPowerValue = 0.0
        mod.abilityPowerScalar = 1.0
        mod.abilityPowerFormat = "+%.0f%%"
        mod.abilityPowerLabel = "Long Range Bonus DMG"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("lucky_shot")
        mod.name = "Lucky Shot"
        mod.abbreviation = "LS"
        mod.description = "Predator cannon hits <cyan>gain +50% DMG when they Crit."
        mod.shortdesc = "Predator cannon hits <cyan>gain +DMG%\nwhen they Crit."
        mod.tags = [LEGION_POWER_SHOT_CHARGE]
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("support_puncture")
        mod.name = "Fear of the Unknown"
        mod.abbreviation = "FoU"
        mod.description = "Gain an additional<cyan> +45% Crit DMG</> against <red>Punctured</> targets, when using your <cyan>other loadout.</>"
        mod.shortdesc = "<cyan>Gain Crit DMG</> when using your other loadout\nagainst punctured targets."
        mod.tags = [LEGION_POWER_SHOT_CHARGE]
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("lrm_bounce")
        mod.name = "BounceShot"
        mod.abbreviation = "BS"
        mod.description = "Long Range Power Shot bounces between enemies."
        mod.shortdesc = "Long Range Power Shot bounces between enemies."
        mod.tags = [LEGION_POWER_SHOT_CHARGE]
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = true
    mod.chip        = 3
    mod.loadouts = [PRIMARY_LEGION]
    mod.isTitan = true

    return mod
}