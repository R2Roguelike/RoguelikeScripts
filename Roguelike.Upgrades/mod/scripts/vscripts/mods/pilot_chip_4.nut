global function PilotChip4_RegisterMods

void function PilotChip4_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("uninterruptable_cloak")
        mod.name = "Stealth++"
        mod.description = "Cloak is uninterrupted by firing your weapon."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("cloak_damage")
        mod.name = "Backstab"
        mod.description = "Damage dealt while cloaked is increased."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("cloak_nades")
        mod.name = "Nades from the dark"
        mod.description = "Grenades restore faster when cloaking."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("big_boom")
        mod.name = "Big Boom"
        mod.description = "Grenade blast radius increased."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("impact_frag")
        mod.name = "Fragile Frag"
        mod.description = "Frag Grenades detonate on impact."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 4
    mod.isTitan = false
    
    return mod
}
