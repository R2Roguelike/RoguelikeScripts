untyped
global function Daze_Init
global function GetLastDodgeTime
global function AddDaze
global function GetDaze
global function GetShotgunBuff
global function SetShotgunBuff

const int MAX_DAZE_STACKS = 3;
const int MAX_SHOTGUN_BUFF_STACKS = 7;

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
    if (Roguelike_HasMod( player, "conduction" ))
    {
        entity offensive = player.GetOffhandWeapon(0)
        if (IsValid(offensive))
            RestoreCooldown( offensive, 0.1 )
    }
    if (Roguelike_HasDatacorePerk( player, "dash+" ))
    {
        RSE_Apply( player, RoguelikeEffect.dash_plus, 1.0, 2.0, 2.0 )
    }
    file.lastDodgeTime = Time()

    Remote_CallFunction_Replay( player, "ServerCallback_FlashCockpitInvulnerable", -0.7 )
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
        float daze = RSE_Get( ent, RoguelikeEffect.ronin_daze )

        if (Roguelike_HasMod( attacker, "quickswap" ) && ("quickswap" in inflictor.s))
        {
            DamageInfo_AddDamageBonus( damageInfo, 0.5 ) // i think this is good?
            //dazeToAdd = 1.0 // max daze!
        }

        if (("buffed" in inflictor.s))
        {
            DamageInfo_ScaleDamage( damageInfo, 2 )
        }

        //AddDaze( ent, attacker, dazeToAdd )
    }
}

void function ArcWaveDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    if (ent.IsNPC() && attacker.IsPlayer())
    {
        float daze = RSE_Get( ent, RoguelikeEffect.ronin_daze )

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

    int daze = RoundToInt(RSE_Stop( ent, RoguelikeEffect.ronin_daze ))
    SetShotgunBuff( attacker, GetShotgunBuff( attacker ) + daze + 1)

    if (Roguelike_HasMod( attacker, "offensive_daze_hits" ) && daze > 0)
    {
        entity arcWave = attacker.GetOffhandWeapon( OFFHAND_ORDNANCE )
        RestoreCooldown( arcWave, 0.333 )

        entity otherOffensive = Roguelike_GetAlternateOffhand( attacker, OFFHAND_ORDNANCE )
        if (IsValid( otherOffensive ))
            RestoreCooldown( otherOffensive, 0.333 )
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

        int daze = GetShotgunBuff( attacker )

        if (daze > 0 && Roguelike_HasMod( attacker, "overdaze" ))
        {
            DamageInfo_AddDamageBonus( damageInfo, 0.5 )
            daze--
        }
        
        SetShotgunBuff( attacker, daze )


        DamageInfo_AddDamageBonus( damageInfo, damageBonus )
    }
}

int function GetDaze( entity ent )
{
    return RoundToInt( RSE_Get( ent, RoguelikeEffect.ronin_daze ) )
}

int function GetShotgunBuff( entity ent )
{
    return RoundToInt( RSE_Get( ent, RoguelikeEffect.ronin_overload ) )
}

void function SetShotgunBuff( entity ent, int amt )
{
    int maxStacks = MAX_SHOTGUN_BUFF_STACKS
    if (ent.IsPlayer() && Roguelike_HasMod( ent, "overdaze" ))
        maxStacks = 99
    
    int curStacks = GetShotgunBuff( ent )
    amt = minint(amt, maxStacks)

    if (amt > curStacks)
    {
        string displayText = format("+%i Overload Shots!", amt - curStacks)
        if (ent.IsPlayer())
            ServerToClientStringCommand( ent, format("mod_activated +%i Overload Shots! 5 0 0.5 1", amt - curStacks) )
    }
    RSE_Apply( ent, RoguelikeEffect.ronin_overload, RoundToNearestInt(amt) )
}

void function AddDaze( entity ent, entity attacker, int amount )
{
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

        RSE_Apply( ent, RoguelikeEffect.ronin_daze, RoundToNearestInt(min(cur + amount, MAX_DAZE_STACKS)) )
    }
}