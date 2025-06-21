global function Scorch_RegisterMods

void function Scorch_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("offense_canister")
        mod.name = "Offense Canister"
        mod.abbreviation = "OC"
        mod.description = "<cyan>Burn DMG Multiplier +10%</>.\n\nYour gas canister conentrates it's fire forward.\n\n" +
                            "On Gas Canister hit, inflict <burn>Burn</> on yourself, " +
                            "<red>increasing DMG taken by 50%</>, but granting<cyan> +50% DMG</>."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("dash_wall")
        mod.name = "FireDash"
        mod.abbreviation = "FD"
        mod.description = "<cyan>Fire Duration +25%</>.\n\nDashing before casting a wall splits it in 3 ways, increasing its base damage by 100%, and reducing the cooldown by 25%."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("high_wall")
        mod.name = "High Wall"
        mod.abbreviation = "HW"
        mod.description = "<cyan>Fire Duration +25%</>.\n\nYour fire walls have increased height, increasing it's damage by 100%."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("warmth")
        mod.name = "Warm Embrance"
        mod.abbreviation = "WE"
        mod.description = "<cyan>Fire Duration +25%</>.\n\nYou no longer take self damage from <note>your own</> fire, but instead gain damage resistance while in it."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("flamethrower")
        mod.name = "Flamethrower"
        mod.abbreviation = "Ft"
        mod.description = "<cyan>Burn DMG Multiplier +10%</>.\n\nYour Thermite Launcher transforms into a rapid-fire flamethrower."
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("buy1get1free")
        mod.name = "1+1 SALE"
        mod.abbreviation = "1+1"
        mod.description = "<cyan>Burn DMG Multiplier +10%</>.\n\nYour Thermite Launcher fires two projectiles at once."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("again")
        mod.name = "AGAIN!"
        mod.abbreviation = "Ag!"
        mod.description = "<cyan>Fire Duration +25%</>.\n\nKilling a titan that is affected by Flame Core gives you 100% Core charge.\n\n" +
                          "<note>For the best experience, scream \"AGAIN!\" at the top of your lungs every time you use your core."
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("let_[insert_pronoun_here]_cook")
        mod.name = "The Perfect Dish"
        mod.abbreviation = "TPD"
        mod.description = "<cyan>Fire Duration +25%</>.\n\n<burn>Burning</> Enemies killed by <red>NON</>-fire damage, spawn a <green>battery</>.\n\n<note>\"I'll give you healing, I'll give you everything, just PLEASE start swapping like an individual on crack\" -EladNLG</>"
        mod.cost = 1
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("gas_recycle")
        mod.name = "Photosynthesis"
        mod.abbreviation = "Ps"
        mod.description = "<cyan>Burn DMG Multiplier +10%</>.\n\nInflicting burn restores cooldown for your utilities."
        mod.cost = 3
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("burn_shield")
        mod.name = "Shields of Flame"
        mod.abbreviation = "SoF"
        mod.description = "<cyan>Burn DMG Multiplier +10%</>.\n\nInflicting non-fire damage against burning enemies restores shields."
        mod.cost = 3
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("burn_dmg")
        mod.name = "Fuel to the Fire"
        mod.abbreviation = "FtF"
        mod.description = "<cyan>Burn DMG Multiplier +10%</>.\n\nBurn affects Fire damage."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("quickload")
        mod.name = "Meteor Stun"
        mod.abbreviation = "MS"
        mod.description = "<cyan>Fire Duration +25%</>.\n\nHitting an enemy with your Thermite Launcher <cyan>stuns them</>."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("gassin")
        mod.name = "Gassed Up"
        mod.abbreviation = "GU"
        mod.description = "<cyan>Fire Duration +25%</>.\n\nFire 2 Gas Canisters per use."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("flame_core_burn_dmg")
        mod.name = "Overburn"
        mod.abbreviation = "Ob"
        mod.description = "<cyan>Burn DMG Multiplier +10%</>.\n\nFlame Core applies a <burn>200% DMG Taken</> debuff onto enemies."
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
