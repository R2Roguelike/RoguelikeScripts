untyped
global function Burn_Init
global function RoguelikeScorch_IsPerfectDish
global function AddBurn
global function GetBurn

global array<int> BURN_DAMAGE_SOURCES = [
    eDamageSourceId.mp_titanweapon_heat_shield,
    eDamageSourceId.mp_titancore_flame_wave,
    eDamageSourceId.mp_titanweapon_flame_wall,
    eDamageSourceId.mp_titanability_slow_trap,
    eDamageSourceId.mp_titanweapon_meteor,
    eDamageSourceId.mp_titanweapon_meteor_thermite
]

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

    int burn = 2
    if (isFlamethrower)
    {
        //DamageInfo_ScaleDamage( damageInfo, 0.25 )
    }
    
    if (attacker == ent && Roguelike_HasMod( attacker, "warmth" ) && attacker.IsTitan())
    {
        DamageInfo_ScaleDamage( damageInfo, 0 )
        HealPlayer( attacker, 10 )
    }

    if (attacker != ent)
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

    if (attacker != ent)
    {
        if (inflictor.ProjectileGetMods().contains("flamethrower"))
            AddBurn( ent, attacker, 5 )
        else
            AddBurn( ent, attacker, 50 )
    }

    if (attacker == ent && Roguelike_HasMod( attacker, "warmth" ) && attacker.IsTitan())
    {
        DamageInfo_ScaleDamage( damageInfo, 0 )
        HealPlayer( attacker, 10 )
    }
}

void function FireTrapDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    if (!attacker.IsPlayer())
        return
        
    DamageInfo_ScaleDamage( damageInfo, 0.25 )

    int burn = 2
    if (Roguelike_HasMod( attacker, "offense_canister"))
    {
        DamageInfo_AddDamageBonus( damageInfo, 1.0 )
        burn = 5
    }

    if (attacker == ent && Roguelike_HasMod( attacker, "warmth" ) && attacker.IsTitan())
    {
        DamageInfo_ScaleDamage( damageInfo, 0 )
        HealPlayer( attacker, 10 )
    }

    if (attacker != ent)
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
    
    DamageInfo_ScaleDamage( damageInfo, 0.25 )

    if (isDashWall)
    {
        DamageInfo_AddDamageBonus( damageInfo, 1.0 )
    }

    int burn = 2
    
    if (attacker != ent)
        AddBurn( ent, attacker, burn )
}

void function HeatShieldDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    
    if (!attacker.IsPlayer())
        return

    DamageInfo_ScaleDamage( damageInfo, 0.5 )

    int burn = 2

    if (attacker != ent)
        AddBurn( ent, attacker, burn )
    
}

void function FlameWaveDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    
    if (!attacker.IsPlayer())
        return

    printt("shit")
    StatusEffect_StopAll( ent, eStatusEffect.roguelike_burn )
    DamageInfo_ScaleDamage( damageInfo, 0.25 ) // reduce base damage by 50%. were gonna cause eruptions lol
    StatusEffect_AddTimed( ent, eStatusEffect.roguelike_burn, 100.0 / 255.0, 15.0, 5.0 )
    if (Roguelike_HasMod( attacker, "again" ))
    StatusEffect_AddTimed( ent, eStatusEffect.roguelike_core_on_kill, 1.0, 15.0, 5.0 )

    Eruption( ent, attacker ) // always cause an eruption.
}

void function AddBurn( entity ent, entity attacker, int amount, float duration = 5.0 )
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

    int maxBaseBurn = 50

    if (Roguelike_HasMod( attacker, "high_temp"))
        maxBaseBurn += 25
    
    if (cur < maxBaseBurn)
    {
        StatusEffect_StopAll( ent, eStatusEffect.roguelike_burn )
        StatusEffect_AddTimed( ent, eStatusEffect.roguelike_burn, minint(cur + amount, maxBaseBurn) / 255.0, duration + 2.0, 2.0 )
    }

    if (cur >= 200)
    {
        // disabled atm
        //thread Eruption( ent, attacker )
    }
}

int function GetBurn( entity ent )
{
    return RoundToInt( StatusEffect_Get( ent, eStatusEffect.roguelike_burn ) * 255.0 )
}

// god help you.
void function Eruption( entity victim, entity attacker )
{
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
        1000,						// normal damage
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

    if (attacker == ent)
        DamageInfo_ScaleDamage( damageInfo, 0.3333 )
}

bool function RoguelikeScorch_IsPerfectDish( entity player, entity ent )
{
    if (!Roguelike_HasMod( player, "let_[insert_pronoun_here]_cook" ) )
        return false
    if (!player.IsTitan())
        return false

    return GetBurn( ent ) >= 50
}