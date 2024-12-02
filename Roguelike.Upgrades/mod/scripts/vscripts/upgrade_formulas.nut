globalize_all_functions

float function Roguelike_GetPilotHealthBonus( int endurance )
{
    return endurance / 100.0
}

float function Roguelike_GetPilotSpeedBonus( int speed )
{
    return speed / 125.0
}

float function Roguelike_GetTitanDamageMultiplier( int armor )
{
    return 9000.0 / (9000.0 + 50.0 * armor)
}

float function Roguelike_GetTitanDamageResist( int armor )
{
    return 1.0 - Roguelike_GetTitanDamageMultiplier( armor )
}

float function Roguelike_GetDashCooldownMultiplier( int energy )
{
    return pow(0.5, energy / 100.0) // at least this gives core lol
}

float function Roguelike_GetCoreGainBonus( int energy )
{
    return energy / 200.0
}

float function Roguelike_GetPilotCooldownReduction( int power )
{
    return pow(0.5, power / 180.0)
}

float function Roguelike_GetTitanCooldownReduction( int power )
{
    return pow(0.666, power / 100.0)
}
