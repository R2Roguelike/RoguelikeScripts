global function PilotChip1_RegisterMods

void function PilotChip1_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("bloodthirst")
        mod.name = "Bloodthirst"
        mod.description = "Heal for 5HP for every hit on a nearby enemy."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("last_stand")
        mod.name = "Last Stand"
        mod.description = "While below 50% HP, gain damage resistance."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("titan_aptitude")
        mod.name = "Titan Aptitude"
        mod.description = "Take reduced damage from titans."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        // NOT IMPLEMENTED
        RoguelikeMod mod = NewMod("pilot_long_range_resist")
        mod.name = "Anti-Bullshitinator"
        mod.description = "Take reduced damage from faraway targets."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("pilot_brawler")
        mod.name = "Brawler"
        mod.description = "Take reduced damage from close targets."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("speed_shield")
        mod.name = "SPEED-BASED SHIELD"
        mod.description = "When moving at 50km/h or above, you are invulnerable."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)
    mod.chip = 1
    mod.isTitan = false
    return mod
}