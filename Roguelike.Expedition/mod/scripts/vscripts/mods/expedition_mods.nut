global function Expedition_RegisterMods

global const string EXPEDITION_REARM_TAG = "expedition_rearm"
global const string EXPEDITION_WEAKEN_TAG = "expedition_weaken"

void function Expedition_RegisterMods()
{
    // +5% weaken DMG bonus
    // -5% rearm cooldown
    // ["never_ending_burst", ""]
    Roguelike_RegisterTag( EXPEDITION_REARM_TAG, "+5% Cooldown Reduction." )
    Roguelike_RegisterTag( EXPEDITION_WEAKEN_TAG, "+10% Weaken DMG Bonus." )
    {
        RoguelikeMod mod = NewMod("never_ending_burst")
        mod.name = "Accuracy Burst"
        mod.abbreviation = "AB"
        mod.description = "Burst Core duration is decreased by <red>50%,</> but is <cyan>extended while hitting enemies.</>"
        mod.shortdesc = "<daze>On Burst Core hit:</> Core duration is extended."
        mod.tags = [EXPEDITION_REARM_TAG]
        mod.statModifiers = [NewStatModifier("cd_reduction", 0.05263)]
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("addiction")
        mod.name = "Addiction"
        mod.abbreviation = "Add"
        mod.description = "<cyan>+100% Melee DMG.</> Enemy Titans finished off with Melee <green>spawn an additional battery.</>"
        mod.shortdesc = "<daze>On Melee kill:</> <green>spawn an additional battery."
        mod.tags = [EXPEDITION_REARM_TAG]
        mod.statModifiers = [NewStatModifier("cd_reduction", 0.05263)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("crippling_missiles")
        mod.name = "Crippling Missiles"
        mod.abbreviation = "CM"
        mod.description = "Missiles additionally <cyan>deal damage over time.</> These Damage over Times stack. The duration scales with <cyan>Ability Duration.</>"
        mod.shortdesc = "Missiles also <cyan>deal damage over time."
        mod.tags = [EXPEDITION_REARM_TAG]
        mod.statModifiers = [NewStatModifier("cd_reduction", 0.05263)]
        {
            HoverSimpleBox box
            box.currentValue = "10"
            box.label = "DPS per Rocket"
            mod.boxes.append(box)
        }
        {
            HoverSimpleBox box
            box.currentValue = "5s"
            box.label = "Base Duration"
            mod.boxes.append(box)
        }
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("xo16_long_range")
        mod.name = "Long Range Mode"
        mod.abbreviation = "LRM"
        mod.description = "The XO-16's accuracy and range are <cyan>greatly increased.</> Base Damage increases by 10%."
        mod.shortdesc = "XO-16 accuracy and range <cyan>greatly increased."
        mod.tags = [EXPEDITION_REARM_TAG]
        mod.statModifiers = [NewStatModifier("cd_reduction", 0.05263)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("xo16_accelerator")
        mod.name = "Accelerator"
        mod.abbreviation = "Al"
        mod.description = "Base fire rate reduced by <red>50%,</> but increases over time, up to <cyan>200%.</>"
        mod.shortdesc = "XO-16 fire rate <cyan>increases over time."
        mod.tags = [EXPEDITION_WEAKEN_TAG]
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("rearm_reshield")
        mod.name = "Rearm and Reshield"
        mod.abbreviation = "RaR"
        mod.description = "Rearm restores <cyan>shields to full</> and grants <cyan>30% DMG Resist</> for 15s."
        mod.shortdesc = "Rearm restores <cyan>shields to full</> and grants\nDMG Resist."
        mod.tags = [EXPEDITION_WEAKEN_TAG]
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("quick_rearm")
        mod.name = "Quick Rearm"
        mod.abbreviation = "QR"
        mod.description = "Rearm cooldown reduced by <cyan>50%.</> Other abilty cooldowns <red>increased by 300%.</>"
        mod.shortdesc = "Rearm cooldown <cyan>reduced.</> Other abilty\ncooldowns <red>increased."
        mod.tags = [EXPEDITION_WEAKEN_TAG]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("rearm_reload")
        mod.name = "Rearm and Reload"
        mod.abbreviation = "RR"
        mod.description = "Rearm reloads your primary weapons and grants <cyan>+25% DMG<cyan> for 20s."
        mod.shortdesc = "Rearm reloads your weapons and grants <cyan>+DMG%."
        mod.tags = [EXPEDITION_REARM_TAG]
        mod.statModifiers = [NewStatModifier("cd_reduction", 0.05263)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("dumbfire_rockets")
        mod.name = "Dumbfire Rockets"
        mod.abbreviation = "DR"
        mod.description = "Multi-Target Missile System <red>no longer locks onto enemies,</> but instead <cyan>fires 5 missiles in a burst.</> +150% Base Damage, Total rockets increased to <cyan>15.</>"
        mod.shortdesc = "MTMS <cyan>fires in bursts.</>\nRocket damage and amount increased."
        mod.tags = [EXPEDITION_WEAKEN_TAG]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("atg_missile")
        mod.name = "AtG Missile"
        mod.abbreviation = "AtG"
        mod.description = "<daze>On Hit:</> 20% chance to <cyan>launch a missile</> for 50% of damage dealt."
        mod.shortdesc = "<daze>On Hit:</> Sometimes, <cyan>launch a missile."
        mod.tags = [EXPEDITION_WEAKEN_TAG]
        mod.cost = 3
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("xo16_intensify")
        mod.name = "Intensifying Magazine"
        mod.abbreviation = "IMg"
        mod.description = "On XO16 hit: <cyan>+3% DMG</> for 3s. Stacks. Repeated triggers refresh the duration."
        mod.shortdesc = "On XO16 hit: <cyan>+3% DMG</> for 3s.\nRepeated triggers refresh the duration."
        mod.tags = [EXPEDITION_WEAKEN_TAG]
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }

    // NOT LOADOUT SPECIFIC
    {
        RoguelikeMod mod = NewMod("vortex_absorb_ammo")
        mod.name = "Vortex Absorb"
        mod.abbreviation = "VA"
        mod.description = "Vortex Shield <cyan>reloads your weapon</> if there are any projctiles caught, and converts <cyan>rockets into energy.</>"
        mod.shortdesc = "Vortex Shield may <cyan>reload your weapon</>, and grant\n<cyan>offensive energy."
        mod.cost = 2
        mod.loadouts = [ PRIMARY_ION ]
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("vortex_anti_drain")
        mod.name = "Power Vortex"
        mod.abbreviation = "PV"
        mod.description = "Vortex Shield <cyan>will catch Cores unhindered,</> <red>it's duration is reduced by 25%.</>"
        mod.shortdesc = "Vortex Shield <cyan>will catch Cores unhindered.</>\n<red>Duration reduced."
        mod.cost = 2
        mod.loadouts = [ PRIMARY_EXPEDITION ]
        mod.chip = TITAN_CHIP_ABILITIES
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = true
    mod.loadouts = [PRIMARY_EXPEDITION]
    mod.chip = 3
    mod.isTitan = true

    return mod
}
