global function PilotChip2_RegisterMods

void function PilotChip2_RegisterMods()
{

    {
        RoguelikeMod mod = NewMod("treasure_chests")
        mod.name = "Treasure Chests"
        mod.abbreviation = "TC"
        mod.description = "Gain 50$ when opening chests or shops for the first time."
        mod.shortdesc = "Gain 50$ when opening chests or shops."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("tactical_cd")
        mod.name = "Tacticool"
        mod.abbreviation = "Tc"
        mod.description = "Kills restore tactical energy."
        mod.shortdesc = "Kills restore tactical energy."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("ground_friction")
        mod.name = "Shiny Boots"
        mod.abbreviation = "SB"
        mod.description = "Ground friction reduced by ^40FFFF0030%^FFFFFFFF."
        mod.shortdesc = "Ground friction reduced by ^40FFFF0030%."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("wall_friction")
        mod.name = "Anti-friction Jumpkit"
        mod.abbreviation = "AFJ"
        mod.description = "Wall friction reduced by ^40FFFF0030%^FFFFFFFF."
        mod.shortdesc = "Wall friction reduced by ^40FFFF0030%."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("moonboots")
        mod.name = "Moonboots"
        mod.abbreviation = "Mb"
        mod.description = "Gravity reduced by ^40FFFF0020%."
        mod.shortdesc = "Gravity reduced by ^40FFFF0020%."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("bhopper")
        mod.name = "2Much4ZBlock"
        mod.abbreviation = "ZBl"
        mod.description = "+300% air acceleration."
        mod.shortdesc = "+300% air acceleration."
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("triplejump")
        mod.name = "Triple Jump"
        mod.abbreviation = "TJ"
        mod.description = "You can double jump twice."
        mod.shortdesc = "You can double jump twice."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("double_dash")
        mod.name = "Double Dash"
        mod.abbreviation = "DD"
        mod.description = "You can dash twice."
        mod.shortdesc = "You can dash twice."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("70kmh")
        mod.name = "Speed Is Cash"
        mod.abbreviation = "SIC"
        mod.description = "Going above 70kmh grants you 5$ per second!!!!\n\n<note>Tip: hit yourself with laser</>"
        mod.shortdesc = "Going fast grants you 5$ per second."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("morality")
        mod.name = "MRVN Robber"
        mod.abbreviation = "MRV"
        mod.description = "MRVN kills as a pilot reward triple the cash."
        mod.shortdesc = "MRVN kills as a pilot reward <cyan>triple the cash.</>"
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("dash_recovery")
        mod.name = "Dash Recovery"
        mod.abbreviation = "DaR"
        mod.description = "Dash cooldown reduced."
        mod.shortdesc = "Dash cooldown reduces."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("dash_on_kill")
        mod.name = "Killer Dash"
        mod.abbreviation = "KiD"
        mod.description = "Restore a dash on kill."
        mod.shortdesc = "Restore a dash on kill."
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
