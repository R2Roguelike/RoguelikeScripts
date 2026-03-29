global function TitanChip3_RegisterMods

void function TitanChip3_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("bonus_mag")
        mod.name = "Ammo++"
        mod.abbreviation = "A++"
        mod.description = "Mag size increased for all weapons."
        mod.shortdesc = "Mag size increased for all weapons."
        int value = 50
        mod.statModifiers = [NewStatModifier("mag_size_titan", value / 100.0)]
        {
            HoverSimpleBox box
            box.currentValue = "+" + value + "%"
            box.label = "Mag Size"
            mod.boxes.append(box)
        }
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("weapon_crit")
        mod.name = "Overcrit"
        mod.abbreviation = "Oc"
        mod.description = "On hit, increase Crit Rate by 1% for 3s. Stacks infinitely, <red>BUT</> stacks do not refresh."
        mod.shortdesc = "Hits increase <cyan>Crit Rate</> temporarily."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("weapon_crit_cd")
        mod.name = "Crit Gurantee"
        mod.abbreviation = "CG"
        mod.description = "If an enemy has not taken damage for 1s, the next hit is a guranteed Crit."
        mod.shortdesc = "<cyan>Gurantees a Crit</> if an enemy\nhas not taken damage for 1 second."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("weapon_load")
        mod.name = "Fast Loader"
        mod.abbreviation = "FL"
        mod.description = "Reload Speed increased."
        mod.shortdesc = "Reload Speed increased."
        int value = 36
        mod.statModifiers = [NewStatModifier("reload_speed_titan", value / 100.0)]
        {
            HoverSimpleBox box
            box.currentValue = "+" + value + "%"
            box.label = "Reload Speed"
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