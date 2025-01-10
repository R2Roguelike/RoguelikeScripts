untyped
globalize_all_functions

void function Roguelike_ItemAcquired( table item )
{
    printt(item)
}

int function Roguelike_GetModCount( entity player, string modName )
{
    array<string> modsArr = split( GetConVarString("player_mods"), " ")
    RoguelikeMod mod = GetModByName( modName )

    int result = 0
    foreach (string modIndex in modsArr)
    {
        if (int( modIndex ) == mod.index)
            result++
    }

    return result
}

bool function Roguelike_HasMod( entity player, string modName )
{
    array<string> modsArr = split( GetConVarString("player_mods"), " ")

    RoguelikeMod mod = GetModByName( modName )

    int result = 0
    foreach (string modIndex in modsArr)
    {
        if (int( modIndex ) == mod.index)
            return true
    }

    return false
}

int function Roguelike_GetStat( entity player, int stat )
{
    array<string> stats = split( GetConVarString("player_stats"), " " )

    return minint(int(stats[stat]), 100) // capped at 100
}
