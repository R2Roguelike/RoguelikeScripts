global function PilotChip2_RegisterMods

void function PilotChip2_RegisterMods()
{

    {
        RoguelikeMod mod = NewMod("grenade_cd")
        mod.name = "Grenadier"
        mod.description = "Kills restore grenade energy."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("tactical_cd")
        mod.name = "Tacticool"
        mod.description = "Kills restore tactical energy."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("ground_friction")
        mod.name = "shiny boots"
        mod.description = "Ground friction reduced by ^40FFFF0030%^FFFFFFFF."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("wall_friction")
        mod.name = "Anti-friction jumpkit"
        mod.description = "Wall friction reduced by ^40FFFF0030%^FFFFFFFF."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("bhopper")
        mod.name = "2much4zblock"
        mod.description = "+300% air acceleration."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 2
    mod.isTitan = false
    
    return mod
}
