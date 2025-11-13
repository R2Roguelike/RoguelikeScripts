global function TitanChip2_RegisterMods

void function TitanChip2_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("titan_holster")
        mod.name = "Weapon Holster"
        mod.abbreviation = "WH"
        mod.description = "Titan primary weapons regenerate ammo while unequipped.\n\n<note>Rate varies by mag size. If your mag size isnt above 100 or below 2, it takes 5 seconds to regenerate from 0 to full.</>"
        mod.shortdesc = "Titan primary weapons regenerate ammo while\nunequipped."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("tick_spawner")
        mod.name = "Tick-Tock O'Clock"
        mod.abbreviation = "TTO"
        mod.description = "Killing an enemy Titan or Reaper has a chance to spawn ticks."
        mod.shortdesc = "Killing an enemy Titan or Reaper will\nsometimes spawn ticks."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("titan_move_speed")
        mod.name = "Titan Leg Day"
        mod.abbreviation = "TLD"
        mod.description = "Base movement speed increased by 20%."
        mod.shortdesc = "Base movement speed increased."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("shock_bullets")
        mod.name = "Ricochet"
        mod.abbreviation = "Rc"
        mod.description = "On hitting a Titan: 20% chance to cause another Titan within 20m to take a hit for 30% of the damage."
        mod.shortdesc = "<daze>On hit:</> Sometimes, another Titan will <cyan>take a\nhit too."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("offensive_charge")
        mod.name = "Backup Plan"
        mod.abbreviation = "BP"
        mod.description = "All offensives gain 1 charge."
        mod.shortdesc = "All offensives gain 1 charge."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("puncture_crit_dmg")
        mod.name = "Crit Exchange"
        mod.abbreviation = "CE"
        mod.description = "<cyan>+100% Crit Rate.</> <red>The lower your original Crit Rate, the lower your Crit DMG.</>"
        mod.shortdesc = "<cyan>+100% Crit Rate.</>\n<red>Lower Crit Rate reduces Crit DMG.</>"
        mod.cost = 3
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("anti_shield")
        mod.name = "Shield Breaching Rounds"
        mod.abbreviation = "SBR"
        mod.description = "+400% DMG against non-combatants (e.g. Particle Walls, Laser Pylons, etc.). Weapon rounds drain Vortex Shields."
        mod.shortdesc = "+DMG% against non-combatants."
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 2
    mod.isTitan = true

    return mod
}