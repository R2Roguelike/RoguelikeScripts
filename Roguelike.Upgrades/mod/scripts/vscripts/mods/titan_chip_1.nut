global function TitanChip1_RegisterMods

void function TitanChip1_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("max_shield")
        mod.name = "Amped Shield"
        mod.description = "Max shield health significantly increased."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("battery_spawn")
        mod.name = "Battery Thief"
        mod.description = "Slightly increases chance of batteries dropping from enemies."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("checkpoint")
        mod.name = "Devil's Deal"
        mod.description = "Dying as a titan allows you to load a checkpoint ONCE.\n\nWARNING: This mod cannot be swapped once consumed."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        // NOT IMPLEMENTED
        RoguelikeMod mod = NewMod("titan_long_range_resist")
        mod.name = "Anti-Bullshitinator"
        mod.description = "Take reduced damage from faraway targets."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("titan_brawler")
        mod.name = "Brawler"
        mod.description = "Take reduced damage from close targets."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
    }
    /*
    {
        RoguelikeMod mod = NewMod("checkpoint_used")
        mod.name = "Devil's Cost"
        mod.description = "You died and respawned. Now bear the cost.\n\nThis mod CANNOT be swapped."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    */
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 1
    mod.isTitan = true
    
    return mod
}