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
        mod.description = "<cyan>+10% Base Turret DMG.</>\n\nHitting an enemy with Laser Core will summon an <red>Orbital Strike."
        mod.shortdesc = "Laser Core can summon an <red>Orbital Strike."
        mod.cost = 3
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("pylon_charge")
        mod.name = "Pylon Combine"
        mod.abbreviation = "PyC"
        mod.description = "<cyan>+10% Base Turret DMG.</>\n\nInstead of 3 Pylons, spawn one <red>BIG</> pylon that fires <cyan>FIVE TIMES AS FAST.</>"
        mod.shortdesc = "Instead of 3 pylons, spawn one <red>BIG</> pylon instead."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("laser_disorder")
        mod.name = "Chargeback"
        mod.abbreviation = "Cb"
        mod.description = "<cyan>+15% Discharge application rate.</>\n\nGain up to 25% of your energy when you trigger a <charge>Discharge</> or a <red>Disorder.</>"
        mod.shortdesc = "Gain energy on Discharge."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("snakesplitter_energy")
        mod.name = "Snake-Ammo"
        mod.abbreviation = "SnA"
        mod.description = "<cyan>+10% Base Turret DMG.</>\n\nSnakesplitter <note>(hold ADS after reflecting projectiles with Vortex Shield/Firing Laser Shot)</> does <cyan>not consume ammo.</>"
        mod.shortdesc = "Snakesplitter grants <cyan>infinite ammo."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("discharge_battery")
        mod.name = "Disorder Battery"
        mod.abbreviation = "DBt"
        mod.description = "<cyan>+15% Discharge application rate.</>\n\nIf an enemy is killed by a <red>Disorder,</> <green>spawn an additional battery.</>"
        mod.shortdesc = "<red>Disorder</> kills <green>spawn an additional battery.</>"
        mod.cost = 2
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("discharge_crit")
        mod.name = "CritOrder"
        mod.abbreviation = "CO"
        mod.description = "<cyan>+15% Discharge application rate.</>\n\n<charge>Discharges</> and <red>Disorders</> ALWAYS critically hit."
        mod.shortdesc = "<charge>Discharges</> and <red>Disorders</> ALWAYS critically hit."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("energy_split")
        mod.name = "Energy Split"
        mod.abbreviation = "ES"
        mod.description = "<cyan>+10% Base Turret DMG.</>\n\nFor every 30 <cyan>Energy</> you have, Particle Accelerator's Alt Fire mode fires 1 additional projectile, up to 7 total projectiles. <red>-33% Base Particle Accelerator Damage</>"
        mod.shortdesc = "The Particle Accelerator's Alt Fire fires\nadditional projectiles."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("energy_conversion")
        mod.name = "Energy Conversion"
        mod.abbreviation = "EC"
        mod.description = "<cyan>+10% Base Turret DMG.</>\n\nThe <cyan>Energy</> stat increases your maximum Ion Energy."
        mod.shortdesc = "The <cyan>Energy</> stat increases maximum Ion Energy."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("repair_turret")
        mod.name = "Repair Turret"
        mod.abbreviation = "RT"
        mod.description = "<cyan>+10% Base Turret DMG.</>\n\nYour Turrets also <cyan>restore shields</> when you're near them. <note>(healing rate depends on fire rate.)</>"
        mod.shortdesc = "Turrets <cyan>restore shields</> when you're near them."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("laser_turret")
        mod.name = "Missile Turret"
        mod.abbreviation = "MT"
        mod.description = "<cyan>+10% Base Turret DMG.</>\n\nYour Turrets will <cyan>fire a missile barrage</> when you fire an Offensive ability."
        mod.shortdesc = "Turrets <cyan>fire missiles</> on\nOffensive usage."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("buff_turret")
        mod.name = "Buff Turret"
        mod.abbreviation = "BT"
        mod.description = "<cyan>+10% Base Turret DMG.</>\n\nYour Turrets will <cyan>grant you a +10% Crit Rate buff</> when you're near them."
        mod.shortdesc = "Turrets <cyan>grant Crit Rate</> when\nyou're near them."
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
    if (Roguelike_HasMod( player, "energy_conversion" ))
        base += 100 * Roguelike_GetStat( player, STAT_ENERGY ) // real.
    return base
}
#endif