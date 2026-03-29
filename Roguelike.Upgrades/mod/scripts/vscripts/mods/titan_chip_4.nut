global function TitanChip4_RegisterMods

void function TitanChip4_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("frost_walker")
        mod.name = "Frost Walker"
        mod.abbreviation = "FW"
        mod.description = "While sprinting, ability cooldowns reduced by <cyan>35%.</>"
        mod.shortdesc = "Ability cooldowns reduced <daze>while sprinting."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("titan_parry")
        mod.name = "Parry"
        mod.abbreviation = "Pr"
        mod.description = "Using a defensive ability restores energy for your offensives."
        mod.shortdesc = "Defensive ability usage restores energy for\noffensives."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("titan_counter")
        mod.name = "Counter"
        mod.abbreviation = "Ct"
        mod.description = "Using an offensive ability restores energy for your defensives."
        mod.shortdesc = "Offensive ability usage restores energy for\ndefensives."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("offensive_cd")
        mod.name = "Offensive Accelerator"
        mod.abbreviation = "OA"
        mod.description = "<cyan>Cooldown reduced for offensive abilities.</>"
        mod.shortdesc = "<cyan>Cooldown reduced for offensive abilities."
        {
            HoverSimpleBox box
            box.icon = $"ui/cooldown"
            box.currentValue = "25%"
            box.label = "Cooldown Reduction"
            mod.boxes.append(box)
        }
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("ability_duration")
        mod.name = "Duration Extender"
        mod.abbreviation = "DE"
        mod.description = "<cyan>Duration extended for all abilities.</>"
        mod.shortdesc = "<cyan>Duration extended for all abilities."
        {
            HoverSimpleBox box
            box.currentValue = "+36%"
            box.label = "Ability Duration"
            mod.boxes.append(box)
        }
        mod.statModifiers = [NewStatModifier("ability_duration", 0.36)]
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("ability_power")
        mod.name = "Empowerment"
        mod.abbreviation = "Emp"
        mod.description = "<cyan>Ability Power increased.</>"
        mod.shortdesc = "<cyan>Ability Power increased."
        {
            HoverSimpleBox box
            box.currentValue = "+20"
            box.label = "Ability Power"
            mod.boxes.append(box)
        }
        mod.statModifiers = [NewStatModifier("ability_power", 20)]
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("utility_cd")
        mod.name = "Utility Accelerator"
        mod.abbreviation = "UA"
        mod.description = "<cyan>Cooldown reduced for utility abilities.</>"
        mod.shortdesc = "<cyan>Cooldown reduced for utility abilities."
        {
            HoverSimpleBox box
            box.icon = $"ui/cooldown"
            box.currentValue = "25%"
            box.label = "Cooldown Reduction"
            mod.boxes.append(box)
        }
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("defensive_cd")
        mod.name = "Defensive Accelerator"
        mod.abbreviation = "DA"
        mod.description = "<cyan>Cooldown reduced for defensive abilities.</>"
        mod.shortdesc = "<cyan>Cooldown reduced for defensive abilities."
        {
            HoverSimpleBox box
            box.icon = $"ui/cooldown"
            box.currentValue = "25%"
            box.label = "Cooldown Reduction"
            mod.boxes.append(box)
        }
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