untyped

globalize_all_functions

global entity weaponDummy
global bool wasWeaponDummySet

global const array<string> allowedWeapons = [
	//ar
	"mp_weapon_rspn101",
	"mp_weapon_rspn101_og",
	"mp_weapon_vinson",
	"mp_weapon_g2",
	"mp_weapon_hemlok",
	// smg
	"mp_weapon_r97",
	"mp_weapon_car",
	"mp_weapon_hemlok_smg",
	"mp_weapon_alternator_smg",
	// lmg
	"mp_weapon_lmg",
	"mp_weapon_lstar",
	"mp_weapon_esaw",
	//sniper
	"mp_weapon_sniper",
	"mp_weapon_doubletake",
	"mp_weapon_dmr",
	//explosive
	"mp_weapon_epg",
	"mp_weapon_pulse_lmg",
	"mp_weapon_softball",
	"mp_weapon_smr",
	// shotguns
	"mp_weapon_shotgun",
	"mp_weapon_mastiff",
	//"mp_weapon_peacekraber",
	// ???
	"mp_weapon_arc_launcher",
	// PISTOL
	"mp_weapon_wingman",
	"mp_weapon_wingman_n",
	"mp_weapon_shotgun_pistol",
	"mp_weapon_semipistol",
	"mp_weapon_autopistol",
	//"mp_weapon_40mm",
	// grenades
	"mp_weapon_frag_grenade",
	"mp_weapon_thermite_grenade",
	"mp_weapon_grenade_gravity",
	"mp_weapon_grenade_emp",
	"mp_weapon_grenade_electric_smoke",
	"mp_weapon_grenade_sonar",
	"mp_weapon_satchel",
	// tacticals :flushed:
	"mp_ability_cloak",
	"mp_ability_heal",
	"mp_ability_shifter",
	"mp_ability_grapple",
	// at
	"mp_weapon_defender",
	"mp_titanability_rearm"
	//"mp_ability_holopilot",
]

void function PrecacheJack()
{
	//PrecacheWeapon( "mp_weapon_40mm" )
	//PrecacheWeapon( "mp_weapon_lstar_csgo" )
	//PrecacheWeapon( "mp_weapon_rspn101_csgo" )
	// script CreatePropDynamic( $"models/weapons/titan_trip_wire/titan_trip_wire.mdl", __p().GetOrigin() )
    //PrecacheModel( $"models/containers/test.mdl" )
    PrecacheModel( $"models/containers/pelican_case_large_open.mdl" )
    PrecacheModel( $"models/containers/pelican_case_large.mdl" )
	PrecacheModel( $"models/titans/heavy/sp_titan_heavy_deadbolt.mdl" )
	PrecacheModel( $"models/titans/heavy/sp_titan_heavy_ogre.mdl" )
	PrecacheModel( $"models/titans/heavy/sp_titan_heavy_deadbolt.mdl" )
	PrecacheModel( $"models/titans/medium/sp_titan_medium_ajax.mdl" )
	PrecacheModel( $"models/titans/medium/sp_titan_medium_wraith.mdl" )
	PrecacheModel( $"models/titans/light/sp_titan_light_locust.mdl" )
	PrecacheModel( $"models/titans/light/sp_titan_light_raptor.mdl" )
	PrecacheModel( $"models/titans/heavy/titan_heavy_rodeo_battery.mdl" )
	PrecacheModel( $"models/titans/medium/titan_medium_rodeo_battery.mdl" )
	PrecacheModel( $"models/titans/light/titan_light_rodeo_battery.mdl" )
	PrecacheWeapon("mp_weapon_mega_turret_boss");
	PrecacheWeapon("mp_titanability_roguelike_pylon");
	PrecacheWeapon("mp_titanability_nuclear_explosion");
	foreach ( string weaponName in allowedWeapons )
	{
		if (!WeaponIsPrecached(weaponName))
			PrecacheWeapon(weaponName);
	}


	array<string> validTitans = [
		"npc_titan_ogre_meteor",
		"npc_titan_ogre_minigun",
		"npc_titan_atlas_tracker",
		"npc_titan_atlas_stickybomb",
		"npc_titan_stryder_leadwall",
		"npc_titan_stryder_sniper"]

	if (RandomFloat(1.0) < 0.1 && GetMapName() != "sp_skyway_v1") // should remove the latter when i finally test fold weapon with force titan
		SetConVarString("roguelike_force_titan", validTitans.getrandom())
	else
		SetConVarString("roguelike_force_titan", "")
		
}