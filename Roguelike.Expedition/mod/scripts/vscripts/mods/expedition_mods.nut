global function Expedition_RegisterMods

void function Expedition_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("never_ending_burst")
        mod.name = "Accuracy Burst"
        mod.description = "Burst Core duration is decreased by <red>50%</>, but is <cyan>extended while hitting enemies</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("quick_rearm")
        mod.name = "Quick Rearm"
        mod.description = "Rearm cooldown reduced by 66%. Other abilty cooldowns <red>increased by 300%</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("rearm_reload")
        mod.name = "Rearm and Reload"
        mod.description = "Rearm reloads your primary weapons and grants them <cyan>+25% DMG<cyan> for 10s."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("vortex_absorb_ammo")
        mod.name = "Vortex Absorb"
        mod.description = "Vortex Shield <cyan>reloads your weapon</> if there are any projctiles caught, and loads <cyan>rockets into your offensive</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.loadouts = [ PRIMARY_EXPEDITION, PRIMARY_BRUTE, PRIMARY_ION ]
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("dumbfire_rockets")
        mod.name = "Dumbfire Rockets"
        mod.description = "Multi-Target Missile System <red>no longer locks onto enemies</>, but instead <cyan>fires 6 missiles in a burst.</> +100% Base Damage, Total rockets increased to <cyan>18</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("xo16_long_range")
        mod.name = "Long Range Mode"
        mod.description = "The XO-16's accuracy and range are <cyan>greatly increased</>, but it's fire rate is <red>decreased by 16%</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("xo16_accelerator")
        mod.name = "Accelerator"
        mod.description = "Base fire rate reduced by <red>50%</>, but increases over time, up to <cyan>200%</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("atg_missile")
        mod.name = "Automatic Missile Launcher"
        mod.description = "On Hit: 25% chance to launch a missile for 50% of damage dealt."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
        mod.chip = TITAN_CHIP_UTILITY
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
