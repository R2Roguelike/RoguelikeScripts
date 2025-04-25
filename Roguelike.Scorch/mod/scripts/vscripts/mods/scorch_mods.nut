global function Scorch_RegisterMods

void function Scorch_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("offense_canister")
        mod.name = "Offense Canister"
        mod.abbreviation = "OC"
        mod.description = "Your gas canister conentrates it's fire forward, increasing its damage and <burn>burn</>."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("dash_wall")
        mod.name = "FireDash"
        mod.abbreviation = "FD"
        mod.description = "Dashing before casting a wall splits it in 3 ways, increasing its damage."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    if (false)
    {
        RoguelikeMod mod = NewMod("ammo_oil")
        mod.name = "Fuel to the Fire"
        mod.abbreviation = "FtF"
        mod.description = "Burn can accumulate ."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    if (false) // this doesnt work yet.
    {
        RoguelikeMod mod = NewMod("heatsink")
        mod.name = "Heatsink"
        mod.abbreviation = "HS"
        mod.description = "Your Heat Shield outputs a <burn>heatwave</> on release, converting <cyan>absorbed projectiles</> into damage."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("high_wall")
        mod.name = "High Wall"
        mod.abbreviation = "HW"
        mod.description = "Your fire walls have increased height, increasing their burn."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("warmth")
        mod.name = "Warm Embrance"
        mod.abbreviation = "WE"
        mod.description = "You no longer take self damage from fire, but instead slightly heal. <red>Fire Wall and Fire Canister cooldowns are now restored through fire damage instead of time.</>"
        mod.cost = 3
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("flamethrower")
        mod.name = "Flamethrower"
        mod.abbreviation = "Ft"
        mod.description = "Your Thermite Launcher transforms into a rapid-fire flamethrower."
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("buy1get1free")
        mod.name = "1+1 SALE"
        mod.abbreviation = "1+1"
        mod.description = "Your Thermite Launcher fires two projectiles at once."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("again")
        mod.name = "AGAIN!"
        mod.abbreviation = "Ag!"
        mod.description = "Killing a titan that is affected by Flame Core gives you 100% Core charge.\n\n" +
                          "<note>For the best experience, scream \"AGAIN!\" at the top of your lungs every time you use your core."
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("let_[insert_pronoun_here]_cook")
        mod.name = "The Perfect Dish"
        mod.abbreviation = "TPD"
        mod.description = "Burning Enemies killed by NON-fire damage, spawn a <green>battery</>.\n\n<note>\"I'll give you healing, I'll give you everything, just PLEASE start swapping like a crackoid\" -EladNLG</>"
        mod.cost = 1
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("gas_recycle")
        mod.name = "Photosynthesis"
        mod.abbreviation = "Ps"
        mod.description = "Inflicting burn restores cooldown for your utilities."
        mod.cost = 3
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("fire_duration")
        mod.name = "Eternal Flame"
        mod.abbreviation = "EF"
        mod.description = "Thermite particles last <cyan>100%</> longer."
        mod.cost = 3
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("high_temp")
        mod.name = "High Temperature"
        mod.abbreviation = "HT"
        mod.description = "Damage multiplier from fire increased by <cyan>25%</>."
        mod.cost = 3
        mod.chip = TITAN_CHIP_UTILITY
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
