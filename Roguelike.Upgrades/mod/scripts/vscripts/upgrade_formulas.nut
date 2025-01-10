globalize_all_functions

float function Roguelike_GetPilotHealthBonus( int endurance )
{
    return endurance / 100.0 - 0.2
}

float function Roguelike_GetPilotSpeedBonus( int speed )
{
    return speed / 125.0
}

float function Roguelike_GetTitanDamageMultiplier( int armor )
{
    return 9000.0 / (7500.0 + 60.0 * armor)
}

float function Roguelike_GetTitanDamageResist( int armor )
{
    float resist = 1.2 - Roguelike_GetTitanDamageMultiplier( armor )
    resist /= 1.2
    return resist
}

// -90% dash cooldown? why the fuck not...
float function Roguelike_GetDashCooldownMultiplier( int energy )
{
    //return Graph( energy, 0, 150, 1.2, 0.1 )
    return 1.2 * pow(0.3, energy / 100.0) // +20% cd when low, -90% when max
}

float function Roguelike_GetCoreGainBonus( int energy )
{
    return energy / 200.0 - 0.2
}

float function Roguelike_GetPilotCooldownReduction( int power )
{
    return 1.2 * pow(0.4, power / 100.0) // +20% cd when low, -40% when max
}

float function Roguelike_GetTitanCooldownReduction( int power )
{
    return 1.2 * pow(0.4, power / 100.0) // +20% when low, -25% when high
}

// bitwise OR of two bits corresponding to titan loadouts
// used for knowing which combination of loadouts we're using, regardless of order
// e.g. scorch + ronin = 0x4 | 0x10 = 0x14
int function GetTitanLoadoutFlags()
{
    array<string> titanLoadouts = Roguelike_GetTitanLoadouts()
    return TITAN_BITS[titanLoadouts[0]] | TITAN_BITS[titanLoadouts[1]]
}

bool function Roguelike_PlayerHasLoadout(string weapon)
{
    return Roguelike_GetTitanLoadouts().contains(weapon)
}

int function Roguelike_GetUpgradePrice( table item )
{
    int level = expect int(item.level)
    int price = 50 + (level * 25) + expect int(item.priceOffset)

    return price
}

int function Roguelike_GetItemMaxLevel( table item )
{
    switch (item.type)
    {
        case "armor_chip":
            return MAX_CHIP_LEVEL
        case "weapon":
            int rarity = expect int(item.rarity)
            return 3
    }

    return 0
}

// first element is name, 2nd element is description
array<string> function GetTitanLoadoutPassiveData()
{
    switch (GetTitanLoadoutFlags())
    {
        case SCORCH_RONIN:
            return ["Early Ignition",
            "<cyan>Arc Wave</> causes enemies over 75% <burn>Burn</> on to immediately <burn>Erupt</>. Eruptions caused by Arc Wave <daze>Daze</> nearby enemies."]
        case EXPEDITION_RONIN:
            return ["weakling executioner",
            "Your sword deals increased damage to <weak>Weak</> enemies. Consumed <daze>Daze</> is converted into <cyan>Missile cooldown</>"]
        case EXPEDITION_SCORCH:
            return ["Portal",
            "<burn>Heat Shield</> absorbs. <cyan>Vortex Shield</> releases."]
    }

    return ["No Passive", "No passive is active for this loadout combination."]
}
