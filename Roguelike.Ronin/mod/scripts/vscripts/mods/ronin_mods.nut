global function Ronin_RegisterMods

void function Ronin_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("ronin_dash_melee")
        mod.name = "Dash-Attack"
        mod.abbreviation = "DA"
        mod.description = "Timing your dash with your sword hit <cyan>gurantees a critical hit</>."
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("reflective_sword")
        mod.name = "Reflective Sword"
        mod.abbreviation = "RS"
        mod.description = "Sword block blocks <green>100%</> damage.\nBlocked damage <cyan>grants up to +35% DMG</>.\nSword block <red>no longer blocks ANY damage</> while at max charge."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        // NOT IMPLEMENTED
        RoguelikeMod mod = NewMod("perfect_sword")
        mod.name = "Perfect Technique"
        mod.abbreviation = "PT"
        mod.description = "If Sword block blocks damage <daze>during it's first second of usage</>, you are <cyan>invulnerable for 1s</> and gain 3 Overload stacks."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        // NOT IMPLEMENTED
        RoguelikeMod mod = NewMod("quickswap")
        mod.name = "Quickswap"
        mod.abbreviation = "Qs"
        mod.description = "Firing your shotgun right after switching to it deals<red> +50% damage</>."
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("offensive_daze_hits")
        mod.name = "Conductive Sword"
        mod.abbreviation = "CS"
        mod.description = "Sword hits while the target has <daze>Daze</> charge your offensives."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("overcharged_arc_wave")
        mod.name = "Overcharged Waves"
        mod.abbreviation = "OW"
        mod.description = "Arc Wave recharges rapidly when using sword core."
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("conduction")
        mod.name = "Conduction"
        mod.abbreviation = "Cd"
        mod.description = "Arc Wave hits restore Dash Energy. Dashing restores Arc Wave cooldown."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("sword_core_use")
        mod.name = "Unrelenting Sword"
        mod.abbreviation = "US"
        mod.description = "Less Sword Core duration is consumed while swinging your sword."
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("overdaze")
        mod.name = "Overdaze"
        mod.abbreviation = "Od"
        mod.description = "<overload>Overload</> stacks no longer have a cap. Sword Core may consume <overload>Overload</> stacks for +50% DMG."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("executioner_meal")
        mod.name = "Executioners Meal"
        mod.abbreviation = "EM"
        mod.description = "Enemies finished off with a <cyan>sword hit</> spawn an additional <green>battery</>."
        mod.cost = 3
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("executioner")
        mod.name = "Executioner"
        mod.abbreviation = "Ex"
        mod.description = "<cyan>Sword hits</> <red>execute</> enemies with less than 25% HP."
        mod.cost = 3
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("offensive_overload")
        mod.name = "Daze to All"
        mod.abbreviation = "DtA"
        mod.description = "When dealing damage with any offensive ability - the target is inflicted <daze>Daze</>. This can trigger every 10s."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("always_sword")
        mod.name = "Sword Sheath"
        mod.abbreviation = "SSh"
        mod.description = "You always use your sword for melee."
        mod.cost = 1
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("phase_ammo")
        mod.name = "Phase Ammo"
        mod.abbreviation = "PA"
        mod.description = "Phase Dash reloads all weapons, and grants <overload>2 Overload charges</>."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("love_diviiiiiiiiiiiiiiiiiiiiiiiiiiiides")
        mod.name = "Oath of the Sword"
        mod.abbreviation = "OtS"
        mod.description = "60% damage resistance while in Sword Core."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = false
    mod.loadouts = [PRIMARY_RONIN]
    mod.isTitan = true

    return mod
}