global function TitanChip3_RegisterMods

void function TitanChip3_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("bonus_mag")
        mod.name = "Ammo++"
        mod.abbreviation = "A++"
        mod.description = "+100% mag size <note>(up to 50)</> for all weapons."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("shield_core")
        mod.name = "Shield Core"
        mod.abbreviation = "SC"
        mod.description = "On Core use: Replenish your shields instantly."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("weapon_crit")
        mod.name = "Overcrit"
        mod.abbreviation = "Oc"
        mod.description = "When hitting with your primary, increase Crit Rate by 0.5% for 3s. Stacks up to 20 times, repeated triggers reset the duration."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("weapon_load")
        mod.name = "Fast Loader"
        mod.abbreviation = "FL"
        mod.description = "-35% Reload Time."
        mod.cost = 2
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 3
    mod.isTitan = true

    return mod
}