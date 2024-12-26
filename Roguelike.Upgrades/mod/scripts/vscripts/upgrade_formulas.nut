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
    return 9000.0 / (7200.0 + 60.0 * armor)
}

float function Roguelike_GetTitanDamageResist( int armor )
{
    float resist = 1.2 - Roguelike_GetTitanDamageMultiplier( armor )
    resist /= 1.2
    return resist
}

float function Roguelike_GetDashCooldownMultiplier( int energy )
{
    return 1.2 * pow(0.5, energy / 100.0) // +20% cd when low, -40% when max
}

float function Roguelike_GetCoreGainBonus( int energy )
{
    return energy / 200.0 - 0.2
}

float function Roguelike_GetPilotCooldownReduction( int power )
{
    return 1.2 * pow(0.5, power / 100.0) // +20% cd when low, -40% when max
}

float function Roguelike_GetTitanCooldownReduction( int power )
{
    return 1.2 * pow(0.625, power / 100.0) // +20% when low, -25% when high
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

// first element is name, 2nd element is description
array<string> function GetTitanLoadoutPassiveData()
{
    switch (GetTitanLoadoutFlags())
    {
        case SCORCH_RONIN:
            return ["Sword of Flame",
            "Sword Core adds <burn>Burn</> on hit."]
        case EXPEDITION_RONIN:
            return ["Effect Cycle",
            "Whenever <daze>Daze</> is consumed, inflict <weak>Weaken</>. Whenever <weak>Weaken</> is consumed, inflict <daze>Daze</>."]
        case EXPEDITION_SCORCH:
            return ["Rearm the Furnace",
            "<weak>Weaken</> sources inflict <burn>Burn</> as well. Eruptions restore cooldown for <cyan>rearm</>."]
    }

    return ["No Passive", "No passive is active for this loadout combination."]
}
