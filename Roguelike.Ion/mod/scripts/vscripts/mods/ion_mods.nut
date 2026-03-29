global function Ion_RegisterMods
#if SERVER || CLIENT
global function Ion_GetMaxEnergy
#endif

global float DISCHARGE_SCALAR = 2
global float DISORDER_SCALAR_BONUS = 0.5

global const string ION_TURRET_DMG_TAG = "ion_turret_dmg"
global const string ION_DISCHARGE_RATE_TAG = "ion_discharge_rate"
void function Ion_RegisterMods()
{
    Roguelike_RegisterTag( ION_TURRET_DMG_TAG, "+10% Base Turret DMG." )
    Roguelike_RegisterTag( ION_DISCHARGE_RATE_TAG, "+15% Discharge application rate." )
    // +5% max energy
    // +15% base discharge damage
    {
        RoguelikeMod mod = NewMod("orbital_strike")
        mod.name = "From the Heavens"
        mod.abbreviation = "FrH"
        mod.description = "Hitting an enemy with Laser Core will summon an <red>Orbital Strike."
        mod.shortdesc = "Laser Core can summon an <red>Orbital Strike."
        mod.tags = [ION_TURRET_DMG_TAG]
        mod.cost = 3
        {
            HoverSimpleBox box
            box.currentValue = "2,000"
            box.label = "Base Damage Per Second"
            mod.boxes.append(box)
        }
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("pylon_charge")
        mod.name = "Pylon Combine"
        mod.abbreviation = "PyC"
        mod.description = "Instead of 3 Pylons, spawn one <red>BIG</> pylon that fires <cyan>FIVE TIMES AS FAST.</>"
        mod.shortdesc = "Instead of 3 pylons, spawn one <red>BIG</> pylon instead."
        mod.tags = [ION_TURRET_DMG_TAG]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("laser_disorder")
        mod.name = "Chargeback"
        mod.abbreviation = "Cb"
        mod.description = "Gain up to 25% of your energy when you trigger a <charge>Discharge</> or a <red>Disorder.</>"
        mod.shortdesc = "Gain energy on Discharge."
        mod.tags = [ION_DISCHARGE_RATE_TAG]
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("snakesplitter_energy")
        mod.name = "Snake-Ammo"
        mod.abbreviation = "SnA"
        mod.description = "Snakesplitter <note>(hold ADS after reflecting projectiles with Vortex Shield/Firing Laser Shot)</> does <cyan>not consume ammo.</>"
        mod.shortdesc = "Snakesplitter grants <cyan>infinite ammo."
        mod.tags = [ION_TURRET_DMG_TAG]
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("discharge_battery")
        mod.name = "Disorder Battery"
        mod.abbreviation = "DBt"
        mod.description = "If an enemy is killed by a <red>Disorder,</> <green>spawn an additional battery.</>"
        mod.shortdesc = "<red>Disorder</> kills <green>spawn an additional battery.</>"
        mod.tags = [ION_DISCHARGE_RATE_TAG]
        mod.cost = 2
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("discharge_crit")
        mod.name = "CritOrder"
        mod.abbreviation = "CO"
        mod.description = "<charge>Discharges</> and <red>Disorders</> ALWAYS critically hit."
        mod.shortdesc = "<charge>Discharges</> and <red>Disorders</> ALWAYS critically hit."
        mod.tags = [ION_DISCHARGE_RATE_TAG]
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("energy_split")
        mod.name = "Energy Split"
        mod.abbreviation = "ES"
        mod.description = "For every 10 <cyan>Ability Power</> you have, Particle Accelerator's Alt Fire mode fires 1 additional projectile, up to 7 total projectiles. <red>-33% Base Particle Accelerator Damage</>"
        mod.shortdesc = "The Particle Accelerator's Alt Fire fires\nadditional projectiles."
        mod.tags = [ION_TURRET_DMG_TAG]
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("energy_conversion")
        mod.name = "Energy Conversion"
        mod.abbreviation = "EC"
        mod.description = "The <cyan>Ability Duration</> stat increases your Ion Energy regeneration.\n\n<note>+1% Ability Duration = +1% Energy Regen.</>"
        mod.shortdesc = "The <cyan>Energy</> stat increases maximum Ion Energy."
        mod.tags = [ION_TURRET_DMG_TAG]
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("repair_turret")
        mod.name = "Repair Turret"
        mod.abbreviation = "RT"
        mod.description = "Your Turrets also <cyan>restore shields</> when you're near them. <note>(healing rate depends on fire rate.)</>"
        mod.shortdesc = "Turrets <cyan>restore shields</> when you're near them."
        mod.tags = [ION_TURRET_DMG_TAG]
        mod.abilityPowerValue = 500.0 / 39.34
        mod.abilityPowerScalar = 5.0 / 39.34
        mod.abilityPowerFormat = "%.1fm"
        mod.abilityPowerLabel = "Range"
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("laser_turret")
        mod.name = "Missile Turret"
        mod.abbreviation = "MT"
        mod.description = "Your Turrets will <cyan>fire a missile barrage</> when you fire an Offensive ability."
        mod.shortdesc = "Turrets <cyan>fire missiles</> on\nOffensive usage."
        mod.tags = [ION_TURRET_DMG_TAG]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("buff_turret")
        mod.name = "Buff Turret"
        mod.abbreviation = "BT"
        mod.description = "Your Turrets will <cyan>grant you a +10% Crit Rate buff</> when you're near them."
        mod.shortdesc = "Turrets <cyan>grant Crit Rate</> when\nyou're near them."
        mod.tags = [ION_TURRET_DMG_TAG]
        mod.abilityPowerValue = 500.0 / 39.34
        mod.abilityPowerScalar = 5.0 / 39.34
        mod.abilityPowerFormat = "%.1fm"
        mod.abilityPowerLabel = "Range"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("multi_turret")
        mod.name = "Multi Turret"
        mod.abbreviation = "MlT"
        mod.description = "Doubles the amount turrets you can deploy. <red>-40% Turret Base DMG."
        mod.shortdesc = "Doubles the amount turrets you can deploy.\n<red>-40% Turret Base DMG."
        mod.tags = [ION_DISCHARGE_RATE_TAG]
        mod.cost = 2
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = true
    mod.loadouts = [PRIMARY_ION]
    mod.chip = 3
    mod.isTitan = true

    return mod
}

#if SERVER || CLIENT
// HACK: Client always sets max energy to base
// we use this to fix the hud
int function Ion_GetMaxEnergy( entity player )
{
    int base = 10000
    //if (Roguelike_HasMod( player, "energy_conversion" ))
    //    base += int(10000 * Roguelike_GetStat( player, "ability_duration" )) // real.
    return base
}
#endif