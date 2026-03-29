global function PilotChip4_RegisterMods

void function PilotChip4_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("uninterruptable_cloak")
        mod.name = "Stealth++"
        mod.abbreviation = "S++"
        mod.description = "<cyan>Cloak isn't interrupted from weapon fire.</> <red>-50% Cloak duration."
        mod.shortdesc = "<cyan>Cloak isn't interrupted from weapon fire.</>\n<red>-50% Cloak duration."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("cloak_damage")
        mod.name = "Backstab"
        mod.abbreviation = "Bk"
        mod.description = "Damage dealt while cloaked is <cyan>increased."
        mod.shortdesc = "Damage dealt while cloaked is <cyan>increased."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("cloak_nades")
        mod.name = "Nades from the Dark"
        mod.abbreviation = "NfD"
        mod.description = "Grenades <cyan>restore faster</> when your Tactical is active."
        mod.shortdesc = "Grenades <cyan>restore faster</> when cloaking."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("ender_pearl")
        mod.name = "Ender Pearls"
        mod.abbreviation = "EP"
        mod.description = "Ordnances teleport you to them when they expire.\n" + 
        "<note>Firestars teleport when they end. All other grenades teleport when they detonate." +
        " <red>Grenades must hit a valid surface to teleport." +
        "\n\n<note>You may get crushed, softlocked, and/or end up in very weird situations. I take no responsibility!"
        mod.shortdesc = "Grenades teleport you to\nthem when they expire."
        mod.doNotUnlock = true // secret mod
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("big_boom")
        mod.name = "Big Boom"
        mod.abbreviation = "BB"
        mod.description = "Grenade blast radius increased by <cyan>25%.</>"
        mod.shortdesc = "Grenade blast radius <cyan>increased."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("cloak_infinite")
        mod.name = "Inexistence"
        mod.abbreviation = "Ie"
        mod.description = "<cyan>+150% Tactical duration...</> <red>but tacticals end when you take damage.</>"
        mod.shortdesc = "<cyan>+150% Tactical duration...</>\n<red>but tacticals end when you take damage."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("cloak_speed")
        mod.name = "SpeedCloak"
        mod.abbreviation = "SC"
        mod.description = "<cyan>+40%</> speed while in cloak."
        mod.shortdesc = "<daze>While cloaking:</> <cyan>+40%</> speed."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("pain_to_gain")
        mod.name = "Pain to Gain"
        mod.abbreviation = "PtG"
        mod.description = "Damage that matches your Grenade's damage type <cyan>restores grenade cooldown.</>"
        mod.shortdesc = "<daze>On hit</>: Restore cooldown for Grenades of the\n<cyan>same element."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("explosive_start")
        mod.name = "Explosive Beginning"
        mod.abbreviation = "EB"
        mod.description = "Throwing a grenade grants weapons that match it's <daze>damage type</> <cyan>+30% DMG.</>"
        mod.shortdesc = "<daze>On Grenade throw</>: Weapons of the <daze>same element</>\n<cyan>gain +DMG%."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("explosive_end")
        mod.name = "Explosive End"
        mod.abbreviation = "EE"
        mod.description = "<daze>On hit:</> Gain <cyan>+1% Grenade DMG.</> Stacks. All stacks end 1s after the next grenade hit."
        mod.shortdesc = "<daze>On hit:</> Gain Grenade DMG.\nEnds 1s after the next grenade hit."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("multi_star")
        mod.name = "MultiStar"
        mod.abbreviation = "MS"
        mod.description = "Throw 3 stars at once for each use of <daze>Gravity or Fire Star."
        mod.shortdesc = "Throw 3 stars at once for each use of\n<daze>Gravity Star or Fire Star."
        mod.cost = 2
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 4
    mod.isTitan = false

    return mod
}
