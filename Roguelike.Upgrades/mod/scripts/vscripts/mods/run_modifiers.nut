global function RunModifiers_Init

void function RunModifiers_Init()
{
    {
        RoguelikeRunModifier mod = NewMod("the_long_way")
        mod.name = "Route"
        mod.description = "The route to the Fold Weapon has been extended... and the enemies will use the additional time to get even stronger."
        mod.options = ["Normal", "Long", "Stupidly Long"]
        mod.baseCost = 2
        mod.costPerLevel = 4
    }
    {
        RoguelikeRunModifier mod = NewMod("memory")
        mod.name = "TITAN HP PERSISTENCE"
        mod.description = "BT's health persists for the entrire run."
        mod.options = ["Off", "On"]
        mod.baseCost = 3
    }
    {
        RoguelikeRunModifier mod = NewMod("pain")
        mod.name = "DMG Taken"
        mod.description = "Damage taken increased."
        mod.options = ["+0%", "+25%", "+50%", "+75%", "+100%"]
        mod.baseCost = 1
        mod.costPerLevel = 3
    }
    {
        RoguelikeRunModifier mod = NewMod("titan_health")
        mod.name = "Lost Segments On Doom"
        mod.description = "BT's health is reduced, and spread out into more segments."
        mod.options = ["0", "1"]
        mod.baseCost = 3
    }
    {
        RoguelikeRunModifier mod = NewMod("unwalkable")
        mod.name = "Pilot Walk Speed"
        mod.description = "Your ground speed as a Pilot is reduced."
        mod.options = ["-0%", "-25%", "-50%", "-75%"]
        mod.baseCost = 1
        mod.costPerLevel = 2
    }
    {
        RoguelikeRunModifier mod = NewMod("defense")
        mod.name = "Enemy Defensive CD"
        mod.description = "Enemies have their defensive cooldowns reduced."
        mod.options = ["-0%", "-50%", "-75%", "-100%"]
        mod.baseCost = 1
        mod.costPerLevel = 2
    }
    {
        RoguelikeRunModifier mod = NewMod("time_pain")
        mod.name = "Min. Time Rank"
        mod.description = "After the time for getting a rating has ran out, you will start to receive damage."
        mod.options = ["Off", "B-Rank", "A-Rank", "S-Rank"]
        mod.baseCost = 1
        mod.costPerLevel = 3
    }
    {
        RoguelikeRunModifier mod = NewMod("crit_or_nothing")
        mod.name = "Non-Crit DMG"
        mod.description = "Non-critical hits against Titans deal reduced damage."
        mod.options = ["-0%", "-25%", "-50%"]
        mod.baseCost = 2
        mod.costPerLevel = 3
    }
    {
        RoguelikeRunModifier mod = NewMod("time_requirement")
        mod.name = "Time Requirements"
        mod.description = "Reduces the time you have to get a rank for each stage."
        mod.options = ["-0%", "-16%", "-33%"]
        mod.baseCost = 2
        mod.costPerLevel = 3
    }
    {
        RoguelikeRunModifier mod = NewMod("vanilla_movement")
        mod.name = "Vanilla Movement"
        mod.description = "Enables vanilla movement."
        mod.options = ["NO", "YES"]
        mod.baseCost = 0
        mod.costPerLevel = 0
    }
}

RoguelikeRunModifier function NewMod(string uniqueName)
{
    RoguelikeRunModifier mod = Roguelike_NewRunModifier(uniqueName)

    return mod
}