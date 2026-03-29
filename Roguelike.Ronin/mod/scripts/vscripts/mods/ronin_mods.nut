global function Ronin_RegisterMods

global const string RONIN_CORE_GAIN_TAG = "ronin_core_gain"
global const string RONIN_DMG_RESIST_TAG = "ronin_dmg_resist"
void function Ronin_RegisterMods()
{
    Roguelike_RegisterTag( RONIN_CORE_GAIN_TAG, "+15% Core Gain." )
    Roguelike_RegisterTag( RONIN_DMG_RESIST_TAG, "+15% DMG Resist." )
    {
        RoguelikeMod mod = NewMod("ronin_dash_melee")
        mod.name = "Dash-Attack"
        mod.abbreviation = "DA"
        mod.description = "Timing your dash with your sword hit <cyan>gurantees a critical hit.</>"
        mod.shortdesc = "Sword Dash-Attacks <cyan>ALWAYS crit."
        mod.tags = [RONIN_CORE_GAIN_TAG]
        mod.statModifiers = [NewStatModifier("core_gain", 0.15)]
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("reflective_sword")
        mod.name = "Reflective Sword"
        mod.abbreviation = "RS"
        mod.description = "Sword block blocks <green>100%</> damage.\nBlocked damage <cyan>grants up to +35% DMG.</>\nSword block <red>no longer blocks ANY damage</> while at max charge."
        mod.shortdesc = "Sword block blocks all DMG and grants a buff.\n<red>But it has a cooldown."
        mod.tags = [RONIN_CORE_GAIN_TAG]
        mod.statModifiers = [NewStatModifier("core_gain", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        // NOT IMPLEMENTED
        RoguelikeMod mod = NewMod("perfect_sword")
        mod.name = "Perfect Technique"
        mod.abbreviation = "PT"
        mod.description = "If Sword block blocks damage <daze>during it's first 0.35s of usage,</> you are <cyan>invulnerable for the duration of the sword block,</> and <daze>reflect projectiles.</>"
        mod.shortdesc = "Timing Sword Block grants <cyan>invulnerability\nand projectile reflection."
        mod.tags = [RONIN_DMG_RESIST_TAG]
        mod.statModifiers = [NewStatModifier("dmg_taken", 0.17647)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        // NOT IMPLEMENTED
        RoguelikeMod mod = NewMod("quickswap")
        mod.name = "Quickswap"
        mod.abbreviation = "Qs"
        mod.description = "Firing your shotgun right after switching to it deals<red> +50% damage.</>"
        mod.shortdesc = "Shotgun Swaps grant <cyan>+DMG%."
        mod.tags = [RONIN_DMG_RESIST_TAG]
        mod.statModifiers = [NewStatModifier("dmg_taken", 0.17647)]
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("offensive_daze_hits")
        mod.name = "Conductive Sword"
        mod.abbreviation = "CS"
        mod.description = "Sword hits while the target has <daze>Daze</> charge your offensives and deal <cyan>+50% DMG."
        mod.shortdesc = "Sword hits against Dazed targets have\nincreased DMG and charge your offensives."
        mod.tags = [RONIN_DMG_RESIST_TAG]
        mod.statModifiers = [NewStatModifier("dmg_taken", 0.17647)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("overcharged_arc_wave")
        mod.name = "Overcharged Waves"
        mod.abbreviation = "OW"
        mod.description = "Arc Wave and Phase Dash recharge rapidly when using Sword Core."
        mod.shortdesc = "Arc Wave and Phase Dash recharge rapidly\nwhen using Sword Core."
        mod.tags = [RONIN_CORE_GAIN_TAG]
        mod.statModifiers = [NewStatModifier("core_gain", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("conduction")
        mod.name = "Conduction"
        mod.abbreviation = "Cd"
        mod.description = "Arc Wave hits restore Dash Energy. Dashing restores Arc Wave cooldown."
        mod.shortdesc = "Arc Wave and Dashing restore cooldowns for\neach other."
        mod.tags = [RONIN_DMG_RESIST_TAG]
        mod.statModifiers = [NewStatModifier("dmg_taken", 0.17647)]
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("sword_core_use")
        mod.name = "Unrelenting Sword"
        mod.abbreviation = "US"
        mod.description = "Less Sword Core duration is consumed while swinging your sword."
        mod.shortdesc = "Less Sword Core duration is consumed while\nswinging your sword."
        mod.tags = [RONIN_CORE_GAIN_TAG]
        mod.statModifiers = [NewStatModifier("core_gain", 0.15)]
        {
            HoverSimpleBox box
            box.icon = $"ui/cooldown"
            box.initialValue = "3s"
            box.currentValue = "2s"
            box.label = "Duration Consumption"
            mod.boxes.append(box)
        }
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("overdaze")
        mod.name = "Overdaze"
        mod.abbreviation = "Od"
        mod.description = "<overload>Overload</> stacks no longer have a cap. Sword Core may consume <overload>Overload</> stacks for +50% DMG."
        mod.shortdesc = "<overload>Overload</> stacks no longer have a cap.\nSword Core consumes <overload>Overload stacks."
        mod.tags = [RONIN_CORE_GAIN_TAG]
        mod.statModifiers = [NewStatModifier("core_gain", 0.15)]
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("executioner_meal")
        mod.name = "Executioners Meal"
        mod.abbreviation = "EM"
        mod.description = "Enemies finished off with a <cyan>sword hit</> <green>spawn an additional battery.</>"
        mod.shortdesc = "Sword kills <green>spawn an additional battery."
        mod.tags = [RONIN_DMG_RESIST_TAG]
        mod.statModifiers = [NewStatModifier("dmg_taken", 0.17647)]
        mod.cost = 3
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("offensive_overload")
        mod.name = "Daze to All"
        mod.abbreviation = "DtA"
        mod.description = "When dealing damage with any offensive ability - the target is inflicted <daze>Daze.</> This can trigger every 10s."
        mod.shortdesc = "Damage with any offensive ability inflicts Daze."
        mod.tags = [RONIN_CORE_GAIN_TAG]
        mod.statModifiers = [NewStatModifier("core_gain", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("daze_dmg")
        mod.name = "Dazed and Slayed"
        mod.abbreviation = "DaS"
        mod.description = "Dazed enemies take <cyan>+35% DMG</> from all sources."
        mod.shortdesc = "Dazed enemies take <cyan>+DMG%</> from all sources."
        mod.tags = [RONIN_CORE_GAIN_TAG]
        mod.statModifiers = [NewStatModifier("core_gain", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("phase_ammo")
        mod.name = "Phase Ammo"
        mod.abbreviation = "PA"
        mod.description = "Phase Dash reloads all weapons, and grants <overload>2 Overload charges."
        mod.shortdesc = "Phase Dash grants <overload>2 Overload charges."
        mod.tags = [RONIN_DMG_RESIST_TAG]
        mod.statModifiers = [NewStatModifier("dmg_taken", 0.17647)]
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("love_diviiiiiiiiiiiiiiiiiiiiiiiiiiiides")
        mod.name = "Oath of the Sword"
        mod.abbreviation = "OtS"
        mod.description = "60% damage resistance while in Sword Core."
        mod.shortdesc = "Gain DMG Resist while in Sword Core."
        mod.tags = [RONIN_CORE_GAIN_TAG]
        mod.statModifiers = [NewStatModifier("core_gain", 0.15)]
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = true
    mod.loadouts = [PRIMARY_RONIN]
    mod.chip = 3
    mod.isTitan = true

    return mod
}