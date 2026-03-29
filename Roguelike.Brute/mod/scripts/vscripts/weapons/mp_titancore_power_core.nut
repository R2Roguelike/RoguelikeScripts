global function OnWeaponPrimaryAttack_DoNothing

global function Power_Core_Init

global function OnCoreCharge_Power_Core
global function OnCoreChargeEnd_Power_Core
global function OnAbilityStart_Power_Core

void function Power_Core_Init()
{
}

var function OnWeaponPrimaryAttack_DoNothing( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0
}

bool function OnCoreCharge_Power_Core( entity weapon )
{
	if ( !OnAbilityCharge_TitanCore( weapon ) )
		return false

#if SERVER
	entity owner = weapon.GetWeaponOwner()
	string swordCoreSound_1p
	string swordCoreSound_3p
	if ( weapon.HasMod( "fd_duration" ) )
	{
		swordCoreSound_1p = "Titan_Ronin_Sword_Core_Activated_Upgraded_1P"
		swordCoreSound_3p = "Titan_Ronin_Sword_Core_Activated_Upgraded_3P"
	}
	else
	{
		swordCoreSound_1p = "Titan_Ronin_Sword_Core_Activated_1P"
		swordCoreSound_3p = "Titan_Ronin_Sword_Core_Activated_3P"
	}
	if ( owner.IsPlayer() )
	{
		EmitSoundOnEntityOnlyToPlayer( owner, owner, swordCoreSound_1p )
		EmitSoundOnEntityExceptToPlayer( owner, owner, swordCoreSound_3p )
	}
	else
	{
		EmitSoundOnEntity( weapon, swordCoreSound_3p )
	}

	owner.HolsterWeapon()
#endif


	return true
}

void function OnCoreChargeEnd_Power_Core( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	#if SERVER
	OnAbilityChargeEnd_TitanCore( weapon )
	owner.DeployWeapon()
	#endif

	float delay = weapon.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_delay )
	thread Power_Core_End( weapon, owner, delay )
}

void function Power_Core_End( entity weapon, entity player, float delay )
{
	weapon.EndSignal( "OnDestroy" )

	if ( player.IsNPC() && !IsAlive( player ) )
		return

	player.EndSignal( "OnDestroy" )
	if ( IsAlive( player ) )
		player.EndSignal( "OnDeath" )
	player.EndSignal( "TitanEjectionStarted" )
	player.EndSignal( "DisembarkingTitan" )
	player.EndSignal( "OnSyncedMelee" )

	OnThreadEnd(
	function() : ( weapon, player )
		{
			OnAbilityEnd_Power_Core( weapon, player )

			#if SERVER
			if ( IsValid( player ) )
			{
				entity soul = player.GetTitanSoul()
				if ( soul != null )
					CleanupCoreEffect( soul )
			}
			#endif
		}
	)

	entity soul = player.GetTitanSoul()
	if ( soul == null )
		return

	while ( 1 )
	{
		if ( soul.GetCoreChargeExpireTime() <= Time() )
			break;
		wait 0.001
	}
}

#if SERVER
void function RestoreWeapon( entity owner, entity weapon )
{
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "CoreBegin" )

	WaitSignal( weapon, "RestoreWeapon", "OnDestroy" )

	if ( IsValid( owner ) && owner.IsPlayer() )
	{
		owner.DeployWeapon() //TODO: Look into rewriting this so it works with DeployAndEnableWeapons()
	}
}
#endif

var function OnAbilityStart_Power_Core( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	OnAbilityStart_TitanCore( weapon )

	entity owner = weapon.GetWeaponOwner()

	if ( !owner.IsTitan() )
		return 0

	if ( !IsValid( owner ) )
		return

#if SERVER
	if ( owner.IsPlayer() )
	{
		owner.Server_SetDodgePower( 100.0 )
		owner.SetPowerRegenRateScale( 6.5 )
		GivePassive( owner, ePassives.PAS_FUSION_CORE )
		GivePassive( owner, ePassives.PAS_SHIFT_CORE )
		RSE_Apply( owner, RoguelikeEffect.brute_infinite_core, 1.0 )
        owner.SetSharedEnergyRegenRate(1000)
		owner.SetSharedEnergyRegenDelay(0.25)
	}
#endif
	
	#if CLIENT
	for (int i = 0; i < 3; i++)
		ClWeaponStatus_SetOffhandHint( i )
	#endif

	return 1
}

void function OnAbilityEnd_Power_Core( entity weapon, entity player )
{
	#if SERVER
	OnAbilityEnd_TitanCore( weapon )

	TakePassive( player, ePassives.PAS_FUSION_CORE )
	TakePassive( player, ePassives.PAS_SHIFT_CORE )
	RSE_Stop( player, RoguelikeEffect.brute_infinite_core )
	player.SetSharedEnergyRegenRate(500)
	player.SetSharedEnergyRegenDelay(0.5)

	if ( player.IsPlayer() )
	{
		float cdReduction = Roguelike_GetStat( player, "cd_reduction" )
		player.SetPowerRegenRateScale( 1.0 / cdReduction )
		EmitSoundOnEntityOnlyToPlayer( player, player, "Titan_Ronin_Sword_Core_Deactivated_1P" )
		EmitSoundOnEntityExceptToPlayer( player, player, "Titan_Ronin_Sword_Core_Deactivated_3P" )
		//int conversationID = GetConversationIndex( "swordCoreOffline" )
		//Remote_CallFunction_Replay( player, "ServerCallback_PlayTitanConversation", conversationID )
	}
	else
	{
		DeleteAnimEvent( player, "shift_core_use_meter" )
		EmitSoundOnEntity( player, "Titan_Ronin_Sword_Core_Deactivated_3P" )
	}
	#endif
	#if CLIENT
	for (int i = 0; i < 3; i++)
		ClWeaponStatus_ClearOffhandHint( i )
	#endif
}