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
        RoguelikeMod mod = NewMod("cd_reduce")
        mod.name = "Time Accelerator"
        mod.abbreviation = "TA"
        mod.description = "<cyan>-20% all cooldowns</>."
        mod.cost = 3
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 4
    mod.isTitan = true
    
    return mod
}