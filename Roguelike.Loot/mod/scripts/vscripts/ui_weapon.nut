untyped
global function RoguelikeWeapon_Init
global function RoguelikeWeapon_Generate
global function RoguelikeWeapon_CreateWeapon
global function RoguelikeWeapon_GetSlot
global function RoguelikeWeapon_GenerateSmartPistol

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

	string weapon = ROGUELIKE_PILOT_WEAPONS.getrandom()
	if (CoinFlip())
		weapon = ROGUELIKE_MOVEMENT_TOOLS.getrandom()

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


table function RoguelikeWeapon_CreateWeapon( string name, int rarity, string slot, string perk1 = "" )
{
    table runData = Roguelike_GetRunData()

    table item = {
        type = "weapon",
        weapon = name,
		slot = slot,
        level = 0,
        priceOffset = 0,
        rarity = rarity,
		perkInherited = "",
		perk1 = "",
		bonusStat = "",
		mods = [],
        moneyInvested = 30 + 15 * (rarity) // give 10 * rarity dolla when dismantled ()
    }

	array<RoguelikeWeaponPerk> perkArr = Roguelike_GetWeaponPerksForSlotAndWeapon( PERK_SLOT_INHERIT, name )
	if (perkArr.len() > 0)
	{
		item.perkInherited = perkArr.getrandom().uniqueName
	}
	perkArr = Roguelike_GetWeaponPerksForSlotAndWeapon( PERK_SLOT_PERK, name )
	if (rarity > RARITY_UNCOMMON && perkArr.len() > 0)
		item.perk1 = perkArr.getrandom().uniqueName

	if (perk1 != "")
		item.perk1 = perk1

	perkArr = Roguelike_GetWeaponPerksForSlotAndWeapon( PERK_SLOT_STAT, name )
	if (rarity > RARITY_COMMON)
		item.bonusStat = perkArr.getrandom().uniqueName

    item.priceOffset += rarity * 25

    return item
}
