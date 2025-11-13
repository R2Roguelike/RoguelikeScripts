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
    float base = 250
    base += 1 * min(armor, 50)
    base += 0.25 * max(armor - 50, 0)
    return 200.0 / (200.0 + armor)
}

float function Roguelike_GetTitanDamageResist( int armor )
{
    float resist = 1.0 - Roguelike_GetTitanDamageMultiplier( armor )
    return resist
}

int function Roguelike_GetBatteryHealingMultiplier( int armor )
{
    int base = 800
    base += 4 * minint(armor, 100)
    base += 2 * maxint(armor - 100, 0)
    return base
}

// -90% dash cooldown? why the fuck not...
float function Roguelike_GetDashCooldownMultiplier( int energy )
{
    //return Graph( energy, 0, 150, 1.2, 0.1 )
    return 1.0 * pow(0.5, energy / 100.0) // +20% cd when low, -90% when max
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
    return 1.25 * pow(0.5, power / 100.0) // +50% cd when low, -40% when max
}

float function Roguelike_GetPilotCloakDuration( int power )
{
    return 1.0 + 0.005 * power // +50% cd when low, -40% when max
}

float function Roguelike_GetGrenadeDamageBoost( int power )
{
    // +233%
    return 1.0 + power * 0.008 // +50% cd when low, -40% when max
}

float function Roguelike_GetTitanCoreGain( int power )
{
    return 0.5 + 0.01 * power // -20% when low
}

float function Roguelike_GetTitanCooldownReduction( int power )
{
    float base = 1.5
    base *= pow(0.666, (power) / 50.0)
    return base // -20% when low
}

float function Roguelike_GetTitanReloadSpeedBonus( int power )
{
    float base = 1.0 + 0.004 * power
    return base // -20% when low
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

int function Roguelike_GetTitanMaxHealth()
{
    int base = 12500

    return base
}

int function Roguelike_GetPurchasePrice( table item )
{
    return SHOP_LOOT_PRICE + SHOP_LOOT_PRICE_PERRARITY * expect int(item.rarity)
}

int function Roguelike_GetItemMaxLevel( table item )
{
    switch (item.type)
    {
        case "armor_chip":
            return MAX_CHIP_LEVEL
        case "weapon":
        case "grenade":
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

array function GetModColor( RoguelikeMod mod )
{
    if (mod.colorTag != "")
        return GetTitanColor( mod.colorTag )
    
    if (mod.loadouts.len() == 1 && mod.isTitan)
    {
        RoguelikeLoadout ornull loadout = Roguelike_GetLoadoutFromWeapon( mod.loadouts[0] )
        expect RoguelikeLoadout( loadout )
        return loadout.color
    }

    return [255,255,255,255]
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
        case "mp_titanweapon_sticky_40mm":
            return [32, 200, 32, 255]
        case "empty":
            return [127, 127, 127, 255]
    }

    return [255,255,255,255]
}

// first element is name, 2nd element is description
array<string> function GetTitanLoadoutPassiveData()
{
    return ["No Passive", "No passive is active for this loadout combination."]
}

