untyped

global function MpTitanWeaponParticleAccelerator_Init

global function OnWeaponPrimaryAttack_titanweapon_particle_accelerator
global function OnWeaponActivate_titanweapon_particle_accelerator
global function OnWeaponCooldown_titanweapon_particle_accelerator
global function OnWeaponStartZoomIn_titanweapon_particle_accelerator
global function OnWeaponStartZoomOut_titanweapon_particle_accelerator
global function LeadPosition

global function PROTO_GetHeatMeterCharge

#if SERVER
global function OnWeaponNpcPrimaryAttack_titanweapon_particle_accelerator
#endif

const ADS_SHOT_COUNT_NORMAL = 3
const ADS_SHOT_COUNT_UPGRADE = 5
const TPAC_PROJECTILE_SPEED = 8000
const TPAC_PROJECTILE_SPEED_NPC = 5000
const LSTAR_LOW_AMMO_WARNING_FRAC = 0.25
const LSTAR_COOLDOWN_EFFECT_1P = $"wpn_mflash_snp_hmn_smokepuff_side_FP"
const LSTAR_COOLDOWN_EFFECT_3P = $"wpn_mflash_snp_hmn_smokepuff_side"
const LSTAR_BURNOUT_EFFECT_1P = $"xo_spark_med"
const LSTAR_BURNOUT_EFFECT_3P = $"xo_spark_med"

const TPA_ADS_EFFECT_1P = $"P_TPA_electricity_FP"
const TPA_ADS_EFFECT_3P = $"P_TPA_electricity"

const CRITICAL_ENERGY_RESTORE_AMOUNT = 30
const SPLIT_SHOT_CRITICAL_ENERGY_RESTORE_AMOUNT = 8

const float PARTICLE_ACCELERATOR_SPREAD = 0.03
struct {
	float[ADS_SHOT_COUNT_UPGRADE] boltOffsets = [
		0.0,
		0.03,
		-0.03,
		0.06,
		-0.06,
	]
} file

function MpTitanWeaponParticleAccelerator_Init()
{
	PrecacheParticleSystem( LSTAR_COOLDOWN_EFFECT_1P )
	PrecacheParticleSystem( LSTAR_COOLDOWN_EFFECT_3P )
	PrecacheParticleSystem( LSTAR_BURNOUT_EFFECT_1P )
	PrecacheParticleSystem( LSTAR_BURNOUT_EFFECT_3P )
	PrecacheParticleSystem( TPA_ADS_EFFECT_1P )
	PrecacheParticleSystem( TPA_ADS_EFFECT_3P )

	#if SERVER
	AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_particle_accelerator, OnHit_TitanWeaponParticleAccelerator )
	#endif
}

void function OnWeaponStartZoomIn_titanweapon_particle_accelerator( entity weapon )
{
	array<string> mods = weapon.GetMods()
	if ( weapon.HasMod( "fd_split_shot_cost") )
	{
		if ( weapon.HasMod( "pas_ion_weapon_ads" ) )
			mods.append( "fd_upgraded_proto_particle_accelerator_pas" )
		else
			mods.append( "fd_upgraded_proto_particle_accelerator" )
	}
	else
	{
		if ( weapon.HasMod( "pas_ion_weapon_ads" ) )
			mods.append( "proto_particle_accelerator_pas" )
		else
			mods.append( "proto_particle_accelerator" )
	}

	weapon.SetMods( mods )

	#if CLIENT
		entity weaponOwner = weapon.GetWeaponOwner()
		if ( weaponOwner == GetLocalViewPlayer() )
			EmitSoundOnEntity( weaponOwner, "Weapon_Particle_Accelerator_WindUp_1P" )
	#endif
	weapon.PlayWeaponEffectNoCull( TPA_ADS_EFFECT_1P, TPA_ADS_EFFECT_3P, "muzzle_flash" )
	//weapon.PlayWeaponEffectNoCull( $"wpn_arc_cannon_charge_fp", $"wpn_arc_cannon_charge", "muzzle_flash" )
	weapon.EmitWeaponSound( "arc_cannon_charged_loop" )
}

void function OnWeaponStartZoomOut_titanweapon_particle_accelerator( entity weapon )
{
	array<string> mods = weapon.GetMods()
	mods.fastremovebyvalue( "proto_particle_accelerator" )
	mods.fastremovebyvalue( "proto_particle_accelerator_pas" )
	weapon.SetMods( mods )
	//weapon.StopWeaponEffect( $"wpn_arc_cannon_charge_fp", $"wpn_arc_cannon_charge" )
	weapon.StopWeaponEffect( TPA_ADS_EFFECT_1P, TPA_ADS_EFFECT_3P )
	weapon.StopWeaponSound( "arc_cannon_charged_loop" )
}

void function OnWeaponActivate_titanweapon_particle_accelerator( entity weapon )
{
	if ( !( "initialized" in weapon.s ) )
	{
		weapon.s.initialized <- true
	}
	#if SERVER
	entity owner = weapon.GetWeaponOwner()
	owner.SetSharedEnergyRegenDelay( 0.5 )
	#endif
}

function OnWeaponPrimaryAttack_titanweapon_particle_accelerator( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()
	float zoomFrac = owner.GetZoomFrac()
	if ( zoomFrac < 1 && zoomFrac > 0)
		return 0

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	return FireWeaponPlayerAndNPC( weapon, attackParams, true )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_titanweapon_particle_accelerator( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	return FireWeaponPlayerAndNPC( weapon, attackParams, false )
}
#endif // #if SERVER


function FireWeaponPlayerAndNPC( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired )
{
	bool shouldCreateProjectile = false
	if ( IsServer() || weapon.ShouldPredictProjectiles() )
		shouldCreateProjectile = true

	#if CLIENT
		if ( !playerFired )
			shouldCreateProjectile = false
	#endif

	entity owner = weapon.GetWeaponOwner()
    bool inADS = weapon.IsWeaponInAds()
	int ADS_SHOT_COUNT = weapon.HasMod( "pas_ion_weapon_ads" ) ? ADS_SHOT_COUNT_UPGRADE : ADS_SHOT_COUNT_NORMAL

	if ( shouldCreateProjectile )
	{
	    int shotCount = inADS ? ADS_SHOT_COUNT : 1
		weapon.ResetWeaponToDefaultEnergyCost()
		int cost = 0
		bool isSnakesplitter = inADS && !weapon.HasMod("proto_particle_accelerator")
		// snakesplitter cost
		if (isSnakesplitter)
		{
			if (Roguelike_HasMod( owner, "snakesplitter_energy" ))
			{
				cost = cost * 2 / 3
			}
		}
		int currentEnergy = owner.GetSharedEnergyCount()
		bool outOfEnergy = (currentEnergy < cost) || (currentEnergy == 0)
		if ( !inADS )
		{
			weapon.SetWeaponEnergyCost( 0 )
			shotCount = 1

			#if CLIENT
				if ( outOfEnergy )
					FlashEnergyNeeded_Bar( cost )
			#endif
			//Single Shots
			weapon.EmitWeaponSound_1p3p( "Weapon_Particle_Accelerator_Fire_1P", "Weapon_Particle_Accelerator_SecondShot_3P" )
		}
		else
		{
			if (outOfEnergy)
				weapon.AddMod("proto_particle_accelerator")
			else
				weapon.SetWeaponEnergyCost( cost )
			shotCount = ADS_SHOT_COUNT
			if (Roguelike_HasMod( owner, "energy_split" ))
				shotCount = minint(shotCount + Roguelike_GetStat( owner, STAT_ENERGY ) / 30, 7)
			//Split Shots
			weapon.EmitWeaponSound_1p3p( "Weapon_Particle_Accelerator_AltFire_1P", "Weapon_Particle_Accelerator_AltFire_SecondShot_3P" )
		}

		vector attackAngles = VectorToAngles( attackParams.dir )
		vector baseRightVec = AnglesToRight( attackAngles )
		int damageType = damageTypes.largeCaliber | DF_STOPS_TITAN_REGEN

		float speed = TPAC_PROJECTILE_SPEED
		if ( owner.IsNPC() )
			speed = TPAC_PROJECTILE_SPEED_NPC

		float start = -PARTICLE_ACCELERATOR_SPREAD
		float end = PARTICLE_ACCELERATOR_SPREAD
		for ( int index = 0; index < shotCount; index++ )
		{
			float frac = index / float(shotCount - 1)
			if (shotCount == 1)
				frac = 0.5
			
			vector attackVec = attackParams.dir + baseRightVec * GraphCapped( frac, 0, 1, start, end )

			entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackVec, speed, damageType, damageType, playerFired, 0 )
			if ( bolt != null )
			{
				if (isSnakesplitter)
					bolt.s.snakesplitter <- true
				//bolt.kv.gravity = -0.1
				bolt.kv.rendercolor = "0 0 0"
				bolt.kv.renderamt = 0
				bolt.kv.fadedist = 1
			}
		}
	}
	return 1
}

void function OnWeaponCooldown_titanweapon_particle_accelerator( entity weapon )
{
	weapon.PlayWeaponEffect( LSTAR_COOLDOWN_EFFECT_1P, LSTAR_COOLDOWN_EFFECT_3P, "SPINNING_KNOB" ) //"DWAY_ROTATE"
	weapon.EmitWeaponSound_1p3p( "LSTAR_VentCooldown", "LSTAR_VentCooldown" )
}

int function PROTO_GetHeatMeterCharge( entity weapon )
{
	if ( !IsValid( weapon ) )
		return 0

	entity owner = weapon.GetWeaponOwner()
	if ( !IsValid( owner ) )
		return 0

	if ( weapon.IsReloading() )
		return 8

	float max = float ( owner.GetWeaponAmmoMaxLoaded( weapon ) )
	float currentAmmo = float ( owner.GetWeaponAmmoLoaded( weapon ) )

	float crosshairSegments = 8.0
	return int ( GraphCapped( currentAmmo, max, 0.0, 0.0, crosshairSegments ) )
}

#if SERVER
void function OnHit_TitanWeaponParticleAccelerator( entity victim, var damageInfo )
{
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( !IsValid( inflictor ) )
		return
	if ( !inflictor.IsProjectile() )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( attacker ) || attacker.IsProjectile() ) //Is projectile check is necessary for when the original attacker is no longer valid it becomes the projectile.
		return

	if ( attacker.GetSharedEnergyTotal() <= 0 )
		return

	if ( attacker.GetTeam() == victim.GetTeam() )
		return

	entity soul = attacker.GetTitanSoul()
	if ( !IsValid( soul ) )
		return

	bool isCrit = (DamageInfo_GetCustomDamageType( damageInfo ) & DF_CRITICAL) != 0

	float cur = RSE_Get( victim, RoguelikeEffect.ion_charge )
	array<string> mods = inflictor.ProjectileGetMods()
	float add = 0.03
	if (mods.contains("proto_particle_accelerator") || "turretBolt" in inflictor.s || "snakesplitter" in inflictor.s)
	{
		if ("turretBolt" in inflictor.s)
		{
			int base = 30
			array<string> turretMods = ["pylon_charge", "orbital_strike", "snakesplitter_energy", "energy_split", "energy_conversion"]
			foreach (string mod in turretMods)
			{
				if (Roguelike_HasMod( attacker, mod ))
					base += 3
			}
			DamageInfo_SetDamage( damageInfo, base )
			add = 0.01
		}
		add = 0.015
	}

    int count = 0
    array<string> chargeMods = ["laser_disorder", "discharge_battery", "discharge_crit"]
    foreach (string mod in chargeMods)
    {
        if (Roguelike_HasMod( attacker, mod ))
            count++
    }
	add *= 1.0 + 0.15 * count // balls...?

	RSE_Apply( victim, RoguelikeEffect.ion_charge, min(cur + add, 1.0) )

	if (cur + add >= 0.99)
	{

	}

	if ((IsNPCTitan(victim) || IsSuperSpectre(victim)) && !("turretBolt" in inflictor.s))
		attacker.s.turretTarget <- victim
	/*if ( ( IsSingleplayer() || SoulHasPassive( soul, ePassives.PAS_ION_WEAPON ) ) && isCrit )
	{
			array<string> mods = inflictor.ProjectileGetMods()
			if ( mods.contains( "proto_particle_accelerator" ) )
				attacker.AddSharedEnergy( SPLIT_SHOT_CRITICAL_ENERGY_RESTORE_AMOUNT )
			else
				attacker.AddSharedEnergy( CRITICAL_ENERGY_RESTORE_AMOUNT )
	}*/
}
#endif

// sidenote - this is not how you are supposed to do this, im just too unbothered to do the math
vector function LeadPosition( vector pos, vector target, vector targetVelocity, float projSpeed )
{
	float travelTime = 0.0
	travelTime = Distance(target, pos) / projSpeed
	for (int i = 0; i < 3; i++)
	{
		vector newPos = target + targetVelocity * travelTime
		float offset = Distance(target, newPos) / projSpeed - travelTime
		travelTime -= offset
	}

	return Normalize(target - pos)
}