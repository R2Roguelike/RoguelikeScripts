global function TitanChip1_RegisterMods

void function TitanChip1_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("max_shield")
        mod.name = "Extra Shield"
        mod.abbreviation = "ExS"
        mod.description = "Max shields increased by 500."
        mod.shortdesc = "Max shields increased by 500."
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("armor_shield")
        mod.name = "Armor Shield"
        mod.abbreviation = "AS"
        mod.description = "Max shields increased by 7 per point in Armor, up to 700."
        mod.shortdesc = "Max shields increased based\non ARMOR."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("armor_2")
        mod.name = "Armor+2"
        mod.abbreviation = "A+2"
        mod.description = "+10 <cyan>Armor.</>"
        mod.shortdesc = "+10 <cyan>Armor."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("lifesteal")
        mod.name = "Shieldsteal"
        mod.abbreviation = "MS"
        mod.description = "Restore 20% of base damage dealt to enemies as shields."
        mod.shortdesc = "Restore base damage dealt to enemies as shields."
        mod.cost = 3
    }
    {
        // NOT IMPLEMENTED
        RoguelikeMod mod = NewMod("titan_long_range_resist")
        mod.name = "Anti-Bullshitinator"
        mod.abbreviation = "A-B"
        mod.description = "Reduce damage taken by 25% from faraway targets."
        mod.shortdesc = "Reduce damage taken from faraway targets."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("titan_brawler")
        mod.name = "Brawler"
        mod.abbreviation = "Bl"
        mod.description = "Reduce damage taken by 33% from close targets."
        mod.shortdesc = "Reduce damage taken from close targets."
        mod.cost = 1
    }
    // TODO: CONVERT TO PERMANENT UPGRADE?
    {
        RoguelikeMod mod = NewMod("battery_heals")
        mod.name = "Healing++"
        mod.abbreviation = "H++"
        mod.description = "Healing from batteries increased by 35%."
        mod.shortdesc = "Healing from batteries increased."
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