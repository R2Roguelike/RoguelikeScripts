global function Legion_RegisterMods

void function Legion_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("mag_dump")
        mod.name = "Mag Dump"
        mod.description = "<cyan>+20 Mag Size.</> Power Shot <red>depletes 50% of ammo left</>, but <cyan>gains +20% damage bonus. This increases for each bullet in the mag.</>"
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("stat_belt")
        mod.name = "Stats to Bullets"
        mod.description = "<cyan>+1 Power Shot charge.</> Gain mag size from investing in the <cyan>Energy</> stat."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("focus_crystal")
        mod.name = "Focus Crystal"
        mod.description = "<cyan>+20 mag size.</>\n\n<daze>Close Range Mode</>: deal 15% bonus damage to enemies within 15m.\n" +
        "<red>Long Range Mode</>: deal 25% more crit damage."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("swap_load")
        mod.name = "swapload"
        mod.description = "<cyan>+1 power shot charge.</> <cyan>On Ammo Swap</>: if you have less than 20 bullets left, <cyan>restore ammo to full</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("shotgun_mode")
        mod.name = "Predator Mode: Shotgun"
        mod.description = "<cyan>+1 Power Shot Charge.</>\n\n<daze>Close Range Mode's Primary Fire</> transforms into an automatic shotgun. <red>Consumes 6 ammo per shot.</>"
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("marksman_mode")
        mod.name = "Predator Mode: Marksman"
        mod.description = "<cyan>+1 Power Shot Charge.</>\n\n<red>Long Range Mode's Primary Fire</> fires 10 bullets at once, as one big bullet. <red>Consumes 10 ammo per shot.</>"
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("ready_up")
        mod.name = "Lightweight Alloys"
        mod.description = "<cyan>+20 mag size.</>\n\nPredator Cannon: Move faster while in ADS. Enter ADS much quicker."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("consumption")
        mod.name = "Bullet Overload"
        mod.description = "<cyan>+20 mag size.</>\n\nPredator Cannon: +100% bullet consumption, +25% damage."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("power_back")
        mod.name = "Physics Power"
        mod.description = "<cyan>+1 power shot charge.</>\n\nIf Close Range Power Shot hits no enemies, it knocks you back and 50% of the cooldown is restored."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = false
    mod.loadouts = [PRIMARY_LEGION]
    mod.isTitan = true
    
    return mod
}