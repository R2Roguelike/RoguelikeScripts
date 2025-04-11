untyped
global function Inventory_Init
global function Roguelike_GetModCount
global function Roguelike_HasMod
global function AddCallback_InventoryRefreshed
global function Roguelike_GetStat
global function Roguelike_RefreshInventory

struct {
    array<void functionref( entity )> onInventoryRefreshed
} file

void function Inventory_Init()
{
    AddClientCommandCallback( "RefreshInventory", CC_RefreshInventory )

    AddCallback_OnClientConnected( OnClientConnected )
    AddCallback_OnLoadSaveGame( void function( entity player ) : () {
        delaythread(0.1) Roguelike_RefreshInventory( player )
    })
    //AddCallback_PlayerClassChanged( RefreshInventory )
}

void function OnClientConnected( entity player )
{
    RefreshInventory( player )

    AddPlayerMovementEventCallback( player, ePlayerMovementEvents.JUMP, OnPlayerJump )

    
    delaythread(0.1) void function() : (player) { wait 0.001; SetServerVar( "startTime", Time() ); RefreshInventory( player ) }()
    
}

void function Roguelike_RefreshInventory( entity player )
{
    RefreshInventory( player )
}

void function OnPlayerJump( entity player )
{
}

void function RefreshInventory( entity player )
{
    printt("refresh inventory")
    // should use GetUserInfoString, but we dont
    // cause it crashes when the player loads a save
    // :(
    string mods = GetConVarString("player_mods")
    string weapons = GetConVarString("player_weapons")
    string weaponPerks = GetConVarString("player_weapon_perks")
    string stats = GetConVarString("player_stats")

    array<string> modsList = split( mods, " " )
    array<string> statsList = split( stats, " " )
    // weapon mod1,mod2,mod3 weapon2 mod1,mod2,mod3
    array<string> weaponsList = split( weapons, " " )
    array<string> weaponPerksList = split( weaponPerks, " " )

    player.s.mods <- []
    player.s.stats <- []

    if (!player.IsTitan())
    {

        array<entity> mainWeapons = player.GetMainWeapons()
        bool shouldSwapWeapons = false
        for (int i = 0; i < 2; i++)
        {
            if (mainWeapons.len() < 2 && weaponsList.len() >= 2)
            {
                shouldSwapWeapons = true
                break
            }
            if (mainWeapons[i].GetWeaponClassName() != weaponsList[i])
                shouldSwapWeapons = true
        }

        if (shouldSwapWeapons)
        {
            foreach (entity mainWeapon in mainWeapons)
                player.TakeWeaponNow( mainWeapon.GetWeaponClassName() )
            
            for (int i = 0; i < weaponsList.len(); i++)
            {
                entity weapon = player.GiveWeapon(weaponsList[i])
            }
        }

    }
    foreach (string s in modsList)
    {
        if (s == "" || s == "0")
            continue
        
        int index = int( s )
        RoguelikeMod mod = GetModForIndex( index )
        player.s.mods.append(mod.uniqueName)
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
        if (w.GetWeaponClassName() == "mp_titanweapon_xo16_shorty")
        {
            if (Roguelike_HasMod( player, "xo16_accelerator" ))
            {
                w.AddMod("accelerator")
            }
            else
            {
                w.RemoveMod("accelerator")
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

    int result = 0
    foreach (var modIndex in player.s.mods)
    {
        if (modIndex == modName)
            result++
    }

    return result
}

bool function Roguelike_HasMod( entity player, string modName )
{
    if (!("mods" in player.s))
        return false

    return expect bool(player.s.mods.contains(modName))
}

int function Roguelike_GetStat( entity player, int stat )
{
    return minint(expect int(player.s.stats[stat]), 100)
}
