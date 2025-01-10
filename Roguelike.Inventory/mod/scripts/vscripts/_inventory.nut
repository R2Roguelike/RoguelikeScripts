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
    AddCallback_PlayerClassChanged( RefreshInventory )
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
    string weapons = expect string( player.GetUserInfoString("player_weapons") )
    string weaponPerks = expect string( player.GetUserInfoString("player_weapon_perks") )
    string stats = expect string( player.GetUserInfoString("player_stats") )

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
