untyped
global function Burn_Init
global function RoguelikeScorch_IsPerfectDish
global function AddBurn

void function Burn_Init()
{
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanability_slow_trap, FireTrapDamage )
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_meteor, FireWeaponDamage )
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_meteor_thermite, FireWeaponSmallDamage )
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_flame_wall, FireWallDamage )
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_heat_shield, HeatShieldDamage )
    AddDamageCallbackSourceID( eDamageSourceId.mp_titancore_flame_wave, FlameWaveDamage )
    AddDamageCallbackSourceID( damagedef_nuclear_core, EruptionDamage )
}

void function FireWeaponSmallDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    if (!attacker.IsPlayer())
        return
        
    entity inflictor = DamageInfo_GetInflictor( damageInfo )

    DamageInfo_ScaleDamage( damageInfo, 0.5 )

    bool isFlamethrower = "flamethrower" in inflictor.s

    int burn = 5
    if (isFlamethrower)
    {
        DamageInfo_ScaleDamage( damageInfo, 0.25 )
        burn = 2
    }

    if (attacker != ent || Roguelike_HasMod( attacker, "self_burn" ))
    {
        AddBurn( ent, attacker, burn )
    }
}

void function FireWeaponDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    if (!attacker.IsPlayer())
        return

    entity inflictor = DamageInfo_GetInflictor( damageInfo )

    if (attacker != ent || Roguelike_HasMod( attacker, "self_burn" ))
    {
        if (inflictor.ProjectileGetMods().contains("flamethrower"))
            AddBurn( ent, attacker, 3 )
        else
            AddBurn( ent, attacker, 25 )
    }
}

void function FireTrapDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    if (!attacker.IsPlayer())
        return
        
    DamageInfo_ScaleDamage( damageInfo, 0.75 )

    int burn = 3
    if (Roguelike_HasMod( attacker, "offense_canister"))
        DamageInfo_ScaleDamage( damageInfo, 2.0 )
    if (Roguelike_HasMod( attacker, "concentrated_canister" ))
        burn = 6

    if (attacker != ent || Roguelike_HasMod( attacker, "self_burn" ))
        AddBurn( ent, attacker, burn )
}

void function FireWallDamage( entity ent, var damageInfo )
{
    entity inflictor = DamageInfo_GetInflictor( damageInfo )
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    
    if (!attacker.IsPlayer() || !IsValid( inflictor ))
        return

    bool isHighWall = "highWall" in inflictor.s
    bool isDashWall = "dashWall" in inflictor.s
    
    int wallPower = 0
    if (isHighWall)
        wallPower++
    
    if (isDashWall)
    {
        DamageInfo_ScaleDamage( damageInfo, 1.5 )
    }
    else
        DamageInfo_ScaleDamage( damageInfo, 0.75 )

    int burn = 4 + wallPower * 4
    
    if (attacker != ent || Roguelike_HasMod( attacker, "self_burn" ))
        AddBurn( ent, attacker, burn )
}

void function HeatShieldDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    
    if (!attacker.IsPlayer())
        return

    DamageInfo_ScaleDamage( damageInfo, 0.75 )

    int burn = 7
    
    if (attacker != ent || Roguelike_HasMod( attacker, "self_burn" ))
        AddBurn( ent, attacker, burn )
    
}

void function FlameWaveDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    
    if (!attacker.IsPlayer())
        return

    DamageInfo_ScaleDamage( damageInfo, 0.5 ) // reduce base damage by 50%. were gonna cause eruptions lol

    Eruption( ent, attacker ) // always cause an eruption. reset the counter
}

void function AddBurn( entity ent, entity attacker, int amount )
{
    if (amount <= 0)
        return

    if (attacker.IsPlayer() && Roguelike_HasMod(attacker, "gas_recycle"))
    {
        entity canister = Roguelike_GetOffhandWeaponByName( attacker, "mp_titanability_slow_trap" )
        int ammo = canister.GetWeaponPrimaryClipCount()
        int maxAmmo = canister.GetWeaponPrimaryClipCountMax()
        printt("restoring", maxint(amount / 3, 1))
        if (canister != null)
            canister.SetWeaponPrimaryClipCountNoRegenReset( minint(canister.GetWeaponPrimaryClipCount() + maxint(amount / 4, 1), maxAmmo) )
    }

    int cur = GetBurn( ent )
    StatusEffect_StopAll( ent, eStatusEffect.roguelike_burn )
    cur += amount
    StatusEffect_AddEndless( ent, eStatusEffect.roguelike_burn, cur / 255.0 )

    if (cur >= 200)
    {
        thread Eruption( ent, attacker )
    }
}

int function GetBurn( entity ent )
{
    return RoundToInt( StatusEffect_Get( ent, eStatusEffect.roguelike_burn ) * 255.0 )
}

// god help you.
void function Eruption( entity victim, entity attacker )
{
    StatusEffect_StopAll( victim, eStatusEffect.roguelike_burn )
    if (victim.IsPlayer())
    {
        Remote_CallFunction_Replay( __p(), "ServerCallback_ScreenShake", 6, 100, 4.0 )
        EmitSoundOnEntity( victim, "titan_nuclear_death_charge" )
        wait 3.0
    }
    vector origin = victim.GetOrigin()

    victim.s.burnt <- true

    PlayFX( TITAN_NUCLEAR_CORE_FX_3P, origin + Vector( 0, 0, -10 ), Vector(0,RandomInt(360),0) )

    EmitSoundAtPosition( TEAM_ANY, origin, "titan_nuclear_death_explode" )

    if (GetTitanLoadoutFlags() == EXPEDITION_SCORCH)
    {
        entity rearm = Roguelike_GetOffhandWeaponByName( attacker, "mp_titanability_rearm" )
        if (rearm != null)
            RestoreCooldown( rearm, 0.2 )
    }

	entity inflictor = CreateEntity( "script_ref" )
	inflictor.SetOrigin( origin )
	inflictor.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
    inflictor.s.eruption <- true
	DispatchSpawn( inflictor )
    
    float titanDamage = 2000
    if (victim == attacker)
    {
        titanDamage = 3000
    }
    RadiusDamage_DamageDef( damagedef_nuclear_core,
        origin,								// origin
        attacker,						// owner
        inflictor,							// inflictor
        300,						// normal damage
        titanDamage,					// heavy armor damage
        500,						// inner radius
        750,						// outer radius
        0 )									// dist from attacker

    inflictor.Destroy()
}

void function EruptionDamage( entity ent, var damageInfo )
{
    entity inflictor = DamageInfo_GetInflictor( damageInfo )
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    if (!attacker.IsPlayer() || !IsValid( inflictor ))
        return
    if (!("eruption" in inflictor.s))
        return

    DamageInfo_ScaleDamage( damageInfo, 0.5 )

    if (attacker == ent && Roguelike_HasMod( attacker, "self_burn" ))
        DamageInfo_ScaleDamage( damageInfo, 0.3333 )
}

bool function RoguelikeScorch_IsPerfectDish( entity player, entity ent )
{
    if (!Roguelike_HasMod( player, "let_[insert_pronoun_here]_cook" ) )
        return false
    if (!player.IsTitan())
        return false
    if ("burnt" in ent.s)
        return false

    return GetBurn( ent ) >= 100
}