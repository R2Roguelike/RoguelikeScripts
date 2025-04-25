global function TitanChip1_RegisterMods

void function TitanChip1_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("max_shield")
        mod.name = "Amped Shield"
        mod.abbreviation = "AS"
        mod.description = "Max shield health significantly increased."
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("lifesteal")
        mod.name = "Metalsteal"
        mod.abbreviation = "MS"
        mod.description = "Gain 30% Lifesteal to enemies within 20m."
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("battery_spawn")
        mod.name = "Battery Thief"
        mod.abbreviation = "BT"
        mod.description = "Enemies have a 25% chance to drop a <green>battery</> upon death."
        mod.cost = 2
    }
    {
        // NOT IMPLEMENTED
        RoguelikeMod mod = NewMod("titan_long_range_resist")
        mod.name = "Anti-Bullshitinator"
        mod.abbreviation = "A-B"
        mod.description = "Reduce damage taken by 25% from faraway targets."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("titan_brawler")
        mod.name = "Brawler"
        mod.abbreviation = "Bl"
        mod.description = "Reduce damage taken by 33% from close targets."
        mod.cost = 1
    }
    // TODO: CONVERT TO PERMANENT UPGRADE?
    {
        RoguelikeMod mod = NewMod("dash_iframes")
        mod.name = "Evasive Dash"
        mod.abbreviation = "ED"
        mod.description = "While dashing, take no damage."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("battery_heals")
        mod.name = "Healing++"
        mod.abbreviation = "H++"
        mod.description = "Healing from batteries increased by 35%."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("second_wind")
        mod.name = "Second Wind"
        mod.abbreviation = "SW"
        mod.description = "Titan kills while doomed undoom you. <red>Batteries no longer heal you.</>"
        mod.cost = 4
    }
    if (false)
    {
        RoguelikeMod mod = NewMod("checkpoint")
        mod.name = "Devil's Deal"
        mod.description = "Dying as a titan allows you to restart a level ONCE."
        mod.cost = 2
    }
    if (false)
    {
        RoguelikeMod mod = NewMod("checkpoint_used")
        mod.name = "Devil's Cost"
        mod.description = "You died and respawned. Now bear the cost.\n\nThis mod CANNOT be swapped."
        mod.cost = 2
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 1
    mod.isTitan = true
    
    return mod
}