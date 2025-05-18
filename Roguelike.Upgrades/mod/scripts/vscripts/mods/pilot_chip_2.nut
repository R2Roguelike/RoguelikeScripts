global function PilotChip2_RegisterMods

void function PilotChip2_RegisterMods()
{

    {
        RoguelikeMod mod = NewMod("grenade_cd")
        mod.name = "Grenadier"
        mod.abbreviation = "Gd"
        mod.description = "Kills restore grenade energy."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("tactical_cd")
        mod.name = "Tacticool"
        mod.abbreviation = "Tc"
        mod.description = "Kills restore tactical energy."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("ground_friction")
        mod.name = "shiny boots"
        mod.abbreviation = "SB"
        mod.description = "Ground friction reduced by ^40FFFF0030%^FFFFFFFF."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("wall_friction")
        mod.name = "Anti-friction jumpkit"
        mod.abbreviation = "AFJ"
        mod.description = "Wall friction reduced by ^40FFFF0030%^FFFFFFFF."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("bhopper")
        mod.name = "2much4zblock"
        mod.abbreviation = "ZBl"
        mod.description = "+300% air acceleration."
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("triplejump")
        mod.name = "triple jump"
        mod.abbreviation = "TJ"
        mod.description = "You can double jump twice."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("double_dash")
        mod.name = "doubledash"
        mod.abbreviation = "DD"
        mod.description = "You can dash twice."
        mod.cost = 1
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 2
    mod.isTitan = false

    return mod
}
