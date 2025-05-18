global function TitanChip4_RegisterMods

void function TitanChip4_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("frost_walker")
        mod.name = "Frost Walker"
        mod.abbreviation = "FW"
        mod.description = "While sprinting, ability cooldowns reduced by <cyan>35%</>."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("titan_parry")
        mod.name = "Parry"
        mod.abbreviation = "Pr"
        mod.description = "Using a defensive ability restores energy for your offensives."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("titan_counter")
        mod.name = "Counter"
        mod.abbreviation = "Ct"
        mod.description = "Using an offensive ability restores energy for your defensives."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("offensive_cd")
        mod.name = "Offensive Accelerator"
        mod.abbreviation = "OA"
        mod.description = "<cyan>-25% offensive ability cooldowns</>."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("utility_cd")
        mod.name = "Utility Accelerator"
        mod.abbreviation = "UA"
        mod.description = "<cyan>-25% utility ability cooldowns</>."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("defensive_cd")
        mod.name = "Defensive Accelerator"
        mod.abbreviation = "DA"
        mod.description = "<cyan>-25% defensive ability cooldowns</>."
        mod.cost = 2
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 4
    mod.isTitan = true

    return mod
}