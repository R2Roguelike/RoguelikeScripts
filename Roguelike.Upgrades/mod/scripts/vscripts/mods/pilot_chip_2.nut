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
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 2
    mod.isTitan = false
    
    return mod
}
