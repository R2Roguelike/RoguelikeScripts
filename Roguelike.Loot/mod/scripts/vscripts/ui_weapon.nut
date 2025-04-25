untyped
global function RoguelikeWeapon_Init
global function RoguelikeWeapon_Generate
global function RoguelikeWeapon_CreateWeapon
global function RoguelikeWeapon_GetSlot
global function RoguelikeWeapon_GenerateSmartPistol

const array<string> allowedWeapons = [
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
	// shotguns
	//"mp_weapon_peacekraber",
	// ???
	"mp_weapon_arc_launcher",
	// PISTOL
	"mp_weapon_wingman",
	"mp_weapon_wingman_n",
	"mp_weapon_shotgun_pistol",
	"mp_weapon_semipistol",
	"mp_weapon_autopistol",
]

array<string> allowedMovementTools = [
	"mp_weapon_epg",
	//"mp_weapon_pulse_lmg",
	"mp_weapon_softball",
	//"mp_weapon_smr",
	"mp_weapon_shotgun",
	"mp_weapon_mastiff"
]

void function RoguelikeWeapon_Init()
{
}

string function RoguelikeWeapon_GetSlot( string weapon )
{
	if (!IsFullyConnected())
		throw "RoguelikeWeapon_GetSlot called while not fully connected"
	
	var slot = GetWeaponInfoFileKeyField_Global( weapon, "inventory_slot" )
	if (slot == null)
		slot = "primary"
	
	expect string(slot)

	return slot
}

table function RoguelikeWeapon_Generate()
{
	table runData = Roguelike_GetRunData()
	string weapon = allowedWeapons.getrandom()
	if (CoinFlip())
		weapon = allowedMovementTools.getrandom()
    int levelsComplete = expect int(runData.levelsCompleted)
    int baseRarity = levelsComplete / 2
    float chanceForBetterRarity = GraphCapped( levelsComplete % 2, 0, 2, 0, 1 )
    if (RandomFloat(1) < chanceForBetterRarity)
        baseRarity++
		
    baseRarity = minint(RARITY_LEGENDARY, maxint(baseRarity, RARITY_COMMON))
	
	return RoguelikeWeapon_CreateWeapon( weapon, baseRarity, RoguelikeWeapon_GetSlot( weapon ) )
}

table function RoguelikeWeapon_GenerateSmartPistol()
{
    table weapon = RoguelikeWeapon_CreateWeapon( "mp_weapon_smart_pistol_og", RARITY_LEGENDARY, "primary" )

	weapon.mods.append("og_pilot")
	weapon.mods.append("pas_fast_reload")

	return weapon
}


table function RoguelikeWeapon_CreateWeapon( string name, int rarity, string slot )
{
    table runData = Roguelike_GetRunData()

    table item = {
        type = "weapon",
        weapon = name,
		slot = slot,
        level = 0,
        priceOffset = 0,
        rarity = rarity,
		perks = [],
		mods = [],
        moneyInvested = 30 + 15 * (rarity) // give 10 * rarity dolla when dismantled ()
    }

    item.priceOffset += rarity * 25

    return item
}
