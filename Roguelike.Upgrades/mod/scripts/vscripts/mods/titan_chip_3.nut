global function TitanChip3_RegisterMods

void function TitanChip3_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("bonus_mag")
        mod.name = "Ammo++"
        mod.description = "Mag size for all weapons doubled."
        mod.icon = $"vgui/hud/white"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("shield_core")
        mod.name = "Shield Core"
        mod.description = "On Core use: Replenish your shields instantly."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("weapon_crit")
        mod.name = "Overcrit"
        mod.description = "When hitting with your primary, increase Crit Rate by 0.5% for 3s. Stacks up to 20 times, repeated triggers reset the duration."
        mod.icon = $"vgui/hud/white"
        mod.cost = 1
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 3
    mod.isTitan = true
    
    return mod
}