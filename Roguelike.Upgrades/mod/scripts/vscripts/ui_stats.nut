global function RoguelikeStats_Init
global function Roguelike_FormatStatValue

void function RoguelikeStats_Init()
{
    // note:
    // 
    {
        RoguelikeStat stat = NewStat("header_fvdsvas")
        stat.name = "Damage"
        stat.isTitan = true
        stat.isHeader = true
    }
    {
        RoguelikeStat stat = NewStat("crit_rate")
        stat.name = "Crit Rate"
        stat.description = "The <daze>base chance</> of you getting a <cyan>Critical Hit</>, dealing <red>increased damage."
        stat.baseValue = 0.048
        stat.chipValue = 0.048
        stat.isTitan = true
        stat.isPercentage = true
    }
    {
        RoguelikeStat stat = NewStat("crit_dmg")
        stat.name = "Crit DMG"
        stat.description = "The <red>damage increase</> of a <cyan>Critical Hit.\n\nMultiplicative</> with other bonus damage sources."
        stat.baseValue = 0.48
        stat.chipValue = 0.096
        stat.isTitan = true
        stat.isPercentage = true
    }
    {
        RoguelikeStat stat = NewStat("header_fsadvas")
        stat.name = "Defense"
        stat.isTitan = true
        stat.isHeader = true
    }
    {
        RoguelikeStat stat = NewStat("dmg_taken")
        stat.name = "DMG Resist"
        stat.baseValue = 0.0
        stat.chipValue = 0.04545454545454545 // 12% @ 2 energy
        stat.isTitan = true
        stat.isPercentage = true
        stat.diminishingReturns = true
    }
    {
        RoguelikeStat stat = NewStat("max_shields")
        stat.name = "Max Shields"
        stat.baseValue = 1000.0
        stat.chipValue = 50.0
        stat.isTitan = true
        stat.isPercentage = false
    }
    {
        RoguelikeStat stat = NewStat("battery_healing")
        stat.name = "Battery Healing"
        stat.description = "The amount of <cyan>health</> that you get from a <daze>single <green>Battery."
        stat.baseValue = 800.0
        stat.chipValue = 40.0
        stat.isTitan = true
        stat.isPercentage = false
    }
    {
        RoguelikeStat stat = NewStat("header_fadvdsvas")
        stat.name = "Abilities"
        stat.isTitan = true
        stat.isHeader = true
    }
    {
        RoguelikeStat stat = NewStat("cd_reduction")
        stat.name = "CD Reduction"
        stat.baseValue = 0.0
        stat.chipValue = 0.04545454545454545 // 12% @ 2 energy
        stat.isTitan = true
        stat.isPercentage = true
        stat.diminishingReturns = true
    }
    {
        RoguelikeStat stat = NewStat("ability_duration")
        stat.name = "Ability Duration"
        stat.baseValue = 0.0
        stat.chipValue = 0.072
        stat.isTitan = true
        stat.isPercentage = true
    }
    {
        RoguelikeStat stat = NewStat("ability_power")
        stat.name = "<burn>Ability Power"
        stat.description = "Increases the <burn>power,</> and sometimes <burn>range,</> of <cyan>loadouts and some of their Status Effects." +
                           "\n\n<note>Sometimes may even affect Mods." 
        stat.baseValue = 0.0
        stat.chipValue = 4
        stat.isTitan = true
        stat.isPercentage = false
    }
    {
        RoguelikeStat stat = NewStat("core_gain")
        stat.name = "Core Gain"
        stat.description = "Increases the Core charge you gain from all sources."
        stat.baseValue = 0.0
        stat.chipValue = 0.05
        stat.isTitan = true
        stat.isPercentage = true
    }
    {
        RoguelikeStat stat = NewStat("header_adfvdsvas")
        stat.name = "Weapons"
        stat.isTitan = true
        stat.isHeader = true
    }
    {
        RoguelikeStat stat = NewStat("reload_speed_titan")
        stat.name = "Reload Speed"
        stat.baseValue = 0.0
        stat.chipValue = 0.032
        stat.isTitan = true
        stat.isPercentage = true
    }
    {
        RoguelikeStat stat = NewStat("fire_rate_titan")
        stat.name = "Fire Rate"
        stat.baseValue = 0.0
        stat.chipValue = 0.072
        stat.isTitan = true
        stat.isPercentage = true
    }
    {
        RoguelikeStat stat = NewStat("mag_size_titan")
        stat.name = "Mag Size"
        stat.baseValue = 0.0
        stat.chipValue = 0.048
        stat.isTitan = true
        stat.isPercentage = true
    }

    // PILOT

    {
        RoguelikeStat stat = NewStat("header_pilot_fvdsvas")
        stat.name = "Defense"
        stat.isTitan = false
        stat.isHeader = true
    }
    {
        RoguelikeStat stat = NewStat("max_hp")
        stat.name = "Max HP"
        stat.baseValue = 0.0
        stat.chipValue = 0.08
        stat.isTitan = false
        stat.isPercentage = true
    }
    {
        RoguelikeStat stat = NewStat("self_dmg")
        stat.name = "Self DMG Resist"
        stat.baseValue = 0.0
        stat.chipValue = 0.083333333
        stat.isTitan = false
        stat.isPercentage = true
        stat.diminishingReturns = true
    }
    {
        RoguelikeStat stat = NewStat("regen_rate")
        stat.name = "Regeneration Rate"
        stat.baseValue = 0.0
        stat.chipValue = 0.1
        stat.isTitan = false
        stat.isPercentage = true
        stat.diminishingReturns = false
    }
    {
        RoguelikeStat stat = NewStat("regen_delay")
        stat.name = "Regeneration Delay"
        stat.baseValue = 0.0
        stat.chipValue = 0.083333333
        stat.isTitan = false
        stat.isPercentage = true
        stat.diminishingReturns = true
    }
    {
        RoguelikeStat stat = NewStat("header_pilot_fvdsadsvas")
        stat.name = "Abilities"
        stat.isTitan = false
        stat.isHeader = true
    }
    {
        RoguelikeStat stat = NewStat("grenade_dmg")
        stat.name = "Grenade DMG Bonus"
        stat.baseValue = 0.0
        stat.chipValue = 0.06
        stat.isTitan = false
        stat.isPercentage = true
    }
    {
        RoguelikeStat stat = NewStat("grenade_cd")
        stat.name = "Grenade CD"
        stat.baseValue = 0.0
        stat.chipValue = 0.083333333
        stat.isTitan = false
        stat.isPercentage = true
        stat.diminishingReturns = true
    }
    {
        RoguelikeStat stat = NewStat("tactical_cd")
        stat.name = "Tactical CD"
        stat.baseValue = 0.0
        stat.chipValue = 0.083333333
        stat.isTitan = false
        stat.isPercentage = true
        stat.diminishingReturns = true
    }
    {
        RoguelikeStat stat = NewStat("cloak_duration")
        stat.name = "Cloak Duration"
        stat.baseValue = 0.0
        stat.chipValue = 0.06
        stat.isTitan = false
        stat.isPercentage = true
    }
    {
        RoguelikeStat stat = NewStat("header_pilot_fgbfb")
        stat.name = "Weapons"
        stat.isTitan = false
        stat.isHeader = true
    }
    {
        RoguelikeStat stat = NewStat("reload_speed")
        stat.name = "Reload Speed"
        stat.baseValue = 0.0
        stat.chipValue = 0.06
        stat.isTitan = false
        stat.isPercentage = true
    }
    {
        RoguelikeStat stat = NewStat("mag_size")
        stat.name = "Magazine Size"
        stat.baseValue = 0.0
        stat.chipValue = 0.06
        stat.isTitan = false
        stat.isPercentage = true
    }
    {
        RoguelikeStat stat = NewStat("header_pilot_fasdgbfb")
        stat.name = "Movement"
        stat.isTitan = false
        stat.isHeader = true
    }
    {
        RoguelikeStat stat = NewStat("move_speed")
        stat.name = "Movement Speed"
        stat.baseValue = 0.0
        stat.chipValue = 0.02
        stat.isTitan = false
        stat.isPercentage = true
    }
    {
        RoguelikeStat stat = NewStat("air_accel")
        stat.name = "Air Acceleration"
        stat.baseValue = 0.0
        stat.chipValue = 0.06
        stat.isTitan = false
        stat.isPercentage = true
    }
    {
        RoguelikeStat stat = NewStat("friction")
        stat.name = "Friction Reduction"
        stat.baseValue = 0.0
        stat.chipValue = 0.083333333333
        stat.isTitan = false
        stat.isPercentage = true
        stat.diminishingReturns = true
    }
}

string function Roguelike_FormatStatValue( RoguelikeStat stat, float value )
{
    if (value < 0 && stat.diminishingReturns)
        value -= 0.01
    string result = string(RoundToNearestInt(value))
    if (stat.isPercentage)
    {
        if (stat.diminishingReturns)
            result = format("%.1f%%", (100.0 - 100.0 / (1.0 + value * 1.0)))
        else
            result = format("%.1f%%", value * 100.0)
    }
    return result
}

RoguelikeStat function NewStat(string uniqueName)
{
    RoguelikeStat mod = Roguelike_NewStat(uniqueName)

    return mod
}
