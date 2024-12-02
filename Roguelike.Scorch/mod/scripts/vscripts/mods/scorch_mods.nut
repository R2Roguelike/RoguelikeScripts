global function Scorch_RegisterMods

void function Scorch_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("offense_canister")
        mod.name = "Offense Canister"
        mod.description = "Your gas canister conentrates it's fire forward, increasing its damage output."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("concentrated_canister")
        mod.name = "Concentrated Canister"
        mod.description = "Your gas canister contains more gas, increasing its Burn output."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("dash_wall")
        mod.name = "FireDash"
        mod.description = "Dashing before casting a wall splits it in 3 ways, increasing its damage."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("high_wall")
        mod.name = "High Wall"
        mod.description = "Your fire walls have increased height, increasing their burn."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("self_burn")
        mod.name = "Explosive Ideals"
        mod.description = "You can inflict Burn on yourself. Self damage from Eruptions heavily reduced."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("flamethrower")
        mod.name = "Flamethrower"
        mod.description = "Your primary transforms into a short-range flamethrower."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("let_[insert_pronoun_here]_cook")
        mod.name = "The Perfect Dish"
        mod.description = "Enemies killed that were never inflicted with Eruption, but are above 75% burn, spawn an additional battery."
        mod.icon = $"vgui/hud/white"
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("gas_recycle")
        mod.name = "Photosynthesis"
        mod.description = "Inflicting burn restores cooldown for your canisters."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = true
    mod.loadout = "mp_titanweapon_meteor"
    mod.chip = 1
    mod.isTitan = true
    
    return mod
}
