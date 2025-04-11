untyped
global function Daze_Init
global function GetLastDodgeTime
global function AddDaze
global function GetDaze
global function GetShotgunBuff
global function SetShotgunBuff

const int MAX_DAZE_STACKS = 3;
const int MAX_SHOTGUN_BUFF_STACKS = 4;

struct {
    float lastDodgeTime = -99.9
} file

void function Daze_Init()
{
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_leadwall, ShotgunDamage )
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_arc_wave, ArcWaveDamage )
    AddDamageCallbackSourceID( eDamageSourceId.melee_titan_sword, SwordDamage )
    AddDamageCallbackSourceID( eDamageSourceId.mp_titancore_shift_core, SwordCoreDamage )
	AddSpawnCallback( "player", PlayerDidLoad )
}

void function PlayerDidLoad( entity player )
{
	AddPlayerMovementEventCallback( player, ePlayerMovementEvents.DODGE, OnPlayerDodge )
}

void function OnPlayerDodge( entity player )
{
    print("dodge!")
    file.lastDodgeTime = Time()
    printt(player.GetVelocity())
    player.SetVelocity( <1000,0,100> )
    printt(player.GetVelocity())
    if (Roguelike_HasMod( player, "dash_iframes" ))
    {
        Remote_CallFunction_Replay( player, "ServerCallback_FlashCockpitInvulnerable" )
    }
}

float function GetLastDodgeTime()
{
    return file.lastDodgeTime
}

void function ShotgunDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    entity inflictor = DamageInfo_GetInflictor( damageInfo )

    if (ent.IsNPC() && attacker.IsPlayer() && IsValid(inflictor))
    {
        float damage = DamageInfo_GetDamage( damageInfo )
        float daze = StatusEffect_Get( ent, eStatusEffect.roguelike_daze )
        
        if (Roguelike_HasMod( attacker, "quickswap" ) && ("quickswap" in inflictor.s))
        {
            DamageInfo_AddDamageBonus( damageInfo, 1 ) // i think this is good?
            //dazeToAdd = 1.0 // max daze!
        }

        if (("buffed" in inflictor.s))
        {
            DamageInfo_ScaleDamage( damageInfo, 2.3333333 )
        }
        
        //AddDaze( ent, attacker, dazeToAdd )
    }
}

void function ArcWaveDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    if (ent.IsNPC() && attacker.IsPlayer())
    {
        float daze = StatusEffect_Get( ent, eStatusEffect.roguelike_daze )

        AddDaze( ent, attacker, 3 )

        if (Roguelike_HasMod( attacker, "conduction" ))
        {
            attacker.Server_SetDodgePower( attacker.GetDodgePower() + 50.0 )
        }
    }
}

void function SwordDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    if (!ent.IsNPC() || !attacker.IsPlayer())
        return

    float bonusDamage = 0.0

    bool crit = (DamageInfo_GetCustomDamageType( damageInfo ) & DF_CRITICAL) > 0
    
    int daze = GetDaze( ent )
    StatusEffect_StopAll( ent, eStatusEffect.roguelike_daze )
    SetShotgunBuff( attacker, GetShotgunBuff( attacker ) + daze + 1)
    
    if (Roguelike_HasMod( attacker, "offensive_daze_hits" ) && daze > 0)
    {
        printt("restoring")
        entity arcWave = attacker.GetOffhandWeapon( OFFHAND_ORDNANCE )
        RestoreCooldown( arcWave, 0.333 )

        if ("storedAbilities" in attacker.s && IsValid(attacker.s.storedAbilities[0]))
        {
            entity otherOffensive = expect entity(attacker.s.storedAbilities[OFFHAND_ORDNANCE])
            RestoreCooldown( otherOffensive, 0.333 )
        }
    }

    DamageInfo_AddDamageBonus(damageInfo, bonusDamage)
}

// give reduced multipliers for everything or swordcore becomes too strong
void function SwordCoreDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    if (ent.IsNPC() && attacker.IsPlayer())
    {
        float damageBonus = 0.0

        int daze = GetDaze( ent )
        StatusEffect_StopAll( ent, eStatusEffect.roguelike_daze )
        
        if (daze > 0 && Roguelike_HasMod( attacker, "sword_core_daze" ))
        {
            DamageInfo_AddDamageBonus( damageInfo, 0.5 )
            daze--
        }
        AddDaze( ent, attacker, daze )

        DamageInfo_AddDamageBonus( damageInfo, damageBonus )
    }
}

int function GetDaze( entity ent )
{
    return RoundToInt( StatusEffect_Get( ent, eStatusEffect.roguelike_daze ) * 255.0 )
}

int function GetShotgunBuff( entity ent )
{
    return RoundToInt( StatusEffect_Get( ent, eStatusEffect.roguelike_shotgun_buff ) * 255.0 )
}

void function SetShotgunBuff( entity ent, int amt )
{
    StatusEffect_StopAll( ent, eStatusEffect.roguelike_shotgun_buff )
    StatusEffect_AddEndless( ent, eStatusEffect.roguelike_shotgun_buff, min((amt + 0.001) / 255.0, MAX_SHOTGUN_BUFF_STACKS / 255.0) )
}

void function AddDaze( entity ent, entity attacker, int amount )
{
    float daze = StatusEffect_Get( ent, eStatusEffect.roguelike_daze )
    if (amount > 0.0)
    {
        int cur = GetDaze( ent )
        int overflow = (cur + amount) - MAX_DAZE_STACKS
        if (overflow > 0)
        {
            int curBuffStacks = GetShotgunBuff( attacker )
            SetShotgunBuff( attacker, curBuffStacks + overflow )
            amount -= overflow
        }

        StatusEffect_StopAll( ent, eStatusEffect.roguelike_daze )
        StatusEffect_AddEndless( ent, eStatusEffect.roguelike_daze, min((daze + amount + 0.001) / 255.0, MAX_DAZE_STACKS / 255.0) )
        printt(GetDaze(ent))
    }
}