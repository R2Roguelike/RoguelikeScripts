global function Scorch_RegisterMods

global const string SCORCH_ABILITY_DURATION_TAG = "scorch_ability_duration"
global const string SCORCH_ABILITY_POWER_TAG = "scorch_ability_power"
void function Scorch_RegisterMods()
{
    Roguelike_RegisterTag(SCORCH_ABILITY_DURATION_TAG, "+15% Ability Duration.")
    Roguelike_RegisterTag(SCORCH_ABILITY_POWER_TAG, "+10 Ability Power.")
    RoguelikeStatModifier SCORCH_ABILITY_DURATION_MODIFIER = NewStatModifier("ability_duration", 0.15)
    RoguelikeStatModifier SCORCH_ABILITY_POWER_MODIFIER = NewStatModifier("ability_power", 10)
    {
        RoguelikeMod mod = NewMod("offense_canister")
        mod.name = "Offense Canister"
        mod.abbreviation = "OC"
        mod.description = "Fire 2 Gas Canisters per use. Your gas canister conentrates it's fire forward.\n\n" +
                            "On Gas Canister hit, inflict <burn>Burn</> on yourself, " +
                            "<red>increasing DMG taken by 50%,</> but granting<cyan> +50% DMG.</>"
        mod.shortdesc = "Burning yourself through <daze>Gas Canister hits</>\ngrants <cyan>+DMG%."
        mod.cost = 2
        mod.tags = [SCORCH_ABILITY_POWER_TAG]
        mod.statModifiers = [SCORCH_ABILITY_POWER_MODIFIER]
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("dash_wall")
        mod.name = "Split Fire"
        mod.abbreviation = "SF"
        mod.description = "Flame Wall casts 3 walls, and an additional 2 Walls for every 10 Ability Power you have <note>up to a total of 9</>."
        mod.shortdesc = "Flame Wall casts 3 walls, and even\nmore with <burn>Ability Power."    
        mod.cost = 2
        mod.tags = [SCORCH_ABILITY_DURATION_TAG]
        mod.statModifiers = [SCORCH_ABILITY_DURATION_MODIFIER]
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("high_wall")
        mod.name = "High Wall"
        mod.abbreviation = "HW"
        mod.description = "Dashing right before casting Flame Wall grants your fire walls have increased height, increasing their damage by 100%. Additionally, gain +10% Crit Rate against burning enemies."
        mod.shortdesc = "Dashing before casting Flame Wall grants\nyour fire walls increased height & DMG."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("warmth")
        mod.name = "Warm Embrance"
        mod.abbreviation = "WE"
        mod.description = "You no longer take self damage from <note>your own</> fire, but instead gain damage resistance while in it."
        mod.shortdesc = "Gain DMG Resist while in your own fire."
        mod.tags = [SCORCH_ABILITY_DURATION_TAG]
        mod.statModifiers = [SCORCH_ABILITY_DURATION_MODIFIER]
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("flamethrower")
        mod.name = "Flamethrower"
        mod.abbreviation = "Ft"
        mod.description = "Your Thermite Launcher transforms into a rapid-fire flamethrower."
        mod.shortdesc = "Your Thermite Launcher is now a flamethrower."
        mod.cost = 3
        mod.tags = [SCORCH_ABILITY_POWER_TAG]
        mod.statModifiers = [SCORCH_ABILITY_POWER_MODIFIER]
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("buy1get1free")
        mod.name = "1+1 SALE"
        mod.abbreviation = "1+1"
        mod.description = "Your Thermite Launcher fires two projectiles at once."
        mod.shortdesc = "Thermite Launcher fires two projectiles at once."
        mod.cost = 2
        mod.tags = [SCORCH_ABILITY_POWER_TAG]
        mod.statModifiers = [SCORCH_ABILITY_POWER_MODIFIER]
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("again")
        mod.name = "AGAIN!"
        mod.abbreviation = "Ag!"
        mod.description = "Killing a Titan up to 15s after hitting it with Flame Core gives you 100% Core charge.\n\n" +
                          "<note>For the best experience, scream \"AGAIN!\" at the top of your lungs every time you use your core."
        mod.tags = [SCORCH_ABILITY_DURATION_TAG]
        mod.statModifiers = [SCORCH_ABILITY_DURATION_MODIFIER]
        mod.shortdesc = "Flame Core kills<red>*</> grant 100% Core charge."
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("let_[insert_pronoun_here]_cook")
        mod.name = "The Perfect Dish"
        mod.abbreviation = "TPD"
        mod.description = "<burn>Burning</> Enemies killed by <red>NON</>-fire damage, spawn a <green>battery.</>\n\n<note>\"I'll give you healing, I'll give you everything, just PLEASE start swapping like an individual on crack\" -EladNLG</>"
        mod.shortdesc = "Burning Titans killed by <red>NON</>-fire damage,\n<green>spawn a battery.</>"
        mod.tags = [SCORCH_ABILITY_DURATION_TAG]
        mod.statModifiers = [SCORCH_ABILITY_DURATION_MODIFIER]
        mod.cost = 1
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("gas_recycle")
        mod.name = "Photosynthesis"
        mod.abbreviation = "Ps"
        mod.description = "Fire hits restore energy for your offensives.\n\n<cyan>This is done at a rate of 3%/sec per fire source.</>"
        mod.shortdesc = "Fire hits restore energy for your\noffensives."
        mod.cost = 3
        mod.tags = [SCORCH_ABILITY_POWER_TAG]
        mod.statModifiers = [SCORCH_ABILITY_POWER_MODIFIER]
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("second_degree_burn")
        mod.name = "Second Degree Burn"
        mod.abbreviation = "SDB"
        mod.description = "Burning enemies spew fire around them on non-fire hit."
        mod.shortdesc = "Burning enemies spew fire around them\non non-fire hits."
        mod.tags = [SCORCH_ABILITY_DURATION_TAG]
        mod.statModifiers = [SCORCH_ABILITY_DURATION_MODIFIER]
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("flame_core_burn_dmg")
        mod.name = "Overburn"
        mod.abbreviation = "Ob"
        mod.description = "Flame Core applies a <burn>200% DMG Taken</> debuff onto enemies."
        mod.shortdesc = "Flame Core applies a <red>BIG</> Burn DMG\ndebuff onto enemies."
        mod.cost = 2
        mod.tags = [SCORCH_ABILITY_POWER_TAG]
        mod.statModifiers = [SCORCH_ABILITY_POWER_MODIFIER]
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("scorch_burn_dmg")
        mod.name = "High Temperature"
        mod.abbreviation = "HT"
        mod.description = "Burn DMG Multiplier +25%."
        mod.shortdesc = "Burn DMG Multiplier +25%."
        mod.cost = 2
        mod.tags = [SCORCH_ABILITY_DURATION_TAG]
        mod.statModifiers = [SCORCH_ABILITY_DURATION_MODIFIER]
        mod.chip = TITAN_CHIP_WEAPON
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = true
    mod.loadouts = [ PRIMARY_SCORCH ]
    mod.chip = 3
    mod.isTitan = true

    return mod
}
