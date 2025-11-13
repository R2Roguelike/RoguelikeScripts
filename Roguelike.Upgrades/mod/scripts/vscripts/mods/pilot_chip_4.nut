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
        mod.description = "Damage dealt while cloaked is increased."
        mod.shortdesc = "Damage dealt while cloaked is increased."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("cloak_nades")
        mod.name = "Nades from the Dark"
        mod.abbreviation = "NfD"
        mod.description = "Grenades restore faster when cloaking."
        mod.shortdesc = "Grenades restore faster when cloaking."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("big_boom")
        mod.name = "Big Boom"
        mod.abbreviation = "BB"
        mod.description = "Grenade blast radius increased by <cyan>25%.</>"
        mod.shortdesc = "Grenade blast radius increased."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("cloak_infinite")
        mod.name = "Inexistence"
        mod.abbreviation = "Ie"
        mod.description = "<cyan>+150% Cloak duration...</> <red>but it ends when you take damage.</>"
        mod.shortdesc = "<cyan>+150% Cloak duration...</> <red>but it ends when you take damage."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("cloak_speed")
        mod.name = "SpeedCloak"
        mod.abbreviation = "SC"
        mod.description = "<cyan>+40%</> speed while in cloak."
        mod.shortdesc = "<cyan>+40%</> speed while in cloak."
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
        mod.name = "Explosive Start"
        mod.abbreviation = "ES"
        mod.description = "Throwing a grenade grants weapons that match it's <daze>damage type</> <cyan>+20% DMG.</>"
        mod.shortdesc = "<daze>On Grenade throw</>: Weapons of the <daze>same element</>\n<cyan>gain +DMG%."
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
