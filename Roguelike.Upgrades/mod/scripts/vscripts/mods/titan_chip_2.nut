global function TitanChip2_RegisterMods

global const string EXTRA_OFFENSIVE_CHARGE = "offensive_charge"
void function TitanChip2_RegisterMods()
{
    Roguelike_RegisterTag( EXTRA_OFFENSIVE_CHARGE, "+1 Charge for all Offensives." )
    {
        RoguelikeMod mod = NewMod("titan_holster")
        mod.name = "Weapon Holster"
        mod.abbreviation = "WH"
        mod.description = "Titan primary weapons regenerate ammo while unequipped."
        mod.shortdesc = "Titan primary weapons regenerate ammo while\nunequipped."
        {
            HoverSimpleBox box
            box.currentValue = "20%"
            box.label = "Mag Regen/sec"
            mod.boxes.append(box)
        }
        {
            HoverSimpleBox box
            box.currentValue = "0.3"
            box.label = "Min Bullets/sec"
            box.newRow = false
            mod.boxes.append(box)
        }
        {
            HoverSimpleBox box
            box.currentValue = "20"
            box.label = "Max Bullets/sec"
            box.newRow = false
            mod.boxes.append(box)
        }
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("tick_spawner")
        mod.name = "Tick-Tock O'Clock"
        mod.abbreviation = "TTO"
        mod.description = "Killing an enemy Titan or Reaper spawns ticks.\n\n<note>These ticks deal heavily increased damage to enemies and are invulnerable to enemy projectiles.</>"
        mod.shortdesc = "Killing an enemy Titan or Reaper spawns ticks."
        {
            HoverSimpleBox box
            box.currentValue = "5"
            box.label = "Ticks/Titan"
            mod.boxes.append(box)
        }
        {
            HoverSimpleBox box
            box.currentValue = "3"
            box.label = "Ticks/Reaper"
            box.newRow = false
            mod.boxes.append(box)
        }
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
        mod.description = "<daze>On hitting a Titan</>: <cyan>20% chance</> to cause another Titan within 20m to take a hit for <cyan>30% of the damage."
        mod.shortdesc = "<daze>On hit:</> Sometimes, another Titan will <cyan>take a\nhit too."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("offensive_charge")
        mod.name = "Offensive Theft"
        mod.abbreviation = "OT"
        mod.description = "Titan Kills restore an offensive charge for both loadouts."
        mod.shortdesc = "<cyan>+1 Charge for all offensives.\n</>Kills restore offensive charges."
        mod.tags = [EXTRA_OFFENSIVE_CHARGE]
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