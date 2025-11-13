global function Scorch_RegisterMods

void function Scorch_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("offense_canister")
        mod.name = "Offense Canister"
        mod.abbreviation = "OC"
        mod.description = "<cyan>Burn DMG Multiplier +5%.</>\n\nFire 2 Gas Canisters per use. Your gas canister conentrates it's fire forward.\n\n" +
                            "On Gas Canister hit, inflict <burn>Burn</> on yourself, " +
                            "<red>increasing DMG taken by 50%,</> but granting<cyan> +50% DMG.</>"
        mod.shortdesc = "Burning yourself through <daze>Gas Canister hits</>\ngrants <cyan>+DMG%."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("dash_wall")
        mod.name = "FireDash"
        mod.abbreviation = "FD"
        mod.description = "<cyan>Fire Duration +25%.</>\n\nDashing before casting a wall splits it in 3 ways, and +10% Crit Rate against burning enemies."
        mod.shortdesc = "Dashing before casting a wall splits it in 3.\nGain <cyan>Crit Rate</> against burning enemies."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("high_wall")
        mod.name = "High Wall"
        mod.abbreviation = "HW"
        mod.description = "<cyan>Fire Duration +25%.</>\n\nYour fire walls have increased height, increasing it's damage by 100%."
        mod.shortdesc = "Your fire walls have increased height."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("warmth")
        mod.name = "Warm Embrance"
        mod.abbreviation = "WE"
        mod.description = "<cyan>Fire Duration +25%.</>\n\nYou no longer take self damage from <note>your own</> fire, but instead gain damage resistance while in it."
        mod.shortdesc = "Gain DMG Resist while in your own fire."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("flamethrower")
        mod.name = "Flamethrower"
        mod.abbreviation = "Ft"
        mod.description = "<cyan>Burn DMG Multiplier +5%.</>\n\nYour Thermite Launcher transforms into a rapid-fire flamethrower."
        mod.shortdesc = "Your Thermite Launcher is now a flamethrower."
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("buy1get1free")
        mod.name = "1+1 SALE"
        mod.abbreviation = "1+1"
        mod.description = "<cyan>Burn DMG Multiplier +5%.</>\n\nYour Thermite Launcher fires two projectiles at once."
        mod.shortdesc = "Thermite Launcher fires two projectiles at once."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("again")
        mod.name = "AGAIN!"
        mod.abbreviation = "Ag!"
        mod.description = "<cyan>Fire Duration +25%.</>\n\nKilling a titan that is affected by Flame Core gives you 100% Core charge.\n\n" +
                          "<note>For the best experience, scream \"AGAIN!\" at the top of your lungs every time you use your core."
        mod.shortdesc = "Flame Core kills grant 100% Core charge."
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("let_[insert_pronoun_here]_cook")
        mod.name = "The Perfect Dish"
        mod.abbreviation = "TPD"
        mod.description = "<cyan>Fire Duration +25%.</>\n\n<burn>Burning</> Enemies killed by <red>NON</>-fire damage, spawn a <green>battery.</>\n\n<note>\"I'll give you healing, I'll give you everything, just PLEASE start swapping like an individual on crack\" -EladNLG</>"
        mod.shortdesc = "Burning Titans killed by <red>NON</>-fire damage,\n<green>spawn a battery.</>"
        mod.cost = 1
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("gas_recycle")
        mod.name = "Photosynthesis"
        mod.abbreviation = "Ps"
        mod.description = "<cyan>Burn DMG Multiplier +5%.</>\n\nInflicting burn restores cooldown for your offensives."
        mod.shortdesc = "Inflicting burn restores cooldown for your\noffensives."
        mod.cost = 3
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("burn_shield")
        mod.name = "Shields of Flame"
        mod.abbreviation = "SoF"
        mod.description = "<cyan>Burn DMG Multiplier +5%.</>\n\nInflicting non-fire damage against burning enemies restores shields."
        mod.shortdesc = "Inflicting non-fire DMG against burning\nenemies restores shields."
        mod.cost = 3
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("burn_dmg")
        mod.name = "Fuel to the Fire"
        mod.abbreviation = "FtF"
        mod.description = "<cyan>Burn DMG Multiplier +5%.</>\n\n<burn>Burn</> and most other Scorch effects apply to <burn>Fire DMG</>."
        mod.shortdesc = "Fire DMG is considered non-Fire damage."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("second_degree_burn")
        mod.name = "Second Degree Burn"
        mod.abbreviation = "SDB"
        mod.description = "<cyan>Fire Duration +25%.</>\n\nBurning enemies spew fire around them on non-fire hit."
        mod.shortdesc = "Burning enemies spew fire around them\non non-fire hits."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("flame_core_burn_dmg")
        mod.name = "Overburn"
        mod.abbreviation = "Ob"
        mod.description = "<cyan>Burn DMG Multiplier +5%.</>\n\nFlame Core applies a <burn>200% DMG Taken</> debuff onto enemies."
        mod.shortdesc = "Flame Core applies a <red>BIG</> Burn DMG\ndebuff onto enemies."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = false
    mod.loadouts = [ PRIMARY_SCORCH ]
    mod.chip = 1
    mod.isTitan = true

    return mod
}
