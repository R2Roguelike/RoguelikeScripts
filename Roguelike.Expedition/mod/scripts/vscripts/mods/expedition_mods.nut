global function Expedition_RegisterMods

void function Expedition_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("never_ending_burst")
        mod.name = "Accuracy Burst"
        mod.description = "Core duration is decreased by <red>50%</>. Core duration is <cyan>extended while hitting enemies</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("quick_rearm")
        mod.name = "Quick Rearm"
        mod.description = "Rearm cooldown reduced by 66%. Other abilty cooldowns <red>increased by 300%</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("rearm_reset")
        mod.name = "Rearm and Reset"
        mod.description = "Rearming <cyan>resets cooldowns for your other loadout as well</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("vortex_absorb_ammo")
        mod.name = "Vortex Absorb"
        mod.description = "Vortex Shield <cyan>reloads your weapon</> if there are any projctiles caught, and also loads catched <cyan>rockets into your Missile Launcher</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("dumbfire_rockets")
        mod.name = "Dumbfire Rockets"
        mod.description = "Multi-Target Missile System <red>no longer locks onto enemies</>, but instead <cyan>fires 6 missiles in a burst.</> Total rockets increased to <cyan>18</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("inverse_relationship")
        mod.name = "Inverse Relationship"
        mod.description = "Multi-Target Missile System <red>no longer inflicts weaken</>, but instead <cyan>your primary does</>." + 
        "\n\nMulti-Target Missile System <cyan>now deals triple damage to weakened enemies</>, but <red>your primary no longer does</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("xo16_long_range")
        mod.name = "Long Range Mode"
        mod.description = "Accuracy and range <cyan>greatly increased</>. Fire rate <red>decreased by 16%</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("atg_missile")
        mod.name = "Automatic Missile Launcher"
        mod.description = "On Hit: 50% chance to launch a missile."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = true
    mod.loadouts = [PRIMARY_EXPEDITION]
    mod.chip = 1
    mod.isTitan = true
    
    return mod
}
