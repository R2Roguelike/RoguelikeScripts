untyped
global function Inventory_Init
global function Roguelike_GetModCount
global function Roguelike_HasMod
global function AddCallback_InventoryRefreshed
global function Roguelike_GetStat
global function Roguelike_RefreshInventory
global function CC_Fuck

struct {
    array<void functionref( entity )> onInventoryRefreshed
} file

void function Inventory_Init()
{
    RegisterSignal("UnfreezeAll")
    AddClientCommandCallback( "RefreshInventory", CC_RefreshInventory )
    AddClientCommandCallback( "notarget", CC_NoTarget )
    AddClientCommandCallback( "freezeall", CC_FreezeAll )
    //AddClientCommandCallback( "fuck", CC_Fuck )

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
    AddPlayerMovementEventCallback( player, ePlayerMovementEvents.DOUBLE_JUMP, OnPlayerDoubleJump )
    AddPlayerMovementEventCallback( player, ePlayerMovementEvents.DODGE, OnPlayerDodge )


    delaythread(0.1) void function() : (player) { wait 0.001; SetServerVar( "startTime", Time() ); RefreshInventory( player ) }()

}

void function Roguelike_RefreshInventory( entity player )
{
    RefreshInventory( player )
}

vector function GetDirectionFromInput( vector playerAngles, float xAxis, float yAxis )
{
	playerAngles.x = 0
	playerAngles.z = 0
	vector forward = AnglesToForward( playerAngles )
	vector right = AnglesToRight( playerAngles )

	vector directionVec = Vector(0,0,0)
	directionVec += right * xAxis
	directionVec += forward * yAxis

	vector directionAngles = VectorToAngles( directionVec )
	vector directionForward = AnglesToForward( directionAngles )

	return directionForward
}

void function OnPlayerJump( entity player )
{
}
void function OnPlayerDodge( entity player )
{
    if (player.IsTitan())
        return

    printt("shit")
    EmitSoundOnEntity( player, "tone_dash_1p" )
    player.TouchGround() // restore double jump and stuff
}
void function OnPlayerDoubleJump( entity player )
{
    if (!Roguelike_HasMod( player, "triplejump" ))
        player.ConsumeDoubleJump() // prevent triple jump
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
    string weaponMods = GetConVarString("player_weapon_mods")
    string stats = GetConVarString("player_stats")

    array<string> modsList = split( mods, " " )
    array<string> statsList = split( stats, " " )
    // weapon mod1,mod2,mod3 weapon2 mod1,mod2,mod3
    array<string> weaponsList = split( weapons, " " )

    array< array<string> > weaponModsList = [ ]
    weaponModsList.append([])
    weaponModsList.append([])

    foreach (int i, string s in split( weaponMods, " " ))
    {
        array<string> man = split(s, ",")
        weaponModsList[i] = man
    }

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
            int weaponsTaken = 2
            foreach (entity mainWeapon in mainWeapons)
            {
                // oh my GOD how did he miss this AGAIN
                if (mainWeapon.GetWeaponClassName() == "sp_weapon_arc_tool")
                    continue
                if (!weaponsList.contains( mainWeapon.GetWeaponClassName() ))
                {
                    player.TakeWeaponNow( mainWeapon.GetWeaponClassName() )
                    weaponsTaken--
                }
                else
                {
                    int index = weaponsList.find(mainWeapon.GetWeaponClassName())
                    weaponsList.remove(index)
                    weaponModsList.remove(index)
                }
            }

            for (int i = 0; i < weaponsList.len(); i++)
            {
                entity weapon = player.GiveWeapon(weaponsList[i], weaponModsList[i])
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

    if (!player.IsTitan() && player.GetPlayerSettings() != "spectator")
    {
        switch (Roguelike_GetRunModifier("unwalkable"))
        {
            case 1:
                player.SetPlayerSettingPosMods(PLAYERPOSE_STANDING, ["75_speed"])
                player.SetPlayerSettingPosMods(PLAYERPOSE_CROUCHING, ["75_speed"])
                break
            case 2:
                player.SetPlayerSettingPosMods(PLAYERPOSE_STANDING, ["50_speed"])
                player.SetPlayerSettingPosMods(PLAYERPOSE_CROUCHING, ["50_speed"])
                break
            case 3:
                player.SetPlayerSettingPosMods(PLAYERPOSE_STANDING, ["25_speed"])
                player.SetPlayerSettingPosMods(PLAYERPOSE_CROUCHING, ["25_speed"])
                break
        }
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
bool function CC_Fuck( entity player, entity target )
{
    thread void function () : (player, target)
    {
        target.EndSignal("OnDeath")
        target.EndSignal("OnDestroy")
        entity cpEnd = CreateEntity( "info_placement_helper" )
        SetTargetName( cpEnd, UniqueString( "balls" ) )
        cpEnd.SetOrigin( target.GetOrigin() + <0, 0, 3000> )
        DispatchSpawn( cpEnd )

        array<entity> fx = []
        const int COUNT = 150
        for (int i = 0; i < COUNT; i++)
        {
            float rightOffset = deg_sin(i * 360.0 / COUNT) * 100
            float forwardOffset = deg_cos(i * 360.0 / COUNT) * 100

            entity fxHandle = CreateEntity( "info_particle_system" )
            fxHandle.SetValueForEffectNameKey( $"P_wpn_lasercannon" )
            fxHandle.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
            fxHandle.kv.start_active = 0
            fxHandle.kv.cpoint1 = cpEnd.GetTargetName()
            fxHandle.SetOrigin( target.GetOrigin() + <0,1,0> * forwardOffset + <1,0,0> * rightOffset - <0,0,100> )
            fxHandle.SetAngles( <0,0,0> )
            DispatchSpawn(fxHandle)
            
            fx.append(fxHandle)
        }


        EmitSoundOnEntity( player, "Titan_Core_Laser_FireBeam_1P_extended" )
        EmitSoundOnEntity( player, "Titan_Core_Laser_FireStart_1P" )
        for (int i = 0; i < COUNT; i++)
        {
            fx[i].Fire( "Start" )
        }


        OnThreadEnd( void function() : (cpEnd, player, fx)
        {
            foreach (entity fxHandle in fx)
            {
            fxHandle.Fire( "Stop" )
            fxHandle.Fire( "DestroyImmediately" )
            fxHandle.Destroy()
            }
            if (IsValid(cpEnd))
            {
                cpEnd.Destroy()
            }
            StopSoundOnEntity( player, "Titan_Core_Laser_FireStart_1P" )
            StopSoundOnEntity( player, "Titan_Core_Laser_FireBeam_1P_extended" )
        } )
        float endTime = Time() + 5
        while (Time() < endTime)
        {
            int i =0
            foreach (entity fxHandle in fx)
            {
                float rightOffset = deg_sin(i * 360.0 / COUNT) * 100
                float forwardOffset = deg_cos(i * 360.0 / COUNT) * 100
                fxHandle.SetOrigin( target.GetOrigin() + <1,0,0> * rightOffset + <0,1,0> * forwardOffset - <0,0,100> )
                i++
            }
            target.TakeDamage( 100, player, player, { damageSourceId = eDamageSourceId.mp_titancore_laser_cannon, origin = target.GetWorldSpaceCenter() })
            wait 0.01
        }
    }()
    return true
}

void function LaserSegment( vector origin, vector dir, entity cpEnd, entity player, array<entity> ignore )
{
    entity fxHandle = CreateEntity( "info_particle_system" )
    fxHandle.SetValueForEffectNameKey( $"P_wpn_lasercannon" )
    fxHandle.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
    fxHandle.kv.start_active = 1
    fxHandle.kv.cpoint1 = cpEnd.GetTargetName()
    fxHandle.SetOrigin( origin )
    fxHandle.SetAngles( <0,0,0> )
    DispatchSpawn( fxHandle )



    OnThreadEnd( void function() : (fxHandle)
    {
        if (IsValid(fxHandle))
        {
            fxHandle.Fire( "Stop" )
            fxHandle.Fire( "DestroyImmediately" )
            fxHandle.Destroy()
        }
    } )

    float startTime = Time()

    float endTime = Time() + 3
    while (Time() < endTime)
    {
        wait 0
    }

}
bool function CC_NoTarget( entity player, array<string> args )
{
    if (!GetConVarBool("sv_cheats"))
        return false

    player.SetNoTarget( !player.GetNoTarget() )
    printt("notarget set to", player.GetNoTarget())

    return true
}

bool freezeall = false
bool function CC_FreezeAll( entity player, array<string> args )
{
    if (!GetConVarBool("sv_cheats"))
        return false

    printt("freeze!")
    player.SetNoTarget( true )
    foreach (entity npc in GetNPCArrayEx( "any", TEAM_ANY, TEAM_ANY, player.GetOrigin(), 65536.0 ))
        thread FreezeNPC(npc)

    return true
}

void function FreezeNPC( entity npc )
{
	npc.DisableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE )
    npc.ClearEnemy()
    npc.ClearEnemyMemory()
	npc.SetNoTarget( true )
    npc.EnableNPCFlag( NPC_IGNORE_ALL )
	npc.EnableNPCFlag( NPC_DISABLE_SENSING )	// don't do traces to look for enemies or players

    svGlobal.worldspawn.EndSignal("UnfreezeAll")
    npc.EndSignal("OnDeath")

    WaitForever()
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
    return minint(expect int(player.s.stats[stat]), STAT_CAP)
}
