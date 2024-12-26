untyped
global function Daze_Init
global function GetLastDodgeTime
global function AddDaze

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
}

float function GetLastDodgeTime()
{
    return file.lastDodgeTime
}

void function ShotgunDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )


    if (ent.IsNPC() && attacker.IsPlayer())
    {
        float daze = StatusEffect_Get( ent, eStatusEffect.roguelike_daze )
        float dazeToAdd = 20.0 / 255.0
        if (Roguelike_HasMod( attacker, "quickswap" ) && StatusEffect_Get( attacker, eStatusEffect.roguelike_ronin_quickswap ) > 0.0)
        {
            StatusEffect_StopAll( attacker, eStatusEffect.roguelike_ronin_quickswap ) // only one pellet gets to trigger the effect
            
            DamageInfo_SetDamage( damageInfo, DamageInfo_GetDamage( damageInfo ) + 1000 ) // i think this is good?
            dazeToAdd = 1.0 // max daze!
        }
        
        AddDaze( ent, attacker, dazeToAdd )
    }
}

void function ArcWaveDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    if (ent.IsNPC() && attacker.IsPlayer())
    {
        float daze = StatusEffect_Get( ent, eStatusEffect.roguelike_daze )
        float dazeToAdd = 0.0
        if (Roguelike_HasMod( attacker, "daze_arc_wave"))
        {
            AddDaze( ent, attacker, 128.0 / 255.0 )
        }

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

    float blockIntensity = StatusEffect_Get( attacker, eStatusEffect.roguelike_block_buff )
    if (blockIntensity > 0.0)
    {
        StatusEffect_StopAll( attacker, eStatusEffect.roguelike_block_buff )
        float damage = DamageInfo_GetDamage( damageInfo )
        int power = Roguelike_GetStat( attacker, STAT_POWER )
        DamageInfo_SetDamage( damageInfo, damage + 621.0 * blockIntensity )
    }

    float daze = StatusEffect_Get( ent, eStatusEffect.roguelike_daze )
    StatusEffect_StopAll( ent, eStatusEffect.roguelike_daze )
    
    if (Roguelike_HasMod( attacker, "offensive_daze_hits" ) && daze)
    {
        entity arcWave = attacker.GetOffhandWeapon( OFFHAND_ORDNANCE )
        RestoreCooldown( arcWave, GraphCapped(daze, 0, 0.5, 0, 0.333) )

        if ("storedAbilities" in attacker.s && IsValid(attacker.s.storedAbilities[0]))
        {
            entity otherOffensive = expect entity(attacker.s.storedAbilities[0])
            RestoreCooldown( otherOffensive, GraphCapped(daze, 0, 0.5, 0, 0.333) )
        }
    }

    DamageInfo_ScaleDamage( damageInfo, GraphCapped(daze, 0, 0.5, 1, 2) )

    if (GetTitanLoadoutFlags() == EXPEDITION_RONIN)
    {
        AddWeaken( ent, attacker, RoundToInt( GraphCapped(daze, 0, 0.5, 0, 10) ) )
    }

    daze -= 0.5

    StatusEffect_AddEndless( ent, eStatusEffect.roguelike_daze, daze )

    print(Time() - file.lastDodgeTime)
    if (Roguelike_HasMod( attacker, "ronin_dash_melee" ) && Time() - file.lastDodgeTime <= 1.0)
    {
        DamageInfo_ScaleDamage( damageInfo, 1.69 )
        DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
    }

}

// give reduced multipliers for everything or swordcore becomes too strong
void function SwordCoreDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    if (ent.IsNPC() && attacker.IsPlayer())
    {
        float blockIntensity = StatusEffect_Get( attacker, eStatusEffect.roguelike_block_buff )
        if (blockIntensity > 0.0)
        {
            StatusEffect_StopAll( attacker, eStatusEffect.roguelike_block_buff )
            float damage = DamageInfo_GetDamage( damageInfo )
            int power = Roguelike_GetStat( attacker, STAT_POWER )
            DamageInfo_SetDamage( damageInfo, damage + 621.0 * blockIntensity )
        }

        float daze = StatusEffect_Get( ent, eStatusEffect.roguelike_daze )
        StatusEffect_StopAll( ent, eStatusEffect.roguelike_daze )
        
        DamageInfo_ScaleDamage( damageInfo, GraphCapped(daze, 0, 0.5, 1, 2) )

        if (GetTitanLoadoutFlags() == EXPEDITION_RONIN)
        {
            AddWeaken( ent, attacker, RoundToInt( GraphCapped(daze, 0, 0.5, 0, 10) ) )
        }
        if (GetTitanLoadoutFlags() == SCORCH_RONIN)
        {
            AddBurn( ent, attacker, 150 )
        }

        daze -= 0.5

        StatusEffect_AddEndless( ent, eStatusEffect.roguelike_daze, daze )

        print(Time() - file.lastDodgeTime)
        if (Roguelike_HasMod( attacker, "ronin_dash_melee") && Time() - file.lastDodgeTime <= 1.0)
        {
            DamageInfo_ScaleDamage( damageInfo, 1.345 )
            DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
        }
    }
}

void function AddDaze( entity ent, entity attacker, float amount )
{
    float daze = StatusEffect_Get( ent, eStatusEffect.roguelike_daze )
    if (amount > 0.0)
    {
        StatusEffect_StopAll( ent, eStatusEffect.roguelike_daze )
        StatusEffect_AddEndless( ent, eStatusEffect.roguelike_daze, daze + amount )
    }
}