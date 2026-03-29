global function RunModifiers_Init

void function RunModifiers_Init()
{
    {
        RoguelikeRunModifier mod = NewMod("the_long_way")
        mod.name = "Route"
        mod.description = "You will have to play through more levels to win...\n\n<red>and the enemies will use the additional time to get even stronger."
        mod.options = ["Normal", "Long", "Stupidly Long"]
        mod.baseCost = 1
        mod.costPerLevel = 1
    }
    {
        RoguelikeRunModifier mod = NewMod("pain")
        mod.name = "DMG Taken"
        mod.description = "Damage taken increased."
        mod.options = ["-20%", "+0%", "+25%", "+50%", "+75%", "+100%"]
        mod.baseCost = 1
        mod.costPerLevel = 3
        mod.negativeCost = -15
        mod.defaultValue = 1
    }
    {
        RoguelikeRunModifier mod = NewMod("titan_health")
        mod.name = "Segment Loss"
        mod.description = "<red>PERMANENTLY</> lose health segments when you get doomed."
        mod.options = ["0", "1"]
        mod.baseCost = 5
    }
    {
        RoguelikeRunModifier mod = NewMod("unwalkable")
        mod.name = "Pilot Walk Speed"
        mod.description = "Your ground speed as a Pilot is reduced."
        mod.options = ["0%", "-15%", "-30%"]
        mod.baseCost = 2
        mod.costPerLevel = 2
    }
    {
        RoguelikeRunModifier mod = NewMod("core_gain")
        mod.name = "Enemy Core CD"
        mod.description = "Enemy use their cores more often."
        mod.options = ["0%", "-99%"]
        mod.baseCost = 4
        mod.costPerLevel = 0
    }
    {
        RoguelikeRunModifier mod = NewMod("defense")
        mod.name = "Enemy Defensive CD"
        mod.description = "Enemies have their defensive cooldowns reduced."
        mod.options = ["-0%", "-50%", "-75%", "-99%"]
        mod.baseCost = 2
        mod.costPerLevel = 2
    }
    {
        RoguelikeRunModifier mod = NewMod("enemy_hp")
        mod.name = "Enemy Base HP"
        mod.description = "Increases the enemy's base health.\n\n<red>This is multiplicative with the health increases."
        mod.options = ["+0", "+33%", "+66%", "+100%"]
        mod.baseCost = 2
        mod.costPerLevel = 3
    }
    {
        RoguelikeRunModifier mod = NewMod("cash_gain")
        mod.name = "Cash Gained"
        mod.description = "Reduces cash gained from enemies."
        mod.options = ["+25%", "+0%", "-15%", "-30%", "-50%"]
        mod.baseCost = 2
        mod.costPerLevel = 3
        mod.negativeCost = -15
        mod.defaultValue = 1
    }
    {
        RoguelikeRunModifier mod = NewMod("proj_speed")
        mod.name = "Enemy Projectile Spd"
        mod.description = "Increases enemy projectile speed."
        mod.options = ["+0%", "+50%", "+100%"]
        mod.baseCost = 2
        mod.costPerLevel = 1
    }
    {
        RoguelikeRunModifier mod = NewMod("elite_freq")
        mod.name = "Elite Enemies"
        mod.description = "Elite enemies (colorful outlines!) appear more often."
        mod.options = ["NORMAL", "MORE", "WAY MORE", "WAY MORE!", "WAY MORE!!"]
        mod.baseCost = 3
        mod.costPerLevel = 2
    }
    {
        RoguelikeRunModifier mod = NewMod("vanilla_movement")
        mod.name = "Vanilla Movement"
        mod.description = "Enables vanilla movement."
        mod.options = ["NO", "YES"]
        mod.baseCost = 0
        mod.costPerLevel = 0
    }
    {
        RoguelikeRunModifier mod = NewMod("speedrun")
        mod.name = "Speedrun Mode"
        mod.description = "Swaps the level timer with a speedrun timer.\n\n<red>Doesn't change game mechanics. Only recommended if you're speedrunning."
        mod.options = ["NO", "^4080FF00YES"]
        mod.baseCost = 0
        mod.costPerLevel = 0
    }
    {
        RoguelikeRunModifier mod = NewMod("checkpoints")
        mod.name = "Checkpoints"
        mod.description = "Determines when checkpoints are loaded.\n\n" +
        //"^00FF8000Always:</> Always loads checkpoints. <note>At that point, are you even playing a roguelike...?</>" +
        "<daze>Default:</> Loads when you die to platforming.\n" +
        "^FF800000Never:</> Dying, <red>by ANY method,</> ends the run."
        mod.options = ["DEFAULT", "NEVER"]
        mod.baseCost = 10
        mod.negativeCost = -100
        mod.defaultValue = 0
    }
    {
        RoguelikeRunModifier mod = NewMod("battery_healing")
        mod.name = "Battery Healing"
        mod.description = "Changes the amount of healing batteries grant."
        mod.options = ["^00FF80001200", "^00FF80001000", "800", "600", "400"]
        mod.baseCost = 5
        mod.costPerLevel = 5
        mod.negativeCost = -10
        mod.defaultValue = 2
    }
    {
        RoguelikeRunModifier mod = NewMod("rerolls")
        mod.name = "Loadout Rerolls"
        mod.description = "Changes the amount of rerolls you get."
        mod.options = ["^00FF80002", "1", "0"]
        mod.baseCost = 2
        mod.costPerLevel = 0
        mod.negativeCost = -15
        mod.defaultValue = 1
    }
}

RoguelikeRunModifier function NewMod(string uniqueName)
{
    RoguelikeRunModifier mod = Roguelike_NewRunModifier(uniqueName)

    return mod
}