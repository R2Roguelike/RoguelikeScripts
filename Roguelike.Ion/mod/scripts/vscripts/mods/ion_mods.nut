global function Ion_RegisterMods
#if SERVER || CLIENT
global function Ion_GetMaxEnergy
#endif

global float DISCHARGE_SCALAR = 2
global float DISORDER_SCALAR_BONUS = 0.5

void function Ion_RegisterMods()
{
    // +5% max energy
    // +15% base discharge damage
    {
        RoguelikeMod mod = NewMod("orbital_strike")
        mod.name = "From the Heavens"
        mod.abbreviation = "FrH"
        mod.description = "<cyan>+10% max energy.</>\n\n<cyan>Discharging</> an enemy with Laser Core will summon an <red>Orbital Strike</>."
        mod.cost = 3
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("pylon_charge")
        mod.name = "Imbued Pylons"
        mod.abbreviation = "ImP"
        mod.description = "<cyan>+10% max energy.</>\n\nPylons will always trigger discharge. <red>+200% Pylon cooldown</>."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("laser_disorder")
        mod.name = "Chargeback"
        mod.abbreviation = "Cb"
        mod.description = "<cyan>+10% base Discharge DMG.</>\n\nLaser Shot's energy is refunded if it triggers a discharge."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("snakesplitter_energy")
        mod.name = "Snake-Saver"
        mod.abbreviation = "SnS"
        mod.description = "<cyan>+10% max energy.</>\n\nSnakesplitter <note>(hold ADS after reflecting projectiles with Vortex Shield/Firing Laser Shot)</> consumes 33% less energy."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("discharge_battery")
        mod.name = "Disorder Battery"
        mod.abbreviation = "DB"
        mod.description = "<cyan>+10% base Discharge DMG.</>\n\nIf an enemy is killed by a <red>Disorder</>, <green>spawn an additional battery</>."
        mod.cost = 2
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("discharge_crit")
        mod.name = "CritOrder"
        mod.abbreviation = "CO"
        mod.description = "<cyan>+10% base Discharge DMG.</>\n\n<charge>Discharges</> and <red>Disorders</> can critically hit."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("energy_split")
        mod.name = "Energy Split"
        mod.abbreviation = "ES"
        mod.description = "<cyan>+10% Max Energy.</>\n\nFor every 30 <cyan>Energy</> you have, Particle Accelerator's Alt Fire mode fires 1 additional projectile, up to 7 total projectiles. <red>-33% Base Particle Accelerator Damage</>"
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("energy_conversion")
        mod.name = "Energy Conversion"
        mod.abbreviation = "EC"
        mod.description = "<cyan>+10% Max Energy.</>\n\n<cyan>Energy</> increases your Energy generation rate."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = false
    mod.loadouts = [PRIMARY_ION]
    mod.isTitan = true

    return mod
}

#if SERVER || CLIENT
// HACK: Client always sets max energy to base
// we use this to fix the hud
int function Ion_GetMaxEnergy( entity player )
{
    int base = 10000
    array<string> mods = ["pylon_charge", "orbital_strike", "snakesplitter_energy", "energy_split"]
    foreach (string mod in mods)
    {
        if (Roguelike_HasMod( player, mod ))
            base += 1000
    }
    return base
}
#endif