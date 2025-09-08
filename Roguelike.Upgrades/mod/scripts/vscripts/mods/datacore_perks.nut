global function DatacorePerks_Init

void function DatacorePerks_Init()
{
    // UNCOMMON PERKS
    {
        RoguelikeDatacorePerk mod = NewMod("weapon_dmg")
        mod.name = "Sharp"
        mod.description = "+15% Weapon DMG."
        mod.slot = 1
    }
    {
        RoguelikeDatacorePerk mod = NewMod("ability_cd")
        mod.name = "Cooled"
        mod.description = "-10% ability cooldowns."
        mod.slot = 1
    }
    {
        RoguelikeDatacorePerk mod = NewMod("ability_dmg")
        mod.name = "Ableist"
        mod.description = "+15% Ability DMG."
        mod.slot = 1
    }
    {
        RoguelikeDatacorePerk mod = NewMod("core_dmg")
        mod.name = "Encorical"
        mod.description = "+20% Core DMG."
        mod.slot = 1
    }
    // RARE
    {
        RoguelikeDatacorePerk mod = NewMod("polarity")
        mod.name = "Polarized"
        mod.description = "Gain a stack of Polarity every hit. When you reach 10 stacks, swap Polarity. <fulm>Blue</> polarity reduces damage taken by 25%. <punc>Red</> polarity grants +25% DMG."
        mod.slot = 2
    }
    {
        RoguelikeDatacorePerk mod = NewMod("tanky")
        mod.name = "Batterized"
        mod.description = "Picking up batteries grants +25% DMG for 15s."
        mod.slot = 2
    }
    {
        RoguelikeDatacorePerk mod = NewMod("swap")
        mod.name = "Divided"
        mod.description = "Swapping loadouts grants +30% DMG for 5s."
        mod.slot = 2
    }
    {
        RoguelikeDatacorePerk mod = NewMod("shield")
        mod.name = "Shielded"
        mod.description = "Shield regeneration delay reduced by 50%."
        mod.slot = 2
    }
    // EPIC
    {
        RoguelikeDatacorePerk mod = NewMod("unlocalized")
        mod.name = "Encrypted"
        mod.description = "U3VyZSBob3BlIHlvdSBkb24ndCBoYXZlIFN0ZWFtIG9wZW4uICsyMCUgRE1HLg"
        mod.slot = 3
    }
    {
        RoguelikeDatacorePerk mod = NewMod("dash+")
        mod.name = "Dashing"
        mod.description = "Dashing grants +35% DMG for 2s."
        mod.slot = 3
    }
    {
        RoguelikeDatacorePerk mod = NewMod("offended")
        mod.name = "Offended"
        mod.description = "+35% Offensive Ability DMG."
        mod.slot = 3
    }
    {
        RoguelikeDatacorePerk mod = NewMod("gun")
        mod.name = "Trigger-Happy"
        mod.description = "+50% Weapon DMG. <red>+25% Ability Cooldowns.</>"
        mod.slot = 3
    }
    // LEGENDARY
    {
        RoguelikeDatacorePerk mod = NewMod("damage_cap")
        mod.name = "Fractured"
        mod.description = "<cyan>+100% DMG</>, but <red>you can only deal up to 1000 DMG per hit</>."
        mod.slot = 4
    }
    {
        RoguelikeDatacorePerk mod = NewMod("gambling")
        mod.name = "Gambler"
        mod.description = "<red>Crit Rate is capped at 50%</>, but Crit DMG increases by 150%."
        mod.slot = 4
    }
    {
        RoguelikeDatacorePerk mod = NewMod("damage_min")
        mod.name = "Risky"
        mod.description = "Non-critical hits do 0 damage. +100% Crit DMG."
        mod.slot = 4
    }
    {
        RoguelikeDatacorePerk mod = NewMod("second_wind")
        mod.name = "Backed-Up"
        mod.description = "Titan kills while doomed undoom you. <red>Battery healing reduced by 50%</>."
        mod.slot = 4
    }
}

RoguelikeDatacorePerk function NewMod(string uniqueName)
{
    RoguelikeDatacorePerk mod = Roguelike_NewDatacorePerk(uniqueName)

    return mod
}