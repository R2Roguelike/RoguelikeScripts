global function Northstar_RegisterMods

void function Northstar_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("cluster_core")
        mod.name = "Cluster Bananza"
        mod.abbreviation = "CB"
        mod.description = "Flight Core has a 33% chance to fire a cluster rocket instead of a normal one. <note>These are not cluster rockets from your offensive, and wont trigger benefits related to it.</>"
        mod.cost = 3
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("big_finish")
        mod.name = "Big Finish"
        mod.abbreviation = "BF"
        mod.description = "If you finish an enemy with a hit that deals over <cyan>3,000 damage</> - <green>spawn an additional battery</>."
        mod.cost = 2
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("first_class_flight")
        mod.name = "First Class Flight"
        mod.abbreviation = "FCF"
        mod.description = "Flight Core extended by 25%. Use abilities and swap to your other loadout while in flight core."
        mod.cost = 1
        mod.loadouts = [PRIMARY_NORTHSTAR, PRIMARY_BRUTE]
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("railgun_hp")
        mod.name = "Bloodshot"
        mod.abbreviation = "Bs"
        mod.description = "Railgun deals up to <cyan>+30% damage</> relative to your <red>missing Health</>."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("500kg")
        mod.name = "500kg missile"
        mod.abbreviation = "500"
        mod.description = "Firing a Cluster Missile while Hovering will cause a <red>very large explosion</>."
        mod.cost = 3
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("crit_backup")
        mod.name = "no skill required"
        mod.abbreviation = "NSR"
        mod.description = "Railgun non-critical-hits may still convert to a crit randomly. <note>This uses your crit rate.</>"
        mod.cost = 1
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("hover_toggle")
        mod.name = "FlightSwitch"
        mod.abbreviation = "FS"
        mod.description = "Toggle between hover and not-hover. While Hovering:<cyan> +25% Damage</>."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("crit_charge")
        mod.name = "CritCharge"
        mod.abbreviation = "CC"
        mod.description = "When Fully Charged Shots Crit: Your railgun instantly recharges."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("tether_crit")
        mod.name = "Inevitable Pain"
        mod.abbreviation = "IP"
        mod.description = "Railgun Hits against tethered enemies will <cyan>always be crits</>."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("railgun_trauma")
        mod.name = "Post-Railgun Trauma"
        mod.abbreviation = "PRT"
        mod.description = "Fully charged Railgun shots <cyan>get +50% Projectile Speed</>, and leave the enemy <cyan>Traumatized</>, reducing their damage output by 50%."
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("pierce_dmg")
        mod.name = "Penetration"
        mod.abbreviation = "PEN"
        mod.description = "."
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
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