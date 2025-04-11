global function Ronin_RegisterMods

void function Ronin_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("ronin_dash_melee")
        mod.name = "Dash-Attack"
        mod.description = "Timing your dash with your sword hit <cyan>gurantees a critical hit</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        // NOT IMPLEMENTED
        RoguelikeMod mod = NewMod("reflective_sword")
        mod.name = "Reflective Sword"
        mod.description = "Sword block blocks <green>100%</> damage.\nBlocked damage <cyan>grants up to +35% DMG</>.\nSword block <red>no longer blocks ANY damage</> while at max charge."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        // NOT IMPLEMENTED
        RoguelikeMod mod = NewMod("quickswap")
        mod.name = "Quickswap"
        mod.description = "Firing your shotgun right after switching to it deals<red> +100% damage</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("offensive_daze_hits")
        mod.name = "Conductive Sword"
        mod.description = "Sword hits while the target has Daze charge your offensives."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("overcharged_arc_wave")
        mod.name = "Overcharged Waves"
        mod.description = "Arc Wave recharges rapidly when using sword core."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("conduction")
        mod.name = "Conduction"
        mod.description = "Arc Wave hits restore Dash Energy."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("sword_core_use")
        mod.name = "Unrelenting Sword"
        mod.description = "Less Sword Core duration is consumed while swinging your sword."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("sword_core_daze")
        mod.name = "Overdaze"
        mod.description = "Sword core may consume daze charges for +DMG%."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("executioner_meal")
        mod.name = "Executioners Meal"
        mod.description = "Enemies finished off with Sword Core spawn a <green>battery</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("offensive_overload")
        mod.name = "Daze to All"
        mod.description = "When dealing damage with any offensive ability - the target is inflicted <daze>Daze</>. This can trigger every 10s."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("always_sword")
        mod.name = "Sword Sheath"
        mod.description = "You always use your sword for melee."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("phase_ammo")
        mod.name = "Phase Ammo"
        mod.description = "Phase Dash reloads all weapons."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
        mod.chip = TITAN_CHIP_WEAPON
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = false
    mod.loadouts = [PRIMARY_RONIN]
    mod.isTitan = true
    
    return mod
}