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
    RoguelikeMod mod = GetModByName( modName )

    return split( GetConVarString("player_mods"), " ").contains(string(mod.index))
}

int function Roguelike_GetStat( entity player, int stat )
{
    array<string> stats = split( GetConVarString("player_stats"), " " )

    return minint(int(stats[stat]), STAT_CAP) // capped at 100
}

bool function Roguelike_HasDatacorePerk( entity player, string perk )
{
    array<string> datacore = split( GetConVarString("player_datacore"), " " )
    if (player.IsPlayer() && datacore.len() > 1)
        return datacore[1] == perk
    return false
}
