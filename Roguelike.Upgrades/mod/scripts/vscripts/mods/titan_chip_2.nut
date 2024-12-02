global function TitanChip2_RegisterMods

void function TitanChip2_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("titan_counter")
        mod.name = "Counter"
        mod.description = "Using a defensive ability restores energy for your offensives."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("titan_parry")
        mod.name = "Parry"
        mod.description = "Using an offensive ability restores energy for your defensives."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("frost_walker")
        mod.name = "Frost Walker"
        mod.description = "While sprinting, ability cooldowns reduced."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("tick_spawner")
        mod.name = "Tick-Tock O'Clock"
        mod.description = "Killing an enemy Titan or Reaper has a chance to spawn ticks."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 2
    mod.isTitan = true
    
    return mod
}