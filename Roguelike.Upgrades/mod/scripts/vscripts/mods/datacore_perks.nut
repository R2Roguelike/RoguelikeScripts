global function DatacorePerks_Init

void function DatacorePerks_Init()
{
    // UNCOMMON PERKS
    {
        RoguelikeDatacorePerk mod = NewMod("weapon_dmg")
        mod.name = "Sharp"
        mod.description = "+%.0f%% Weapon DMG."
        mod.baseValue = 15.0
        mod.valuePerLevel = 5.0
        mod.slot = 1
    }
    {
        RoguelikeDatacorePerk mod = NewMod("ability_cd")
        mod.name = "Cooled"
        mod.description = "-%.0f%% ability cooldowns."
        mod.baseValue = 10.0
        mod.valuePerLevel = 3.0
        mod.slot = 1
    }
    {
        RoguelikeDatacorePerk mod = NewMod("ability_dmg")
        mod.name = "Ableist"
        mod.description = "+%.0f%% Ability DMG."
        mod.baseValue = 15.0
        mod.valuePerLevel = 5.0
        mod.slot = 1
    }
    {
        RoguelikeDatacorePerk mod = NewMod("core_dmg")
        mod.name = "Encorical"
        mod.description = "+%.0f%% Core DMG."
        mod.baseValue = 18.0
        mod.valuePerLevel = 6.0
        mod.slot = 1
    }
    // RARE
    {
        RoguelikeDatacorePerk mod = NewMod("polarity")
        mod.name = "Polarized"
        mod.description = "Gain a stack of Polarity every hit. When you reach 10 stacks, swap Polarity. <fulm>Blue</> polarity reduces damage taken by %.0f%%. <punc>Red</> polarity grants +%.0f%% DMG."
        mod.baseValue = 15.0
        mod.valuePerLevel = 5.0
        mod.slot = 2
    }
    {
        RoguelikeDatacorePerk mod = NewMod("tanky")
        mod.name = "Batterized"
        mod.description = "Picking up batteries grants +%.0f%% DMG for 15s."
        mod.baseValue = 25.0
        mod.valuePerLevel = 5.0
        mod.slot = 2
    }
    {
        RoguelikeDatacorePerk mod = NewMod("swap")
        mod.name = "Divided"
        mod.description = "Swapping loadouts grants +40%% DMG for %.0fs."
        mod.baseValue = 5.0
        mod.valuePerLevel = 1.0
        mod.slot = 2
    }
    {
        RoguelikeDatacorePerk mod = NewMod("shield")
        mod.name = "Shielded"
        mod.description = "Shield regeneration delay reduced by 100%%. Shield regeneration rate reduced by 50%%."
        mod.slot = 2
    }
    // EPIC
    {
        RoguelikeDatacorePerk mod = NewMod("unlocalized")
        mod.name = "Malware-Contaminated"
        mod.description = "+%.0f%% DMG.\n\n<red>:)</>"
        mod.baseValue = 30.0
        mod.valuePerLevel = 10.0
        mod.slot = 3
    }
    {
        RoguelikeDatacorePerk mod = NewMod("dash+")
        mod.name = "Dashing"
        mod.description = "Dashing grants +%.0f%% DMG for 2s."
        mod.baseValue = 50.0
        mod.valuePerLevel = 5.0
        mod.slot = 3
    }
    {
        RoguelikeDatacorePerk mod = NewMod("offended")
        mod.name = "Offended"
        mod.description = "+%.0f%% Offensive Ability DMG."
        mod.baseValue = 35.0
        mod.valuePerLevel = 5.0
        mod.slot = 3
    }
    {
        RoguelikeDatacorePerk mod = NewMod("gun")
        mod.name = "Trigger-Happy"
        mod.description = "+%.0f%% Weapon DMG. <red>+25%% Ability Cooldowns.</>"
        mod.baseValue = 50.0
        mod.valuePerLevel = 10.0
        mod.slot = 3
    }
    // LEGENDARY
    {
        RoguelikeDatacorePerk mod = NewMod("damage_cap")
        mod.name = "Fractured"
        mod.description = "<cyan>+%.0f%% DMG,</> but <red>you can only deal up to 1000 DMG per hit.</>"
        mod.baseValue = 100.0
        mod.valuePerLevel = 25.0
        mod.slot = 4
    }
    {
        RoguelikeDatacorePerk mod = NewMod("gambling")
        mod.name = "Gambler"
        mod.description = "<red>Crit Rate is capped at 50%%,</> but Crit DMG increases by %.0f%%."
        mod.baseValue = 150.0
        mod.valuePerLevel = 30.0
        mod.slot = 4
    }
    {
        RoguelikeDatacorePerk mod = NewMod("damage_min")
        mod.name = "Risky"
        mod.description = "Non-critical hits do 0 damage. +%.0f%% Crit DMG."
        mod.baseValue = 100.0
        mod.valuePerLevel = 25.0
        mod.slot = 4
    }
    {
        RoguelikeDatacorePerk mod = NewMod("second_wind")
        mod.name = "Backed-Up"
        mod.description = "Titan kills while doomed undoom you. <red>Battery healing reduced by %.0f%%.</>"
        mod.baseValue = 100.0
        mod.valuePerLevel = -10.0
        mod.slot = 4
    }
}

RoguelikeDatacorePerk function NewMod(string uniqueName)
{
    RoguelikeDatacorePerk mod = Roguelike_NewDatacorePerk(uniqueName)

    return mod
}