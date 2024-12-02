global function Ronin_RegisterMods

void function Ronin_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("daze_arc_wave")
        mod.name = "Dazing Arc Wave"
        mod.description = "Arc Wave deals ^FFE16400Daze^FFFFFFFF to enemies. Additional copies increase Daze dealt."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("ronin_dash_melee")
        mod.name = "Dash-Attack"
        mod.description = "Timing your dash with your sword hit increases damage."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
    }
    {
        // NOT IMPLEMENTED
        RoguelikeMod mod = NewMod("reflective_sword")
        mod.name = "Reflective Sword"
        mod.description = "Sword block blocks ^40FF4000100%^FFFFFFFF damage.\nBlocked damage ^40FFFF00charges your next sword hit^FFFFFFFF.\nSword block ^FF404000no longer blocks ANY damage^FFFFFFFF while at max charge."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    if (false)
    {
        // NOT IMPLEMENTED
        RoguelikeMod mod = NewMod("quickswap")
        mod.name = "Quickswap"
        mod.description = "Firing your shotgun right after switching to it deals ^FF404000massive damage^FFFFFFFF and ^FFE16400maximum Daze^FFFFFFFF."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("offensive_daze_hits")
        mod.name = "Conductive Sword"
        mod.description = "Sword hits while the target has Daze charge your offensives."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("overcharged_arc_wave")
        mod.name = "Overcharged Waves"
        mod.description = "Arc Wave recharges rapidly when using sword core."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("conduction")
        mod.name = "Conduction"
        mod.description = "Arc Wave hits restore Dash Energy."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("sword_core_use")
        mod.name = "Unrelenting Sword"
        mod.description = "Less Sword Core duration is consumed while swinging your sword."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = true
    mod.loadout = "mp_titanweapon_leadwall"
    mod.chip = 1
    mod.isTitan = true
    
    return mod
}