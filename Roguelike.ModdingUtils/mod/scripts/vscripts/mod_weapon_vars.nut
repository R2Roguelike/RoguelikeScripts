untyped
global function ModWeaponVars_ScaleVar
global function AddCallback_ApplyModWeaponVars
global function CodeCallback_ApplyModWeaponVars
#if SERVER
global function CodeCallback_DoWeaponModsForPlayer
global function Roguelike_ResetTitanLoadoutFromPrimary
global function RestoreCooldown
#endif
#if CLIENT
global function CodeCallback_PredictWeaponMods
#endif
global function ScaleCooldown
global function Roguelike_GetOffhandWeaponByName

// doing overrides last 
global const int WEAPON_VAR_PRIORITY_OVERRIDE = 0
global const int WEAPON_VAR_PRIORITY_ADD = 100
global const int WEAPON_VAR_PRIORITY_MULT = 200

// these are utility global variables for easier setting of more "generic" things
// e.g. hipfire spread, ads spread

global const array<int> HIP_SPREAD_VARS = [eWeaponVar.spread_stand_hip, eWeaponVar.spread_stand_hip_run, eWeaponVar.spread_stand_hip_sprint,
    eWeaponVar.spread_crouch_hip, eWeaponVar.spread_air_hip, eWeaponVar.spread_kick_on_fire_air_hip, eWeaponVar.spread_kick_on_fire_stand_hip, 
    eWeaponVar.spread_kick_on_fire_crouch_hip, eWeaponVar.spread_max_kick_air_hip, eWeaponVar.spread_max_kick_stand_hip, 
    eWeaponVar.spread_max_kick_crouch_hip, eWeaponVar.spread_wallrunning, eWeaponVar.spread_wallhanging] // wallhanging is "ads" but aaplies spread on the level of hipfire? keeping it here.

    
global const array<int> SPREAD_KICK_VARS = [eWeaponVar.spread_kick_on_fire_air_hip, eWeaponVar.spread_kick_on_fire_stand_hip, 
    eWeaponVar.spread_kick_on_fire_crouch_hip, eWeaponVar.spread_max_kick_air_hip, eWeaponVar.spread_max_kick_stand_hip, 
    eWeaponVar.spread_max_kick_crouch_hip, eWeaponVar.spread_kick_on_fire_air_ads, eWeaponVar.spread_kick_on_fire_stand_ads, eWeaponVar.spread_kick_on_fire_crouch_ads, 
    eWeaponVar.spread_max_kick_air_ads, eWeaponVar.spread_max_kick_stand_ads, eWeaponVar.spread_max_kick_crouch_ads] // wallhanging is "ads" but aaplies spread on the level of hipfire? keeping it here.

global const array<int> ADS_SPREAD_VARS = [eWeaponVar.spread_stand_ads, eWeaponVar.spread_crouch_ads, eWeaponVar.spread_air_ads, 
    eWeaponVar.spread_kick_on_fire_air_ads, eWeaponVar.spread_kick_on_fire_stand_ads, eWeaponVar.spread_kick_on_fire_crouch_ads, 
    eWeaponVar.spread_max_kick_air_ads, eWeaponVar.spread_max_kick_stand_ads, eWeaponVar.spread_max_kick_crouch_ads]

global const array<int> RELOAD_TIME_VARS = [eWeaponVar.reload_time, eWeaponVar.reloadempty_time,
eWeaponVar.reload_time_late1, eWeaponVar.reload_time_late2, eWeaponVar.reload_time_late3, eWeaponVar.reload_time_late4, 
eWeaponVar.reload_time_late5, eWeaponVar.reloadempty_time_late1, eWeaponVar.reloadempty_time_late2, eWeaponVar.reloadempty_time_late3, 
eWeaponVar.reloadempty_time_late4, eWeaponVar.reloadempty_time_late5, eWeaponVar.reloadsegment_time_loop,
eWeaponVar.reloadsegment_time_end, eWeaponVar.reloadsegmentempty_time_end]

global enum WeaponVarType
{
    INTEGER = 1,
    FLOAT = 2,
    BOOLEAN = 3,
    STRING = 4,
    ASSET = 5,
    VECTOR = 6,
    SPECIAL
}

struct CallbackArray
{
    int priority
    array<void functionref( entity )> callbacks
}

struct
{
    array<CallbackArray> weaponVarCallbacks
} file

void function ModWeaponVars_ScaleVar( entity weapon, int weaponVar, float scalar )
{
    switch (ModWeaponVars_GetType(weaponVar))
    {
        case 1:
            ModWeaponVars_SetInt( weapon, weaponVar, int(RoundToNearestInt(weapon.GetWeaponSettingInt(weaponVar) * scalar) ) )
            break
        case 2:
            ModWeaponVars_SetFloat( weapon, weaponVar, weapon.GetWeaponSettingFloat(weaponVar) * scalar )
            break
        default:
            throw "WeaponVar is not of type int or float!"
            break
    }
}

int function SortByPriority( CallbackArray a, CallbackArray b )
{
    if (a.priority > b.priority)
        return 1
    else if (a.priority < b.priority)
        return -1
    
    return 0
}

// because order matters when applying weapon vars,
void function AddCallback_ApplyModWeaponVars( int priority, void functionref( entity ) callback )
{
    foreach (CallbackArray arr in file.weaponVarCallbacks)
    {
        if (arr.priority == priority)
        {
            arr.callbacks.append(callback)
        }
    }

    CallbackArray arr
    arr.priority = priority
    arr.callbacks = [ callback ]
    file.weaponVarCallbacks.append(arr)
    file.weaponVarCallbacks.sort(SortByPriority)
}

void function CodeCallback_ApplyModWeaponVars( entity weapon )
{
    #if CLIENT
    if (weapon.GetClassName() != "weaponx")
    {
        printt("entity of class " + weapon.GetClassName())
        return
    }
    
    if (weapon.GetWeaponOwner() != GetLocalClientPlayer())
        return
    #endif

    foreach (CallbackArray arr in file.weaponVarCallbacks)
    {
        foreach (void functionref( entity ) callback in arr.callbacks)
        {
            callback( weapon )
        }
    }
}

#if CLIENT
void function CodeCallback_PredictWeaponMods( entity weapon )
{
    if (!IsValid(weapon))
        return

    // avoids some visual glitches that happen if we set weaponmods
    // this is done here too to save performance
    if (weapon.GetWeaponPrimaryClipCount() == -1)
    {
        return
    }
    weapon.s.lastModsCalculatedTime <- Time()

    ModWeaponVars_CalculateWeaponMods( weapon )
}
#endif

#if SERVER
void function CodeCallback_DoWeaponModsForPlayer( entity weapon )
{
    string t = typeof(weapon)
    if (t.find("weaponx") == null)
    {
        printt(typeof(weapon), "is NOT a weaponx")
        return
    }

    if (!IsValid(weapon.GetWeaponOwner()))
        return

    entity player = weapon.GetWeaponOwner()

    if (!IsValid(player))
        return
    if (!player.IsPlayer())
        return
    if (!IsValid(player.GetActiveWeapon()))
        return

    if (player.IsOnGround())
    {
        player.s.lastGroundPosition <- player.GetOrigin()
        player.s.lastGroundAngles <- player.GetAngles()
    }

    if (IsValid(player.GetActiveWeapon()) && !player.GetActiveWeapon().IsWeaponOffhand() && player.IsTitan())
    {
        if (!("lastActiveWeapon" in player.s))
            player.s.lastActiveWeapon <- player.GetActiveWeapon().GetWeaponClassName()
        else if (player.GetActiveWeapon().GetWeaponClassName() != player.s.lastActiveWeapon)
        {
            if (Roguelike_HasMod( player, "quickswap" ))
            {
                StatusEffect_AddTimed( player, eStatusEffect.roguelike_ronin_quickswap, 1.0, 0.75, 0.0 )
            }
            Roguelike_ResetTitanLoadoutFromPrimary( player, player.GetActiveWeapon() )
            player.s.lastActiveWeapon <- player.GetActiveWeapon().GetWeaponClassName()
        }
    }
    player.s.lastModsCalculatedTime <- Time()
    // recalculating mods is kind of expensive -
    // expensive enough that doing it for all weapons
    // for all players is a bad idea. so offloading
    // mod recalculation responsibility to the modder is generally good.
    // we do it for the active weapon to not cause mispredictions
    // on the client. However, client does it every frame
    // for the active weapon, so we do too.
    foreach (entity weapon in player.GetMainWeapons())
        ModWeaponVars_CalculateWeaponMods( weapon )
    foreach (entity weapon in player.GetOffhandWeapons())
        ModWeaponVars_CalculateWeaponMods( weapon )
    if ("storedAbilities" in player.s && player.IsTitan())
        foreach (var weapon in player.s.storedAbilities)
        {
            if (weapon != null && IsValid(weapon))
            {
                expect entity(weapon)
                ModWeaponVars_CalculateWeaponMods( weapon )
            }
        }
}

void function Roguelike_ResetTitanLoadoutFromPrimary( entity titan, entity primary )
{
	Assert( titan.IsTitan() )
	Assert( IsAlive( titan ) )

//	EmitSoundOnEntity( player, "Coop_AmmoBox_AmmoRefill" )
	entity soul = titan.GetTitanSoul()
	// not a real titan, swapping in/out of titan etc
	if ( soul == null )
		return

    TitanLoadoutDef ornull titanLoadout = GetTitanLoadoutForPrimary( primary.GetWeaponClassName() )
    if ( titanLoadout == null )
        return
    expect TitanLoadoutDef( titanLoadout )

    //table<int,float> cooldowns = GetWeaponCooldownsForTitanLoadoutSwitch( titan )

    float coreValue = SoulTitanCore_GetNextAvailableTime( soul )

	StatusEffect_StopAll( titan, eStatusEffect.cockpitColor )
    //ReplaceTitanLoadoutWhereDifferent( titan, titanLoadout )
    if ((!("storedAbilities" in titan.s) || titan.s.storedAbilities[0] == null))
    {
        print("STORE EM")
        titan.s.storedAbilities <- [null, null, null, null, null, null]
        for ( int i = 0; i < OFFHAND_COUNT; i++ )
        {
            if (i == OFFHAND_INVENTORY) // ignore equipment
                continue
            if (!IsValid(titan.GetOffhandWeapon(i)))
                continue
            entity offhandWeapon = titan.TakeOffhandWeapon_NoDelete( i )
            
            if (IsValid(offhandWeapon))
            {
                offhandWeapon.s.storedWeaponOwner <- titan

                if (offhandWeapon.IsWeaponRegenDraining())
                {
                    offhandWeapon.s.exploitFix <- Time()
                }
            }

            // maintain offhand index
            titan.s.storedAbilities[i] = offhandWeapon
        }
        titan.GiveOffhandWeapon( titanLoadout.melee, OFFHAND_MELEE )
        titan.GiveOffhandWeapon( titanLoadout.ordnance, OFFHAND_ORDNANCE )
        titan.GiveOffhandWeapon( titanLoadout.special, OFFHAND_SPECIAL )
        titan.GiveOffhandWeapon( titanLoadout.antirodeo, OFFHAND_TITAN_CENTER )
        titan.GiveOffhandWeapon( titanLoadout.coreAbility, OFFHAND_EQUIPMENT )
    }
    else
    {
        for ( int i = 0; i < OFFHAND_COUNT; i++ )
        {
            if (i == OFFHAND_INVENTORY)
                continue
            
            entity offhandWeapon = titan.TakeOffhandWeapon_NoDelete( i )

            if (IsValid(offhandWeapon))
            {
                offhandWeapon.s.storedWeaponOwner <- titan

                if (offhandWeapon.IsWeaponRegenDraining())
                    offhandWeapon.s.exploitFix <- Time()
            }

            if (titan.s.storedAbilities[i] != null)
            {
                entity newOffhand = expect entity( titan.s.storedAbilities[i] )
                if (!IsValid(newOffhand))
                {
                    titan.GiveOffhandWeapon( GetOffhandWeaponBySlot( titanLoadout, i ), i )
                    newOffhand = titan.GetOffhandWeapon(i)
                }
                if ("storedWeaponOwner" in newOffhand.s)
                    delete newOffhand.s.storedWeaponOwner
                titan.GiveExistingOffhandWeapon( newOffhand, i )

                if ("exploitFix" in newOffhand.s)
                {
                    printt("exploit fix")
                    float timePassed = Time() - expect float(newOffhand.s.exploitFix)
                    delete newOffhand.s.exploitFix
                    timePassed -= newOffhand.GetWeaponSettingFloat(eWeaponVar.regen_ammo_refill_start_delay)
                    float newAmmo = timePassed * newOffhand.GetWeaponSettingFloat(eWeaponVar.regen_ammo_refill_rate)
                    printt(newAmmo)
                    
                    newOffhand.SetWeaponPrimaryClipCountAbsolute(clamp(newAmmo, 0, newOffhand.GetWeaponSettingInt(eWeaponVar.ammo_clip_size) + 0.0))
                }
            }
            // maintain offhand index
            titan.s.storedAbilities[i] = offhandWeapon
        }
    }

    foreach (entity w in titan.GetMainWeapons())
    {
        if (w.GetWeaponClassName() == "mp_titanweapon_meteor")
        {
            if (Roguelike_HasMod( titan, "flamethrower" ))
            {
                w.AddMod("flamethrower")
            }
            else
            {
                w.RemoveMod("flamethrower")
            }
        }
    }

    SoulTitanCore_SetNextAvailableTime( soul, coreValue )

    if ( titan.IsPlayer() )
    {
//			Remote_CallFunction_Replay( titan, "ServerCallback_NotifyLoadout", titan.GetEncodedEHandle() )
        Remote_CallFunction_Replay( titan, "ServerCallback_UpdateTitanModeHUD" )
    }
}

string function GetOffhandWeaponBySlot( TitanLoadoutDef titanLoadout, int offhandSlot)
{
    switch (offhandSlot)
    {
        case OFFHAND_ORDNANCE:
            return titanLoadout.ordnance
        case OFFHAND_SPECIAL:
            return titanLoadout.special
        case OFFHAND_MELEE:
            return titanLoadout.melee
        case OFFHAND_TITAN_CENTER:
            return titanLoadout.antirodeo
        case OFFHAND_EQUIPMENT:
            return titanLoadout.coreAbility
    }

    return ""
}

void function RestoreCooldown( entity weapon, float frac )
{
    if (!IsValid(weapon) || weapon.GetWeaponClassName() == "")
        return
    
    switch (weapon.GetWeaponInfoFileKeyField("cooldown_type"))
    {
        case "ammo":
        case "ammo_instant":
        case "ammo_deployed":
        case "ammo_timed":
            int ammo = weapon.GetWeaponPrimaryClipCount()
            int maxAmmo = weapon.GetWeaponPrimaryClipCountMax()
            weapon.SetWeaponPrimaryClipCountNoRegenReset( minint( ammo + RoundToInt(frac * maxAmmo), maxAmmo ) )
            break
        
        case "chargeFrac":
        case "vortex_drain":
            weapon.SetWeaponChargeFractionForced( weapon.GetWeaponChargeFraction() - frac )
            break
        
        case "shared_energy":
        case "shared_energy_drain":
            entity owner = weapon.GetWeaponOwner()
            if (!IsValid(owner))
                owner = GetPlayerArray()[0]
            
            owner.AddSharedEnergy( RoundToInt(frac * 1000) )
            break
        
        case "grapple":
            entity owner = weapon.GetWeaponOwner()
            if (!IsValid(owner))
                break
            owner.SetSuitGrapplePower( owner.GetSuitGrapplePower() + RoundToInt(frac * 100) )
            break
    }
}
#endif

entity function Roguelike_GetOffhandWeaponByName( entity player, string weapon )
{
    array<entity> currentOffhandWeapons = player.GetOffhandWeapons()

    foreach (entity w in currentOffhandWeapons)
        if (w.GetWeaponClassName() == weapon)
            return w
        
    foreach (var w in player.s.storedAbilities)
    {
        printt(w, typeof(w))
        if (w == null)
            continue
        if (w.GetWeaponClassName() == weapon)
            return expect entity(w)
    }

    return null
}

void function ScaleCooldown( entity weapon, float scalar )
{
    if (!IsValid(weapon) || weapon.GetWeaponClassName() == "")
        return
    
    switch (weapon.GetWeaponInfoFileKeyField("cooldown_type"))
    {
        case "ammo":
        case "ammo_instant":
        case "ammo_deployed":
        case "ammo_timed":
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.regen_ammo_refill_rate, 1.0 / scalar )
            break
        
        case "chargeFrac":
        case "vortex_drain":
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.charge_cooldown_time, scalar )
            break
        
        case "shared_energy":
            weapon.SetWeaponEnergyCost(RoundToInt(weapon.GetWeaponSettingInt(eWeaponVar.shared_energy_cost) * scalar))
            break
        
        case "grapple":
            ModWeaponVars_ScaleVar( weapon, eWeaponVar.grapple_power_required, scalar )
            break
    }
}