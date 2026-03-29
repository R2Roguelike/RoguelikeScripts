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

array<string> modCache = []
string modVal = ""

array<string> function Roguelike_GetModList( entity player )
{
    if (modVal != GetConVarString("player_mods"))
    {
        modVal = GetConVarString("player_mods")
        modCache = split( GetConVarString("player_mods"), " " )
        print("alloc")
    }
    
    if (!IsValid( player ))
        return []

    if (!player.IsPlayer())
        return []

    return modCache
}

bool function Roguelike_HasMod( entity player, string modName )
{
    if (modVal != GetConVarString("player_mods"))
    {
        modVal = GetConVarString("player_mods")
        modCache = split( GetConVarString("player_mods"), " " )
        print("alloc")
    }
    if (!IsValid(player))
        return false
    if (!player.IsPlayer())
        return false

    RoguelikeMod mod = GetModByName( modName )

    return modCache.contains(string(mod.index))
}

int function Roguelike_GetTagCount( entity player, string tag )
{
    if (modVal != GetConVarString("player_mods"))
    {
        modVal = GetConVarString("player_mods")
        modCache = split( GetConVarString("player_mods"), " " )
        print("alloc")
    }

    int result = 0
    foreach (string m in modCache)
    {
        RoguelikeMod mod = GetModForIndex(int(m))
        if (mod.tags.contains(tag))
            result++
    }
    return result
}

array<string> statsCache = []
string statsVal = ""
float function Roguelike_GetStat( entity player, string stat )
{
    if (statsVal != GetConVarString("player_stats"))
    {
        statsVal = GetConVarString("player_stats")
        statsCache = split( GetConVarString("player_stats"), " " )
        print("alloc")
    }
    
    RoguelikeStat statData = GetStatByName(stat)

    if (statsCache.len() <= statData.index)
        return statData.baseValue

    float baseVal = float(statsCache[statData.index])

    if (statData.diminishingReturns)
        return 1.0 / (1.0 + baseVal)

    return baseVal
}

array<string> datacoreCache
string datacoreVal = ""
bool function Roguelike_HasDatacorePerk( entity player, string perk )
{
    if (datacoreVal != GetConVarString("player_datacore"))
    {
        datacoreVal = GetConVarString("player_datacore")
        datacoreCache = split( GetConVarString("player_datacore"), " " )
        print("alloc")
    }
    if (player.IsPlayer() && player.IsTitan() && datacoreCache.len() > 1)
        return datacoreCache[1] == perk
    return false
}

float function Roguelike_GetDatacoreValue( entity player )
{
    if (datacoreVal != GetConVarString("player_datacore"))
    {
        datacoreVal = GetConVarString("player_datacore")
        datacoreCache = split( GetConVarString("player_datacore"), " " )
        print("alloc")
    }
    if (player.IsPlayer() && datacoreCache.len() > 1)
        return float( datacoreCache[2] )
    return 0.0
}
