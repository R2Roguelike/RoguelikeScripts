global function Expedition_RegisterMods



void function Expedition_RegisterMods()
{
    // +5% weaken DMG bonus
    // -5% rearm cooldown
    // ["never_ending_burst", ""]
    {
        RoguelikeMod mod = NewMod("never_ending_burst")
        mod.name = "Accuracy Burst"
        mod.abbreviation = "AB"
        mod.description = "<cyan>-5% Rearm cooldown.</>\n\nBurst Core duration is decreased by <red>50%,</> but is <cyan>extended while hitting enemies.</>"
        mod.shortdesc = "<daze>On Burst Core hit:</> Core duration is extended."
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("addiction")
        mod.name = "Addiction"
        mod.abbreviation = "Add"
        mod.description = "<cyan>-5% Rearm cooldown.</>\n\n<cyan>+100% Melee DMG.</> Enemy Titans finished off with Melee <green>spawn an additional battery.</>\n"
        mod.shortdesc = "<daze>On Melee kill:</> <green>spawn an additional battery."
        mod.cost = 2
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("xo16_long_range")
        mod.name = "Long Range Mode"
        mod.abbreviation = "LRM"
        mod.description = "<cyan>-5% Rearm cooldown.</>\n\nThe XO-16's accuracy and range are <cyan>greatly increased.</> Base Damage increases by 10%."
        mod.shortdesc = "XO-16 accuracy and range <cyan>greatly increased."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("xo16_accelerator")
        mod.name = "Accelerator"
        mod.abbreviation = "Al"
        mod.description = "<cyan>-5% Rearm cooldown.</>\n\nBase fire rate reduced by <red>50%,</> but increases over time, up to <cyan>200%.</>"
        mod.shortdesc = "XO-16 fire rate <cyan>increases over time."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("rearm_reshield")
        mod.name = "Rearm and Reshield"
        mod.abbreviation = "RaR"
        mod.description = "<cyan>-5% Rearm cooldown.</>\n\nRearm restores shields to full and grants 30% DMG Resist for 15s."
        mod.shortdesc = "Rearm restores shields to full and grants\nDMG Resist."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("quick_rearm")
        mod.name = "Quick Rearm"
        mod.abbreviation = "QR"
        mod.description = "<cyan>+5% weaken DMG bonus.</>\n\nRearm cooldown reduced by 50%. Other abilty cooldowns <red>increased by 300%.</>"
        mod.shortdesc = "Rearm cooldown reduced. Other abilty\ncooldowns <red>increased."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("rearm_reload")
        mod.name = "Rearm and Reload"
        mod.abbreviation = "RR"
        mod.description = "<cyan>+5% weaken DMG bonus.</>\n\nRearm reloads your primary weapons and grants <cyan>+25% DMG<cyan> for 20s."
        mod.shortdesc = "Rearm reloads your weapons and grants <cyan>+DMG%."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("dumbfire_rockets")
        mod.name = "Dumbfire Rockets"
        mod.abbreviation = "DR"
        mod.description = "<cyan>+5% weaken DMG bonus.</>\n\nMulti-Target Missile System <red>no longer locks onto enemies,</> but instead <cyan>fires 5 missiles in a burst.</> +150% Base Damage, Total rockets increased to <cyan>15.</>"
        mod.shortdesc = "MTMS <cyan>fires in bursts.</>\nRocket damage and amount increased."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("atg_missile")
        mod.name = "AtG Missile"
        mod.abbreviation = "AtG"
        mod.description = "<cyan>+5% weaken DMG bonus.</>\n\nOn Hit: 20% chance to launch a missile for 50% of damage dealt."
        mod.shortdesc = "<daze>On Hit:</> Sometimes, launch a missile."
        mod.cost = 3
        mod.chip = TITAN_CHIP_UTILITY
    }

    // NOT LOADOUT SPECIFIC
    {
        RoguelikeMod mod = NewMod("vortex_absorb_ammo")
        mod.name = "Vortex Absorb"
        mod.abbreviation = "VA"
        mod.description = "Vortex Shield <cyan>reloads your weapon</> if there are any projctiles caught, and loads <cyan>rockets into offensive energy.</>"
        mod.shortdesc = "Vortex Shield may <cyan>reload your weapon</>, and grant\n<cyan>offensive energy."
        mod.cost = 2
        mod.loadouts = [ PRIMARY_EXPEDITION, PRIMARY_ION ]
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("vortex_anti_drain")
        mod.name = "Power Vortex"
        mod.abbreviation = "PV"
        mod.description = "Vortex Shield <cyan>will catch Cores unhindered,</> <red>it's duration is reduced by 25%.</>"
        mod.shortdesc = "Vortex Shield <cyan>will catch Cores unhindered.</>\n<red>Duration reduced."
        mod.cost = 2
        mod.loadouts = [ PRIMARY_EXPEDITION, PRIMARY_ION ]
        mod.chip = TITAN_CHIP_ABILITIES
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = false
    mod.loadouts = [PRIMARY_EXPEDITION]
    mod.chip = 1
    mod.isTitan = true

    return mod
}
