globalize_all_functions

float function Roguelike_GetPilotHealthBonus( int endurance )
{
    return endurance / 100.0
}

float function Roguelike_GetPilotSelfDamageMult( int endurance )
{
    return 100.0 / (100.0 + endurance)
}

float function Roguelike_GetPilotSpeedBonus( int speed )
{
    return speed / 150.0 * 0.8
}

float function Roguelike_GetTitanDamageMultiplier( int armor )
{
    return Graph(75.0 / (75.0 + armor), 1, 0, 1, 1 - 1.75 * 0.3)
}

float function Roguelike_GetTitanDamageResist( int armor )
{
    float resist = 1.0 - Roguelike_GetTitanDamageMultiplier( armor )
    return resist
}

// -90% dash cooldown? why the fuck not...
float function Roguelike_GetDashCooldownMultiplier( int energy )
{
    //return Graph( energy, 0, 150, 1.2, 0.1 )
    return 1.2 * pow(0.3, energy / 100.0) // +20% cd when low, -90% when max
}

float function Roguelike_BaseCritRate( int energy )
{
    //return Graph( energy, 0, 150, 1.2, 0.1 )
    return (5.0 + energy / 2.0) / (100.0)
}

float function Roguelike_BaseCritDMG( int energy )
{
    //return Graph( energy, 0, 150, 1.2, 0.1 )
    return 0.25 + 0.01 * energy
}

float function Roguelike_GetPilotCooldownReduction( int power )
{
    return 1.25 * pow(0.4, power / 100.0) // +50% cd when low, -40% when max
}

float function Roguelike_GetGrenadeDamageBoost( int power )
{
    // +233%
    return 1.0 + power * 0.008 // +50% cd when low, -40% when max
}

float function Roguelike_GetTitanCoreGain( int power )
{
    return 0.5 + 0.0025 * power // -20% when low
}

// bitwise OR of two bits corresponding to titan loadouts
// used for knowing which combination of loadouts we're using, regardless of order
// e.g. scorch + ronin = 0x4 | 0x10 = 0x14
int function GetTitanLoadoutFlags()
{
    array<string> titanLoadouts = Roguelike_GetTitanLoadouts()
    return TITAN_BITS[titanLoadouts[0]] | TITAN_BITS[titanLoadouts[1]]
}

bool function Roguelike_HasTitanLoadout(string weapon)
{
    return Roguelike_GetTitanLoadouts().contains(weapon)
}

int function Roguelike_GetUpgradePrice( table item )
{
    int level = expect int(item.level)
    int price = 100 + (level * 50) + expect int(item.priceOffset)

    return price
}

int function Roguelike_GetItemMaxLevel( table item )
{
    switch (item.type)
    {
        case "armor_chip":
            return MAX_CHIP_LEVEL
        case "weapon":
        case "grenade":
            int rarity = expect int(item.rarity)
            return 3
    }

    return 0
}

string function GetTitanOrPilotFromBool( bool isTitan )
{
    return isTitan ? "Titan" : "Pilot"
}

// first element is name, 2nd element is description
array function GetTitanTextColor(string primary)
{
    switch (primary)
    {
        case "mp_titanweapon_leadwall":
        case "mp_titanweapon_particle_accelerator":
            return [0, 0, 0, 255]
    }

    return [255, 255, 255, 255]
}

// first element is name, 2nd element is description
array function GetTitanColor(string primary)
{
    switch (primary)
    {
        case "mp_titanweapon_leadwall":
            return [255, 225, 100, 255]
        case "mp_titanweapon_meteor":
            return [255, 175, 75, 255]
        case "mp_titanweapon_xo16_shorty":
            return [177, 94, 255, 255]
        case "mp_titanweapon_predator_cannon":
            return [255, 64, 64, 255]
        case "mp_titanweapon_sniper":
            return [64, 96, 255, 255]
        case "mp_titanweapon_particle_accelerator":
            return [64, 255, 255, 255]
    }

    return [40,40,40,255]
}

// first element is name, 2nd element is description
array<string> function GetTitanLoadoutPassiveData()
{
    return ["No Passive", "No passive is active for this loadout combination."]
}


