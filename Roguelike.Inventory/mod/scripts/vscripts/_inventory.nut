untyped
global function Inventory_Init
global function Roguelike_GetModCount
global function Roguelike_HasMod
global function AddCallback_InventoryRefreshed
global function Roguelike_GetStat

struct {
    array<void functionref( entity )> onInventoryRefreshed
} file

void function Inventory_Init()
{
    AddClientCommandCallback( "RefreshInventory", CC_RefreshInventory )

    AddCallback_OnClientConnected( OnClientConnected )
    AddCallback_OnPilotBecomesTitan( EmbarkDisembarkInventoryRefresh )
    AddCallback_OnTitanBecomesPilot( EmbarkDisembarkInventoryRefresh )
}

void function EmbarkDisembarkInventoryRefresh( entity player, entity npc_titan )
{
    RefreshInventory( player )
}

void function OnClientConnected( entity player )
{
    RefreshInventory( player )
    
    AddPlayerMovementEventCallback( player, ePlayerMovementEvents.JUMP, OnPlayerJump )
}

void function OnPlayerJump( entity player )
{
}

void function RefreshInventory( entity player )
{
    string mods = expect string( player.GetUserInfoString("player_mods") )
    string stats = expect string( player.GetUserInfoString("player_stats") )

    array<string> modsList = split( mods, " " )
    array<string> statsList = split( stats, " " )

    player.s.mods <- []
    player.s.stats <- []

    foreach (string s in modsList)
    {
        if (s == "")
            continue
        
        int index = int( s )
        player.s.mods.append(index)
    }

    foreach (string s in statsList)
    {
        if (s == "")
            continue
        
        int value = int( s )
        player.s.stats.append(value)
    }

    foreach (void functionref( entity ) callback in file.onInventoryRefreshed)
        callback( player )
    
    
    foreach (entity w in player.GetMainWeapons())
    {
        if (w.GetWeaponClassName() == "mp_titanweapon_meteor")
        {
            if (Roguelike_HasMod( player, "flamethrower" ))
            {
                w.AddMod("flamethrower")
            }
            else
            {
                w.RemoveMod("flamethrower")
            }
        }
    }
}

void function AddCallback_InventoryRefreshed( void functionref( entity ) callback )
{
    file.onInventoryRefreshed.append(callback)
}

bool function CC_RefreshInventory( entity player, array<string> args )
{
    RefreshInventory( player )
    return true
}

int function Roguelike_GetModCount( entity player, string modName )
{
    if (!("mods" in player.s))
        return 0
    RoguelikeMod mod = GetModByName( modName )

    int result = 0
    foreach (var modIndex in player.s.mods)
    {
        if (modIndex == mod.index)
            result++
    }

    return result
}

bool function Roguelike_HasMod( entity player, string modName )
{
    if (!("mods" in player.s))
        return false
    RoguelikeMod mod = GetModByName( modName )

    int result = 0
    foreach (var modIndex in player.s.mods)
    {
        if (modIndex == mod.index)
            return true
    }

    return false
}

int function Roguelike_GetStat( entity player, int stat )
{
    return minint(expect int(player.s.stats[stat]), 100)
}
