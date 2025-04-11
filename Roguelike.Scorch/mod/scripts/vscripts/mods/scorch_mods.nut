global function Scorch_RegisterMods

void function Scorch_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("offense_canister")
        mod.name = "Offense Canister"
        mod.description = "Your gas canister conentrates it's fire forward, increasing its damage and <burn>burn</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("dash_wall")
        mod.name = "FireDash"
        mod.description = "Dashing before casting a wall splits it in 3 ways, increasing its damage."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("ammo_oil")
        mod.name = "Fuel to the Fire"
        mod.description = "Burn can accumulate ."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    if (false) // this doesnt work yet.
    {
        RoguelikeMod mod = NewMod("heatsink")
        mod.name = "Heatsink"
        mod.description = "Your Heat Shield outputs a <burn>heatwave</> on release, converting <cyan>absorbed projectiles</> into damage."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("high_wall")
        mod.name = "High Wall"
        mod.description = "Your fire walls have increased height, increasing their burn."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("warmth")
        mod.name = "Warm Embrance"
        mod.description = "You no longer take self damage from fire, but instead slightly heal."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("flamethrower")
        mod.name = "Flamethrower"
        mod.description = "Your Thermite Launcher transforms into a rapid-fire flamethrower."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("buy1get1free")
        mod.name = "1+1 SALE"
        mod.description = "Your Thermite Launcher fires two projectiles at once."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("again")
        mod.name = "AGAIN!"
        mod.description = "Killing a titan that is affected by Flame Core gives you 100% Core charge.\n\n" +
                          "^88888800For the best experience, scream \"AGAIN!\" at the top of your lungs every time you use your core."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("let_[insert_pronoun_here]_cook")
        mod.name = "The Perfect Dish"
        mod.description = "Enemies killed that are above 50% burn, spawn a <green>battery</>."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("gas_recycle")
        mod.name = "Photosynthesis"
        mod.description = "Inflicting burn restores cooldown for your canisters."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("fire_duration")
        mod.name = "Eternal Flame"
        mod.description = "Thermite particles last <cyan>100%</> longer."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("high_temp")
        mod.name = "High Temperature"
        mod.description = "Damage multiplier from fire increased by <cyan>25%</>."
        mod.icon = $"vgui/hud/white"
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
