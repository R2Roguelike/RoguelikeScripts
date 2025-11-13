untyped
global function Inventory_Init
global function Roguelike_GetModCount
global function Roguelike_HasMod
global function AddCallback_InventoryRefreshed
global function Roguelike_GetStat
global function Roguelike_RefreshInventory
global function Roguelike_HasDatacorePerk
global function Roguelike_PauseTimer
global function Roguelike_UnpauseTimer
global function Roguelike_SetTimerValue
global function Roguelike_GetDatacoreValue
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
    AddClientCommandCallback( "fuck2", CC_Fuck2 )

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

void function Roguelike_PauseTimer()
{
    if (GetServerVar("isTimerPaused"))
        throw "timer already paused"

    SetServerVar("timerValue", Time() - GetServerVar("startTime") )
    SetServerVar("isTimerPaused", true)
}
void function Roguelike_SetTimerValue( float value )
{
    if (!GetServerVar("isTimerPaused"))
    {
        SetServerVar("startTime", Time() - value )
        return
    }

    SetServerVar("timerValue", value )
}
void function Roguelike_UnpauseTimer()
{
    if (!GetServerVar("isTimerPaused"))
        throw "timer already unpaused"
    SetServerVar("startTime", Time() - GetServerVar("timerValue") )
    SetServerVar("isTimerPaused", false)
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
    string datacore = GetConVarString("player_datacore")

    array<string> modsList = split( mods, " " )
    array<string> statsList = split( stats, " " )
    // weapon mod1,mod2,mod3 weapon2 mod1,mod2,mod3
    array<string> weaponsList = split( weapons, " " )
    array<string> datacoreList = split( datacore, " " )

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
    if (datacoreList.len() > 2)
    {
        player.s.datacorePerk <- datacoreList[1]
        player.s.datacoreValue <- float(datacoreList[2])
    }
    else
        player.s.datacorePerk <- ""

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
            int inventoryIndex = 0
            entity existingWeapon = null
            foreach (entity mainWeapon in mainWeapons)
            {
                // oh my GOD how did he miss this AGAIN
                if (mainWeapon.GetWeaponClassName() == "sp_weapon_arc_tool")
                    continue
                if (!weaponsList.contains( mainWeapon.GetWeaponClassName() ))
                {
                    player.TakeWeaponNow( mainWeapon.GetWeaponClassName() )
                }
                else
                {
                    int index = weaponsList.find(mainWeapon.GetWeaponClassName())
                    if (mainWeapon.GetInventoryIndex() != index)
                    {
                        existingWeapon = mainWeapon
                        inventoryIndex = index
                        player.TakeWeapon_NoDelete( mainWeapon.GetWeaponClassName() )
                    }
                    weaponsList.remove(index)
                    weaponModsList.remove(index)
                }
            }

            if (inventoryIndex == 0 && existingWeapon != null)
            {
                player.GiveExistingWeapon( existingWeapon )
                existingWeapon.SetWeaponBurstFireCount(GetWeaponInfoFileKeyField_GlobalInt(existingWeapon.GetWeaponClassName(), "burst_fire_count"))
            }
            printt(weaponsList[0])
            for (int i = 0; i < weaponsList.len(); i++)
            {
                entity weapon = player.GiveWeapon(weaponsList[i], weaponModsList[i])
                ModWeaponVars_CalculateWeaponMods( weapon )
                printt(weapon.GetInventoryIndex())
                weapon.SetWeaponPrimaryClipCount(min(weapon.GetWeaponPrimaryClipCount(), weapon.GetWeaponPrimaryClipCountMax()))
            }
            if (inventoryIndex == 1 && existingWeapon != null)
            {
                player.GiveExistingWeapon( existingWeapon )
                ModWeaponVars_CalculateWeaponMods( existingWeapon )
                existingWeapon.SetWeaponBurstFireCount(GetWeaponInfoFileKeyField_GlobalInt(existingWeapon.GetWeaponClassName(), "burst_fire_count"))
                existingWeapon.SetWeaponPrimaryClipCount(min(existingWeapon.GetWeaponPrimaryClipCount(), existingWeapon.GetWeaponPrimaryClipCountMax()))
            }
        }

        entity ordnance = player.GetOffhandWeapon(0)
        string ordnanceName = ""
        int ammo = -1
        if (IsValid(ordnance))
        {
            ammo = ordnance.GetWeaponPrimaryClipCount()
            ordnanceName = ordnance.GetWeaponClassName()
        }
        if (ordnanceName != GetConVarString("player_ordnance"))
        {
            if (ordnanceName !="")
                player.TakeOffhandWeapon(0)
            
            player.GiveOffhandWeapon( GetConVarString("player_ordnance"), 0 )
            if (ammo != -1)
                player.GetOffhandWeapon(0).SetWeaponPrimaryClipCount(min(player.GetOffhandWeapon(0).GetWeaponPrimaryClipCountMax(), ammo))
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
        if (Roguelike_GetRunModifier("vanilla_movement"))
        {
            array<string> mods = player.GetPlayerSettingsMods()
            if (!mods.contains("vanilla"))
                mods.append("vanilla")
            player.SetPlayerSettingsWithMods(player.GetPlayerSettings(), mods)
            player.SetPlayerSettingPosMods(PLAYERPOSE_STANDING, ["vanilla"])
            player.SetPlayerSettingPosMods(PLAYERPOSE_CROUCHING, ["vanilla"])
        }
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
bool function CC_Fuck2( entity player, array<string> args )
{
    thread void function (entity player, array<string> args) : ()
    {
        while (true)
        {
            table results = player.WaitSignal( "OnPrimaryAttack" )
            entity weapon = expect entity(results.activator)
            print(weapon)
            foreach (k, v in weapon.GetMods())
                printt(k, v)
        }
    }(player, args)
    return true
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
    if (!IsValid( player ))
        return false
    if (!("mods" in player.s))
        return false

    return expect bool(player.s.mods.contains(modName))
}

int function Roguelike_GetStat( entity player, int stat )
{
    if (player.s.stats.len() < 8)
        return 0
    return minint(expect int(player.s.stats[stat]), STAT_CAP)
}

bool function Roguelike_HasDatacorePerk( entity player, string perk )
{
    if ("datacorePerk" in player.s)
        return player.s.datacorePerk == perk
    return false
}

float function Roguelike_GetDatacoreValue( entity player )
{
    if ("datacoreValue" in player.s)
        return expect float(player.s.datacoreValue)
    return 0.0
}
