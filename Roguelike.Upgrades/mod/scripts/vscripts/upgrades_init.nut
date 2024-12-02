global struct RoguelikeMod
{
    string uniqueName = "unnamed_mod"
    string name = "UNNAMED MOD!!"
    string description = "THERE IS NO DESCRIPTION DEVS DIDNT MAKE ONE"
    asset icon = $"vgui/hud/missing"
    int cost = 0
    bool isTitan = false
    int chip = 0
    string loadout = ""
    // uses the loadout-dedicated chip slots.
    // e.g. if you equip scorch and northstar, scorch mods will be available in chip 3
    // but if you equip tone and scorch, scorch mods will be available in chip 4
    bool useLoadoutChipSlot = false

    bool unlockedByDefault = false
    int index = 0
}

global struct StatusEffectData
{
    bool isEndless
    int effectType
    int instanceId
    float intensity
    float endTime
    float fadeOutTime
}

// how much (in percent) health and damage enemies get for every power above the player
// additive
global const float POWER_SCALAR = 1.0

global const int MOD_SLOTS = 4;

global const bool MOD_TYPE_TITAN = true
global const bool MOD_TYPE_PILOT = false

global const int STAT_ARMOR     = 0;
global const int STAT_ENERGY    = 1;
global const int STAT_POWER     = 2;
global const int STAT_TEMPER    = 3;
global const int STAT_SPEED     = 4;
global const int STAT_ENDURANCE = 5;

global const array<string> STAT_NAMES = ["Armor", "Energy", "Power", "Temper", "Speed", "Endurance"]
