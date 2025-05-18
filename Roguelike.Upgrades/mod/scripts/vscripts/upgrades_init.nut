global struct RoguelikeMod
{
    string uniqueName = "unnamed_mod"
    string name = "UNNAMED MOD!!"
    string description = "THERE IS NO DESCRIPTION DEVS DIDNT MAKE ONE"
    string abbreviation = "XXX"
    asset icon = $"vgui/hud/missing"
    int cost = 0
    bool isTitan = false
    int chip = 0
    array<string> loadouts = []
    bool isHidden = false
    bool isSwappable = true
    // uses the loadout-dedicated chip slots.
    // e.g. if you equip scorch and northstar, scorch mods will be available in chip 3
    // but if you equip tone and scorch, scorch mods will be available in chip 4
    bool useLoadoutChipSlot = false

    bool unlockedByDefault = false
    int index = 0
}

global struct RoguelikeRunModifier
{
    string uniqueName = "unnamed_modifier"
    string name = "UNNAMED MODIFIER!!"
    string description = "THERE IS NO DESCRIPTION DEVS DIDNT MAKE ONE"
    array<string> options = []
    asset icon = $"vgui/hud/missing"
    int baseCost = 0
    int costPerLevel = 0
    int index = 0
}

global struct UniqueTitanPassiveData
{
    string name
    string desc
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

global const int MOD_SLOTS = 4;

global const bool MOD_TYPE_TITAN = true
global const bool MOD_TYPE_PILOT = false

global const int STAT_ARMOR     = 0;
global const int STAT_ENERGY    = 1;
global const int STAT_POWER     = 2;
global const int STAT_TEMPER    = 3;
global const int STAT_SPEED     = 4;
global const int STAT_ENDURANCE = 5;

global const int TITAN_CHIP_CHASSIS = 1;
global const int TITAN_CHIP_UTILITY = 2;
global const int TITAN_CHIP_WEAPON = 3;
global const int TITAN_CHIP_CORE = 3;
global const int TITAN_CHIP_ABILITIES = 4;

global const int MAX_CHIP_LEVEL = 3;

global const int RARITY_COMMON      = 0;
global const int RARITY_UNCOMMON    = 1;
global const int RARITY_RARE        = 2;
global const int RARITY_EPIC        = 3;
global const int RARITY_LEGENDARY   = 4;

global const int ENEMY_DEF_PER_LEVEL_EASY  = 50;
global const int ENEMY_DEF_PER_LEVEL       = 50;
global const int ENEMY_DEF_PER_LEVEL_HARD  = 75;
global const int ENEMY_DEF_PER_LEVEL_MASTER= 75;
global const int ENEMY_HP_PER_LEVEL        = 500;
global const int ENEMY_HP_PER_LEVEL_HARD   = 750;
global const int ENEMY_HP_PER_LEVEL_MASTER = 1000;

global const int CHIP_MAIN_STAT_MULT = 5;

global const array<string> STAT_NAMES = ["Armor", "Energy", "Power", "Temper", "Speed", "Endurance"]

global const string PRIMARY_EXPEDITION = "mp_titanweapon_xo16_shorty"
global const string PRIMARY_TONE = "mp_titanweapon_sticky_40mm"
global const string PRIMARY_SCORCH = "mp_titanweapon_meteor"
global const string PRIMARY_BRUTE = "mp_titanweapon_rocketeer_rocketstream"
global const string PRIMARY_ION = "mp_titanweapon_particle_accelerator"
global const string PRIMARY_RONIN = "mp_titanweapon_leadwall"
global const string PRIMARY_NORTHSTAR = "mp_titanweapon_sniper"
global const string PRIMARY_LEGION = "mp_titanweapon_predator_cannon"

global const table<string, int> TITAN_BITS = {
    [PRIMARY_EXPEDITION] = 1,
    [PRIMARY_TONE] = 2,
    [PRIMARY_SCORCH] = 4,
    [PRIMARY_BRUTE] = 8,
    [PRIMARY_ION] = 0x10,
    [PRIMARY_RONIN] = 0x20,
    [PRIMARY_NORTHSTAR] = 0x40,
    [PRIMARY_LEGION] = 0x80
}

global const int SCORCH_RONIN = TITAN_BITS[PRIMARY_SCORCH] | TITAN_BITS[PRIMARY_RONIN]
global const int EXPEDITION_SCORCH = TITAN_BITS[PRIMARY_EXPEDITION] | TITAN_BITS[PRIMARY_SCORCH]
global const int EXPEDITION_RONIN = TITAN_BITS[PRIMARY_EXPEDITION] | TITAN_BITS[PRIMARY_RONIN]
global const int ALL_CHIP_SLOTS = 0xFFFF
global const int DAMAGEFLAG_DISCHARGE = 32
global const int DAMAGEFLAG_DISORDER = 64
global const int DAMAGEFLAG_PYLON = 128

global const int STAT_CAP = 3000

// Roguelike Status Effects
// USE CASE: entities can only have 10 status effects at a time (oldest one gets overwritten when the 11th is applies)
// and intensity precision is limited to fractions of 255
//

global enum RoguelikeEffect
{
    invalid = -1,
    burn,
    burn_flame_core,
    core_on_kill,
    expedition_weaken,
    ronin_overload,
    ronin_daze,
    rearm_reload,
    ronin_block_buff,
    legion_puncture,
    ronin_quickswap,
    northstar_fulminate,
    pilot_fatigue,
    sacrifice_roll,
    segment_sacrifice_1,
    segment_sacrifice_2,
    damage_sacrifice_1,
    damage_sacrifice_2,
    overcrit,
    railgun_trauma,
    ion_charge,
    scorch_warmth,
    parry,
    counter,
    offense_canister,
    rearm_reshield,
    gun_shield_shield,
    count,
}

global const string NORMAL_DIFFICULTY_DESC = "For those who are either fresh off the campaign or after not playing for a long time. ^F4D5A600Not very hard, but great if you want to learn the fundementals."
global const string HARD_DIFFICULTY_DESC = "The intended experience.\n^F4D5A600Recommended if you've played Titanfall 2 recently."
global const string MASTER_DIFFICULTY_DESC = "Enemy health increased, enemy cooldowns halved.\n^F4D5A600Recommended for those who found Hard too easy."
global const string MASOCHIST_DIFFICULTY_DESC = "Batteries no longer spawn naturally.\n^F4D5A600Recommended if you're really looking for pain."

global struct RSEInstance
{
    int effect
    float stacks
    float startTime
    float endTime
    float fadeOutTime
    bool isEndless
}

global struct RStatusEffectData
{
    table<int, RSEInstance> data
}
