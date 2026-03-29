global function Brute_RegisterMods

global const string BRUTE_MAG_SIZE_TAG = "brute_mag_size"  
global const string BRUTE_FIRE_RATE_TAG = "brute_fire_rate"  
void function Brute_RegisterMods()
{
    Roguelike_RegisterTag( BRUTE_MAG_SIZE_TAG, "+15% Mag Size.")
    Roguelike_RegisterTag( BRUTE_FIRE_RATE_TAG, "+15% Fire Rate.")
    {
        RoguelikeMod mod = NewMod("quickload_firerate")
        mod.name = "Quickfire"
        mod.abbreviation = "Qf"
        mod.description = "Gain <cyan>+100% Quad Rocket Fire Rate</> for 3s after using Quickload."
        mod.shortdesc = "Gain <cyan>Quad Rocket Fire Rate</> after using Quickload."
        mod.tags = [BRUTE_MAG_SIZE_TAG]
        mod.statModifiers = [NewStatModifier("mag_size", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("auto_altfire")
        mod.name = "Rocket Machine Gun"
        mod.abbreviation = "RMG"
        mod.description = "<cyan>+100% Base Fire Rate</> while using the Quad Rocket's alt fire."
        mod.shortdesc = "Quad Rocket's Alt Fire\ngains <cyan>+100% Base Fire Rate."
        mod.tags = [BRUTE_MAG_SIZE_TAG]
        mod.statModifiers = [NewStatModifier("mag_size", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("dual_load")
        mod.name = "Dual Load"
        mod.abbreviation = "DL"
        mod.description = "When using Quickload - if <daze>ALL primaries are are missing ammo</> - gain <cyan>+50% DMG</> for 20s."
        mod.shortdesc = "If <daze>ALL primaries are missing ammo</> when\nquickloading: <cyan>+50% DMG</> for 20s."
        mod.tags = [BRUTE_MAG_SIZE_TAG]
        mod.statModifiers = [NewStatModifier("mag_size", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("infinite_ammo")
        mod.name = "Infiniteload"
        mod.abbreviation = "Inl"
        mod.description = "When using Quickload - gain <cyan>infinite ammo for all weapons</> for 10s after using."
        mod.shortdesc = "Quickload grants <daze>infinite ammo</> for 10s."
        mod.tags = [BRUTE_FIRE_RATE_TAG]
        mod.statModifiers = [NewStatModifier("fire_rate_titan", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("arm_ed")
        mod.name = "StrongArmed"
        mod.abbreviation = "SoA"
        mod.description = "When applying Armed against an already Tagged target, <cyan>deal an enourmous amount of DMG</>."
        mod.shortdesc = "Using your Armed against an already\nTagged target deals <red>enourmous DMG.</>"
        mod.tags = [BRUTE_FIRE_RATE_TAG]
        mod.statModifiers = [NewStatModifier("fire_rate_titan", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("multi_arm")
        mod.name = "MultiArm"
        mod.abbreviation = "MA"
        mod.description = "<cyan>+1 Tagging Laser charge.</>\nYou can Arm multiple targets at once. When Arming multiple rockets - the amount of rockets you fire increases, but ammo consumed does not."
        mod.shortdesc = "<cyan>+1 Tagging Laser charge.</>\nYou can Arm multiple targets at once."
        mod.tags = [BRUTE_FIRE_RATE_TAG, EXTRA_OFFENSIVE_CHARGE]
        mod.statModifiers = [NewStatModifier("fire_rate_titan", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("quick_charge")
        mod.name = "QuickCharge"
        mod.abbreviation = "QC"
        mod.description = "Quickload also resets the cooldown of his offensive."
        mod.shortdesc = "Quickload also resets the\ncooldown of his offensive."
        mod.tags = [BRUTE_FIRE_RATE_TAG]
        mod.statModifiers = [NewStatModifier("fire_rate_titan", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("instant_stun")
        mod.name = "Shield Charger"
        mod.abbreviation = "SC"
        mod.description = "Restore Shields as you craft a battery."
        mod.shortdesc = "Restore Shields as you craft a battery."
        mod.tags = [BRUTE_MAG_SIZE_TAG]
        mod.statModifiers = [NewStatModifier("mag_size", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("power_battery")
        mod.name = "Power Battery"
        mod.abbreviation = "PB"
        mod.description = "Crafting a battery grants invulnerability for 5s."
        mod.shortdesc = "Crafting a battery grants invulnerability for 5s."
        mod.tags = [BRUTE_FIRE_RATE_TAG]
        mod.statModifiers = [NewStatModifier("fire_rate_titan", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("arm_load")
        mod.name = "Loading Arm"
        mod.abbreviation = "LA"
        mod.description = "Applying Armed reloads all weapons and grants +35% DMG for 12s."
        mod.shortdesc = "Applying Armed reloads all weapons\nand grants +DMG% for 12s."
        mod.tags = [BRUTE_FIRE_RATE_TAG]
        mod.statModifiers = [NewStatModifier("fire_rate_titan", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("burst_load")
        mod.name = "Burst Load"
        mod.abbreviation = "BL"
        mod.description = "Quickload makes your Quad Rocket dump it's entire mag the next time you fire."
        mod.shortdesc = "Quickload makes your Quad Rocket dump it's\nentire mag the next time you fire."
        mod.tags = [BRUTE_MAG_SIZE_TAG]
        mod.statModifiers = [NewStatModifier("mag_size", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("double_battery")
        mod.name = "Double Craft"
        mod.abbreviation = "DC"
        mod.description = "When you have at least 66% Core: Right after crafting a battery, <red>consume an additional 16% Core</> to <green>craft another.</>"
        mod.shortdesc = "When you have at least 66% Core,\nBattery Craft will craft 2 batteries."
        mod.tags = [BRUTE_FIRE_RATE_TAG]
        mod.statModifiers = [NewStatModifier("fire_rate_titan", 0.15)]
        mod.cost = 2
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("quad_inverted")
        mod.name = "Inversion"
        mod.abbreviation = "Ivr"
        mod.description = "Quad Rocket <cyan>alt fire homes onto enemies</>, but <red>Primary Fire no longer does.</>"
        mod.shortdesc = "Quad Rocket <cyan>alt fire homes onto enemies.</>\n<red>Primary Fire no longer does.</>"
        mod.tags = [BRUTE_FIRE_RATE_TAG]
        mod.statModifiers = [NewStatModifier("fire_rate_titan", 0.15)]
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("power_fire")
        mod.name = "SuperPower"
        mod.abbreviation = "SP"
        mod.description = "Quad Rocket fires double the rockets,<red> for double the ammo consumption."
        mod.shortdesc = "Quad Rocket fires double the rockets,\n<red>for double the ammo consumption."
        mod.tags = [BRUTE_FIRE_RATE_TAG]
        mod.statModifiers = [NewStatModifier("fire_rate_titan", 0.15)]
        mod.cost = 2
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = true
    mod.loadouts = [PRIMARY_BRUTE]
    mod.chip = 3
    mod.isTitan = true

    return mod
}
