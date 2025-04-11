global function TitanChip2_RegisterMods

void function TitanChip2_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("titan_holster")
        mod.name = "Weapon Holster"
        mod.description = "Titan primary weapons regenerate ammo while unequipped."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("tick_spawner")
        mod.name = "Tick-Tock O'Clock"
        mod.description = "Killing an enemy Titan or Reaper has a chance to spawn ticks."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("titan_move_speed")
        mod.name = "Overclock (Legs)"
        mod.description = "Base movement speed increased by 20%."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("shock_bullets")
        mod.name = "Ricochet"
        mod.description = "On hitting a Titan: 20% chance to cause another Titan within 20m to take a hit for 30% of the damage."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("offensive_charge")
        mod.name = "Backup Plan"
        mod.description = "All offensives gain 1 charge."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("puncture_crit_dmg")
        mod.name = "Crit Exchange"
        mod.description = "Excess Crit Rate is <cyan>converted into Crit DMG</> at a 2:1 ratio."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
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