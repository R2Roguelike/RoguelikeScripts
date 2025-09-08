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
        RoguelikeMod mod = NewMod("armor_2")
        mod.name = "Armor+2"
        mod.abbreviation = "A+2"
        mod.description = "+10 <cyan>Armor</>."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("lifesteal")
        mod.name = "Shieldsteal"
        mod.abbreviation = "MS"
        mod.description = "Restore 20% of damage dealt to enemies within 20m as shields."
        mod.cost = 3
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
        RoguelikeMod mod = NewMod("battery_heals")
        mod.name = "Healing++"
        mod.abbreviation = "H++"
        mod.description = "Healing from batteries increased by 35%."
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