global function AmpedShield_Init
global function Roguelike_PlayerDealtDamage

void function AmpedShield_Init()
{
    AddDamageCallback( "player", OnPlayerDamaged )
    AddCallback_OnPilotBecomesTitan( CheckShield )
    AddCallback_InventoryRefreshed( InventoryRefreshed )
}

void function CheckShield( entity player, entity titan )
{
    if (Roguelike_HasMod( player, "max_shield"))
        player.GetTitanSoul().SetShieldHealthMax(2000)
    else
        player.GetTitanSoul().SetShieldHealthMax(1000)
}

void function InventoryRefreshed( entity player )
{
    if (player.IsTitan())
    {
        player.SetMoveSpeedScale(1.0)
        int energy = Roguelike_GetStat( player, STAT_ENERGY )
		float cdReduction = Roguelike_GetDashCooldownMultiplier( energy )
        player.SetPowerRegenRateScale( 1.0 / cdReduction )
        CheckShield( player, player )
    }
    else
    {
        int endurance = Roguelike_GetStat( player, STAT_ENDURANCE )
        int speed = Roguelike_GetStat( player, STAT_SPEED )
        player.SetMaxHealth(100 * (1.0 + Roguelike_GetPilotHealthBonus( endurance )))

        if (player.ContextAction_IsBusy() || player.ContextAction_IsActive())
            player.SetHealth(player.GetMaxHealth())
        
        player.SetMoveSpeedScale(1.0 + Roguelike_GetPilotSpeedBonus( speed ))
    }
}

void function OnPlayerDamaged( entity player, var damageInfo )
{

    if (GetHealthFrac( player ) <= 0.5 && !player.IsTitan())
    {
        int stacks = Roguelike_GetModCount( player, "last_stand" )

        switch (stacks)
        {
            case 1:
                DamageInfo_ScaleDamage( damageInfo, 0.75 )
                break
            case 2:
                DamageInfo_ScaleDamage( damageInfo, 0.6 )
                break
            case 3:
                DamageInfo_ScaleDamage( damageInfo, 0.45 )
                break
            case 4:
                DamageInfo_ScaleDamage( damageInfo, 0.3 )
                break
        }
    }

    if (player.IsTitan())
        TitanDamageReductions( player, damageInfo )
    else
        PilotDamageReductions( player, damageInfo )
}

void function TitanDamageReductions( entity player, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    if (!IsValid(attacker))
        return
    
    if (!attacker.IsNPC())
        return
        
    if (attacker.IsTitan())
    {
        if (Roguelike_HasMod( player, "titan_aptitude" ))
        {
            DamageInfo_ScaleDamage( damageInfo, 0.6 )
        }
    }

    float sqrDist = DistanceSqr( attacker.GetOrigin(), player.GetOrigin() )
    if ( sqrDist < 393.7 * 393.7 ) // 10m
    {
        if (Roguelike_HasMod( player, "titan_brawler" ))
        {
            DamageInfo_ScaleDamage( damageInfo, 0.6 )
        }
    }

    if ( sqrDist > 1574 * 1574 ) // 40m
    {
        if (Roguelike_HasMod( player, "titan_long_range_resist" ))
        {
            DamageInfo_ScaleDamage( damageInfo, 0.6 )
        }
    }
}
void function PilotDamageReductions( entity player, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    if (!IsValid(attacker))
        return
    
    if (!attacker.IsNPC())
    {
        if (attacker == player)
        {
            if (Roguelike_HasMod( player, "masochist" ))
            {
                DamageInfo_ScaleDamage( damageInfo, 0.5 )
            }
            if (Roguelike_HasMod( player, "skull_emoji" ))
            {
                DamageInfo_ScaleDamage( damageInfo, 0.4 )
                float damage = DamageInfo_GetDamage( damageInfo )
                // hp - damage = 5
                // hp - 5
                DamageInfo_SetDamage( damageInfo, max(min(player.GetHealth() - 5, damage), 0) )
            }
        }
        return
    }
        
    if (attacker.IsTitan())
    {
        if (Roguelike_HasMod( player, "titan_aptitude" ))
        {
            DamageInfo_ScaleDamage( damageInfo, 0.6 )
        }
    }

    float sqrDist = DistanceSqr( attacker.GetOrigin(), player.GetOrigin() )
    if ( sqrDist < 196.8 * 196.8 ) // 5m
    {
        if (Roguelike_HasMod( player, "pilot_brawler" ))
        {
            DamageInfo_ScaleDamage( damageInfo, 0.6 )
        }
    }

    if ( sqrDist > 787.4 * 787.4 ) // 20m
    {
        if (Roguelike_HasMod( player, "pilot_long_range_resist" ))
        {
            DamageInfo_ScaleDamage( damageInfo, 0.6 )
        }
    }
}

void function Roguelike_PlayerDealtDamage( entity victim, entity player, var damageInfo )
{
    float damage = DamageInfo_GetDamage( damageInfo )
    if (DistanceSqr( victim.GetOrigin(), player.GetOrigin() ) < 196.8 * 196.8 && Roguelike_HasMod( player, "bloodthirst") )
    {
        player.SetHealth( min(player.GetMaxHealth(), player.GetHealth() + damage * 0.3) )
    }
}