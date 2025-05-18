untyped
global function AmpedShield_Init
global function Roguelike_PlayerDealtDamage
global function Roguelike_PlayerUsedOffhand
global function Roguelike_IsWeaponDamage

void function AmpedShield_Init()
{
    AddDamageCallback( "player", OnPlayerDamaged )
    AddCallback_OnPilotBecomesTitan( CheckShield )
    AddCallback_InventoryRefreshed( InventoryRefreshed )
    AddCallback_OnClientConnected( OnClientConnected )

    AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_shotgun, ShotgunDamage )
    AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_mastiff, ShotgunDamage )
    AddCallback_OnTitanDoomed( OnTitanDoomed )
}

void function OnClientConnected( entity player) 
{
    if (!Roguelike_GetRunModifier("memory"))
        return
    
    thread void function() : (player)
    {
        bool setHP = false
        while (true)
        {
            // this is fucked
            if (!setHP)
            {
                int hp = GetConVarInt("memory_titan_hp")
                if (player.IsTitan())
                {
                    if (hp != -1)
                    {
                        player.SetHealth(hp)
                        if (GetConVarString("memory_titan_settings") != "")
                        {
                            array<string> mods = player.GetPlayerSettingsMods()
                            mods.append(GetConVarString("memory_titan_settings"))
                            player.SetPlayerSettingsWithMods( player.GetPlayerSettings(), mods )
                        }
                    }
                    setHP = true
                }
                if (player.GetPetTitan() != null)
                {
                    if (hp != -1)
                    {
                        player.GetPetTitan().SetHealth(hp)
                        if (GetConVarString("memory_titan_settings") != "")
                        {
                            player.GetPetTitan().ai.titanSettings.titanSetFileMods.append(GetConVarString("memory_titan_settings"))
                        }
                    }
                    setHP = true
                }
            }
            else 
            {
                if (player.IsTitan())
                {
                    SetConVarInt("memory_titan_hp", player.GetHealth())
                    setHP = true
                }
                else if (player.GetPetTitan() != null)
                {
                    SetConVarInt("memory_titan_hp", player.GetPetTitan().GetHealth())
                }
                else
                {
                    setHP = false
                }
            }
            wait 0.001
        }
    }()
}

void function OnTitanDoomed( entity titan, var damageInfo )
{
    if (titan.IsPlayer() && "titan_health" in Roguelike_GetRunModifiers())
    {
        printt("HEALTH!")
        array<string> settings = titan.GetPlayerSettingsMods()
        // healthbar always displays 3 segments, lets not misdirect the player
        if (!settings.contains("segment_sacrifice_2"))
        {
            if (settings.contains("segment_sacrifice_1"))
            {
                settings.fastremovebyvalue("segment_sacrifice_1")
                settings.append("segment_sacrifice_2")
            }
            else
            {
                settings.append("segment_sacrifice_1")
            }
        }
        titan.SetPlayerSettingsWithMods( titan.GetPlayerSettings(), settings )

        Remote_CallFunction_NonReplay( titan, "ServerCallback_UpdateHealthSegmentCountRandom", 0.0 )
    }
}

void function ShotgunDamage( entity ent, var damageInfo )
{
    if (DamageInfo_GetCustomDamageType( damageInfo ) & DF_RADIUS_DAMAGE )
    {
        if (ent != DamageInfo_GetAttacker( damageInfo ))
        DamageInfo_SetDamage( damageInfo, 0 )
    }
}

void function CheckShield( entity player, entity titan )
{
    if (!IsValid(player) || !IsAlive(player))
        return

    if (Roguelike_HasMod( player, "max_shield"))
        player.GetTitanSoul().SetShieldHealthMax(1500)
    else
        player.GetTitanSoul().SetShieldHealthMax(1000)
}

void function InventoryRefreshed( entity player )
{
    if (player.IsTitan())
    {
        player.SetMoveSpeedScale(Roguelike_HasMod(player, "titan_move_speed") ? 1.2 : 1.0 )
        int energy = Roguelike_GetStat( player, STAT_ENERGY )
		float cdReduction = Roguelike_GetDashCooldownMultiplier( energy )
        player.SetPowerRegenRateScale( 1.0 / cdReduction )
        CheckShield( player, player )
        
        player.SetSharedEnergyTotal( Ion_GetMaxEnergy( player ) )
        if (Roguelike_HasMod( player, "energy_conversion" ))
            player.SetSharedEnergyRegenRate( 500 * ( 1.0 + 0.01 * Roguelike_GetStat( player, STAT_ENERGY ) ) )
        else
            player.SetSharedEnergyRegenRate(500)
        
        int overflow = player.GetSharedEnergyCount() - player.GetSharedEnergyTotal()
        if (overflow > 0)
            player.TakeSharedEnergy( overflow )
    }
    else
    {
        float maxDashPower = 20.0
        if (Roguelike_HasMod( player, "double_dash" ))
            maxDashPower = 40.0
        player.Server_SetDodgePower(min(player.GetDodgePower(), maxDashPower))
        int endurance = Roguelike_GetStat( player, STAT_ENDURANCE )
        int speed = Roguelike_GetStat( player, STAT_SPEED )
        float healthFrac = GetHealthFrac( player )
        player.SetMaxHealth(100 * (1.0 + Roguelike_GetPilotHealthBonus( endurance )))

        if (player.ContextAction_IsBusy() || player.ContextAction_IsActive())
            player.SetHealth(player.GetMaxHealth())
        else if (IsAlive(player))
            player.SetHealth( player.GetMaxHealth() * healthFrac )

        player.SetMoveSpeedScale(1.0 + Roguelike_GetPilotSpeedBonus( speed ))

        if (Roguelike_HasMod( player, "ground_friction" ))
        {
            player.SetGroundFrictionScale( 0.7 )
        }
        else
        {
            player.SetGroundFrictionScale( 1 )
        }
        if (Roguelike_HasMod( player, "wall_friction" ))
        {
            player.SetWallrunFrictionScale( 0.7 )
        }
        else
        {
            player.SetWallrunFrictionScale( 1 )
        }
        player.kv.airAcceleration = Roguelike_HasMod( player, "bhopper" ) ? 2000 : player.GetPlayerSettingsField( "airAcceleration" )
    }
}

void function OnPlayerDamaged( entity player, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    if (GetHealthFrac( player ) <= 0.5 && !player.IsTitan() && Roguelike_HasMod( player, "last_stand" ))
    {
        DamageInfo_ScaleDamage( damageInfo, 0.5 )
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

    if (RSE_Get( player, RoguelikeEffect.scorch_warmth ) > 0)
    {
        DamageInfo_ScaleDamage( damageInfo, 1.0 - RSE_Get( player, RoguelikeEffect.scorch_warmth ))
    }
    if (IsGunShieldActive( player) && Roguelike_HasMod( player, "gun_shield_shield") )
    {
        DamageInfo_ScaleDamage( damageInfo, 0.6 )
    }
    float sqrDist = DistanceSqr( attacker.GetOrigin(), player.GetOrigin() )
    if ( sqrDist < 787.7 * 787.7 ) // 20m
    {
        if (Roguelike_HasMod( player, "titan_brawler" ))
        {
            DamageInfo_ScaleDamage( damageInfo, 0.666 )
        }
    }

    if ( sqrDist > 1181 * 1181 ) // 30m
    {
        if (Roguelike_HasMod( player, "titan_long_range_resist" ))
        {
            DamageInfo_ScaleDamage( damageInfo, 0.75 )
        }
    }
}
void function PilotDamageReductions( entity player, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    if (!IsValid(attacker))
        return

    if (attacker == player)
    {
        float selfDMGMult = Roguelike_GetPilotSelfDamageMult(Roguelike_GetStat(player, STAT_ENDURANCE))
        DamageInfo_ScaleDamage( damageInfo, selfDMGMult )
        return
    }

    if (attacker.IsTitan())
    {
        if (Roguelike_HasMod( player, "titan_aptitude" ))
        {
            DamageInfo_ScaleDamage( damageInfo, 0.4 )
        }
    }

    float sqrDist = DistanceSqr( attacker.GetOrigin(), player.GetOrigin() )
    if ( sqrDist < 196.8 * 196.8 ) // 5m
    {
        if (Roguelike_HasMod( player, "pilot_brawler" ))
        {
            DamageInfo_ScaleDamage( damageInfo, 0.5 )
        }
    }

    if ( sqrDist > 787.4 * 787.4 ) // 20m
    {
        if (Roguelike_HasMod( player, "pilot_long_range_resist" ))
        {
            DamageInfo_ScaleDamage( damageInfo, 0.5 )
        }
    }
}

entity function CreateProcInflictorHelper()
{
	entity inflictor = CreateEntity( "info_target" )
	DispatchSpawn( inflictor )
	inflictor.e.onlyDamageEntitiesOncePerTick = true
    inflictor.SetScriptName("proc")
	return inflictor
}

void function Roguelike_PlayerUsedOffhand( entity player, entity offhand, int index )
{
    bool isTitan = player.IsTitan()
    if ( index == OFFHAND_EQUIPMENT && isTitan && Roguelike_HasMod( player, "shield_core" ))
    {
        entity soul = player.GetTitanSoul()
        soul.SetShieldHealth(soul.GetShieldHealthMax())
    }
    if ( index == OFFHAND_ORDNANCE && isTitan && Roguelike_HasMod( player, "titan_counter" ) && RSE_Get( player, RoguelikeEffect.counter ) <= 0.0)
    {
        entity ordnance = player.GetOffhandWeapon(1)
        entity otherOrdnance = Roguelike_GetAlternateOffhand( player, OFFHAND_SPECIAL )
        if (IsValid(ordnance))
            RestoreCooldown( ordnance, 0.2 )
        if (IsValid(otherOrdnance))
            RestoreCooldown( otherOrdnance, 0.2 )

        RSE_Apply( player, RoguelikeEffect.counter, 1.0, 6.0, 6.0 )
    }
    if ( index == OFFHAND_SPECIAL && isTitan && Roguelike_HasMod( player, "titan_parry" ) && RSE_Get( player, RoguelikeEffect.parry ) <= 0.0)
    {
        entity ordnance = player.GetOffhandWeapon(0)
        entity otherOrdnance = Roguelike_GetAlternateOffhand( player, OFFHAND_ORDNANCE )
        if (IsValid(ordnance))
            RestoreCooldown( ordnance, 0.2 )
        if (IsValid(otherOrdnance))
            RestoreCooldown( otherOrdnance, 0.2 )

        RSE_Apply( player, RoguelikeEffect.parry, 1.0, 6.0, 6.0 )
    }

    //if (Time() - player.p.lastTitanOffhandUseTime[index] < 6.0 && Roguelike_HasMod( player, ""))
}

void function Roguelike_PlayerDealtDamage( entity victim, entity player, var damageInfo )
{
    entity inflictor = DamageInfo_GetInflictor( damageInfo )
    if (!IsAlive( player ))
        return
    entity procEnt = null
    bool destroyProcInflictor = false
    // requires a valid inflictor to work
    if (IsValid( inflictor ) && inflictor.GetScriptName() == "proc")
    {
        procEnt = inflictor
    }
    else
    {
        if (verboseDamagePrintouts)
            printt("--- PROCS START ---")
        procEnt = CreateProcInflictorHelper()
        destroyProcInflictor = true // we created it, we take care of it

        if (IsValid(inflictor) && inflictor.e.procs.len() > 0)
            procEnt.e.procs.extend(inflictor.e.procs)
    }

    int initialLen = inflictor.e.procs.len()
    float damage = DamageInfo_GetDamage( damageInfo )

    if (player.IsTitan())
        TitanProcs( victim, player, damageInfo, procEnt )
    else
        PilotProcs( victim, player, damageInfo, procEnt )

    if (destroyProcInflictor)
    {
        procEnt.Destroy()
        if (verboseDamagePrintouts)
            print("--- PROC INFLICTOR END --- `")
    }
}

void function PilotProcs( entity victim, entity player, var damageInfo, entity procEnt )
{
    entity inflictor = DamageInfo_GetInflictor( damageInfo )
    float damage = DamageInfo_GetDamage( damageInfo )
    int scriptDamageFlags = DamageInfo_GetCustomDamageType( damageInfo )
    int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )

    if ((scriptDamageFlags & DF_CRITICAL) != 0 && Roguelike_HasMod( player, "headshot_booster") && !player.IsTitan())
    {
        if (verboseDamagePrintouts)
            printt("headshot boost")
        player.SetHealth( min(player.GetMaxHealth(), player.GetHealth() + damage * 0.1) )
        DamageInfo_SetDamage( damageInfo, damage * 1.5 )
    }

    if (DistanceSqr( victim.GetOrigin(), player.GetOrigin() ) < 196.8 * 196.8 && Roguelike_HasMod( player, "bloodthirst"))
    {
        player.SetHealth( min(player.GetMaxHealth(), player.GetHealth() + 5) )
    }

    if (Roguelike_HasMod( player, "pain_to_gain"))
    {
        float restoration = min(damage, victim.GetHealth()) / 1000.0
        entity grenade = player.GetOffhandWeapon(OFFHAND_ORDNANCE)
        if (IsValid(grenade))
            RestoreCooldown( grenade, restoration )
    }
}

void function TitanProcs( entity victim, entity player, var damageInfo, entity procEnt )
{
    entity inflictor = DamageInfo_GetInflictor( damageInfo )
    float damage = DamageInfo_GetDamage( damageInfo )
    int scriptDamageFlags = DamageInfo_GetCustomDamageType( damageInfo )
    int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
    entity sourceWeapon = Roguelike_FindWeaponForDamageInfo( damageInfo )

    if (Roguelike_HasMod( player, "shock_bullets" ) && RandomFloat(1.0) < 0.3 && !inflictor.e.procs.contains("shock_bullets") && victim.IsTitan())
    {
        array<entity> entsInRadius = GetNPCArrayEx( "npc_titan", TEAM_ANY, player.GetTeam(), victim.GetWorldSpaceCenter(), 787.4 * 2.5 )

        procEnt.e.procs.append("shock_bullets")
        for (int i = 0; i < entsInRadius.len(); i++)
        {
            if (entsInRadius[i] == victim)
                continue

            entsInRadius[i].TakeDamage( damage * 0.3, player, procEnt, { damageSourceId = eDamageSourceId.shock_bullets, origin = entsInRadius[i].GetWorldSpaceCenter() } )
            break
        }
        procEnt.e.procs.fastremovebyvalue("shock_bullets")
    }

    if (Roguelike_HasMod( player, "atg_missile" ) && RandomFloat(1.0) < 0.2 && !inflictor.e.procs.contains("atg_missile") && player.IsTitan() && IsValid(victim))
    {
        entity activeWeapon = player.GetActiveWeapon()
        entity weapon = Roguelike_GetOffhandWeaponByName( player, "mp_titanweapon_shoulder_rockets" )
        if (weapon == null)
            return

        if (verboseDamagePrintouts)
            printt("firing missile!!")
        vector right = AnglesToRight( player.EyeAngles() )
        entity missile = weapon.FireWeaponMissile( player.CameraPosition(), <0,0,1> - right * RandomFloatRange(-0.5, 0.5), 1000.0, damageTypes.projectileImpact, damageTypes.explosive, false, false )

        weapon.EmitWeaponSound( "ShoulderRocket_Paint_Fire_1P" )

        missile.SetMissileTarget( victim, < 0, 0, 0 > )
        missile.proj.damageScale = damage / 100.0 * 0.5
        missile.proj.isChargedShot = true
        missile.e.procs.extend(procEnt.e.procs)
        missile.e.procs.append("atg_missile")

        missile.SetHomingSpeeds( 250, 250 )
    }

    if (!("offensive_overload" in player.s))
    {
        player.s.offensive_overload <- -99.9
    }
    if (Roguelike_HasMod( player, "offensive_overload" ) && Time() - player.s.offensive_overload > 10.0)
    {
        bool isOffensive = IsValid(sourceWeapon) && sourceWeapon.GetInventoryIndex() == 0 && sourceWeapon.IsWeaponOffhand()
        if (IsDamageSourcePowerShot( damageInfo ))
            isOffensive = true

        if (IsValid(sourceWeapon) && isOffensive && damageSourceID != eDamageSourceId.mp_titanweapon_arc_wave)
        {
            AddDaze( victim, player, 3 )
            player.s.offensive_overload <- Time()
        }
    }

    if (IsValid(sourceWeapon))
    {
        if ( sourceWeapon.GetWeaponClassName() == "mp_titanweapon_predator_cannon" && !sourceWeapon.HasMod("LongRangeAmmo")
            && Roguelike_HasMod( player, "focus_crystal") )
            DamageInfo_AddDamageBonus( damageInfo, 0.2 )
        if (Roguelike_IsWeaponDamage( damageInfo )) // we consider melee to be weapon damage.
        {
            float weaponCrit = RSE_Get( player, RoguelikeEffect.overcrit )
            if (Roguelike_HasMod( player, "weapon_crit" ))
                RSE_Apply( player, RoguelikeEffect.overcrit, min(weaponCrit + 1, 20.0), 4.0, 0.0 )
        }
    }
    else
    {
        printt("sourceWeapon is not valid!", inflictor, damageSourceID, player)
        printt(inflictor.GetClassName())
    }
}

bool function Roguelike_IsWeaponDamage( var damageInfo )
{
    entity sourceWeapon = Roguelike_FindWeaponForDamageInfo( damageInfo )
    if (sourceWeapon == null)
        return false

    return !sourceWeapon.IsWeaponOffhand() || sourceWeapon.GetInventoryIndex() == OFFHAND_MELEE
}