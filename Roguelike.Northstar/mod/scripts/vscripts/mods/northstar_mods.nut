global function Northstar_RegisterMods

void function Northstar_RegisterMods()
{
    // +5% base railgun dmg
    // -10% charge time
    {
        RoguelikeMod mod = NewMod("cluster_core")
        mod.name = "Cluster Bananza"
        mod.abbreviation = "CB"
        mod.description = "<cyan>+5% Base Railgun DMG.</>\n\nFlight Core fires cluster rockets instead of normal ones. <note>These are not cluster rockets from your offensive, and wont trigger benefits related to it.</>"
        mod.shortdesc = "Flight Core fires cluster rockets."
        mod.cost = 3
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("big_finish")
        mod.name = "Big Finish"
        mod.abbreviation = "BF"
        mod.description = "<cyan>+5% Base Railgun DMG.</>\n\nIf you finish an enemy with a hit that deals over <cyan>3,000 damage</> - <green>spawn an additional battery.</>"
        mod.shortdesc = "Finals hits over 3K damage <green>spawn an additional\nbattery."
        mod.cost = 2
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("first_class_flight")
        mod.name = "First Class Flight"
        mod.abbreviation = "FCF"
        mod.description = "<cyan>-10% Railgun Charge Time.</>\n\nFlight Core extended by 25%. Use abilities and swap to your other loadout while in flight core."
        mod.shortdesc = "Use abilities and swap loadouts when in\nFlight Core."
        mod.cost = 1
        mod.loadouts = [PRIMARY_NORTHSTAR, PRIMARY_BRUTE]
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("railgun_hp")
        mod.name = "Bloodshot"
        mod.abbreviation = "Bs"
        mod.description = "<cyan>+5% Base Railgun DMG.</>\n\nRailgun deals up to <cyan>+30% damage</> relative to your <red>missing Health.</>"
        mod.shortdesc = "Railgun gains <cyan>+DMG%</> relative to your\n<red>missing Health."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("500kg")
        mod.name = "500kg Missile"
        mod.abbreviation = "500"
        mod.description = "Firing a Cluster Missile while Hovering will cause a <red>very large explosion.</>"
        mod.shortdesc = "Cluster Missiles fired while Hovering will\ncause a <red>big explosion."
        mod.cost = 3
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("crit_backup")
        mod.name = "No Skill Required"
        mod.abbreviation = "NSR"
        mod.description = "<cyan>-10% Railgun Charge Time.</>\n\nRailgun non-critical-hits may still convert to a crit randomly. <note>This uses your crit rate.</>"
        mod.shortdesc = "Railgun may still crit randomly if you miss\nthe weakspot."
        mod.cost = 1
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("hover_toggle")
        mod.name = "FlightSwitch"
        mod.abbreviation = "FS"
        mod.description = "<cyan>-10% Railgun Charge Time.</>\n\nToggle between hover and not-hover. While Hovering:<cyan> +25% Damage.</>"
        mod.shortdesc = "Toggle between hover and not-hover."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("crit_charge")
        mod.name = "CritCharge"
        mod.abbreviation = "CC"
        mod.description = "<cyan>+5% Base Railgun DMG.</>\n\nWhen Fully Charged Shots Crit: Your railgun instantly recharges."
        mod.shortdesc = "Railgun instantly recharges if a fully\ncharged shot crits."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("tether_crit")
        mod.name = "Inevitable Pain"
        mod.abbreviation = "IP"
        mod.description = "<cyan>+5% Base Railgun DMG.</>\n\nRailgun Hits against tethered enemies will <cyan>always be crits.</>"
        mod.shortdesc = "Railgun Hits against tethered enemies will\n<cyan>always be crits."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("railgun_trauma")
        mod.name = "Post-Railgun Trauma"
        mod.abbreviation = "PRT"
        mod.description = "<cyan>-10% Railgun Charge Time.</>\n\nFully charged Railgun shots <cyan>get +50% Projectile Speed,</> and leave the enemy <cyan>Traumatized,</> reducing their damage output by 50% and <cyan>increasing Crit DMG against them by 25%."
        mod.shortdesc = "Fully charged Railgun shots travel faster\nand <cyan>debuff enemies."
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("pierce_dmg")
        mod.name = "Penetration"
        mod.abbreviation = "PEN"
        mod.description = "<cyan>-10% Railgun Charge Time.</>\n\nThe railgun's base damage increases by 25% of your Max Shields."
        mod.shortdesc = "Railgun Base DMG increases relative\nto your Max Sheilds."
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("super_spread")
        mod.name = "No-Scoper"
        mod.abbreviation = "NSc"
        mod.description = "<cyan>+5% Base Railgun DMG.</>\n\nThe Railgun does not lose charge. <red>+400% Spread."
        mod.shortdesc = "Railgun No-Scopes keep charge.\n<red>+400% Spread."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = false
    mod.loadouts = [PRIMARY_NORTHSTAR]
    mod.isTitan = true

    return mod
}