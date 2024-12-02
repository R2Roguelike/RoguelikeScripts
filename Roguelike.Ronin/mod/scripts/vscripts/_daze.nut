untyped
global function Daze_Init
global function GetLastDodgeTime

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
        float dazeToAdd = 15.0 / 255.0
        if (dazeToAdd > 0.0)
        {
            StatusEffect_StopAll( ent, eStatusEffect.roguelike_daze )
            daze += dazeToAdd
            StatusEffect_AddTimed( ent, eStatusEffect.roguelike_daze, daze, 10.0 + daze * 5.0, daze * 5.0 )
        }
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
            dazeToAdd = 128.0 / 255.0
        }
        if (dazeToAdd > 0.0)
        {
            StatusEffect_StopAll( ent, eStatusEffect.roguelike_daze )
            daze += dazeToAdd
            StatusEffect_AddTimed( ent, eStatusEffect.roguelike_daze, daze, 10.0 + daze * 5.0, daze * 5.0 )
        }

        if (Roguelike_HasMod( attacker, "conduction" ))
        {
            attacker.Server_SetDodgePower( attacker.GetDodgePower() + 40.0 )
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
        damage /= Roguelike_GetTitanCooldownReduction( power )
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

    daze -= 0.5

    StatusEffect_AddTimed( ent, eStatusEffect.roguelike_daze, daze, 10.0 + daze * 5.0, daze * 5.0 )

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
            damage /= Roguelike_GetTitanCooldownReduction( power )
            DamageInfo_SetDamage( damageInfo, damage + 621.0 * blockIntensity )
        }

        float daze = StatusEffect_Get( ent, eStatusEffect.roguelike_daze )
        StatusEffect_StopAll( ent, eStatusEffect.roguelike_daze )
        
        DamageInfo_ScaleDamage( damageInfo, GraphCapped(daze, 0, 0.5, 1, 2) )

        daze -= 0.5

        StatusEffect_AddTimed( ent, eStatusEffect.roguelike_daze, daze, 10.0 + daze * 5.0, daze * 5.0 )

        print(Time() - file.lastDodgeTime)
        if (Roguelike_HasMod( attacker, "ronin_dash_melee") && Time() - file.lastDodgeTime <= 1.0)
        {
            DamageInfo_ScaleDamage( damageInfo, 1.345 )
            DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
        }
    }
}