untyped
global function RoguelikeGrenade_Init
global function RoguelikeGrenade_Generate
global function RoguelikeGrenade_CreateWeapon
global function RoguelikeGrenade_GetSlot

void function RoguelikeGrenade_Init()
{
}

string function RoguelikeGrenade_GetSlot( string weapon )
{
	if (!IsFullyConnected())
		throw "RoguelikeGrenade_GetSlot called while not fully connected"

	var slot = GetWeaponInfoFileKeyField_Global( weapon, "inventory_slot" )
	if (slot == null)
		slot = "primary"

	expect string(slot)

	return slot
}

table function RoguelikeGrenade_Generate()
{
	table runData = Roguelike_GetRunData()

	string weapon = ROGUELIKE_GRENADES.getrandom()

    int levelsComplete = expect int(runData.levelsCompleted)
    int baseRarity = levelsComplete / 2
    float chanceForBetterRarity = GraphCapped( levelsComplete % 2, 0, 2, 0, 1 )
    if (RandomFloat(1) < chanceForBetterRarity)
        baseRarity++

    baseRarity = minint(RARITY_LEGENDARY, maxint(baseRarity, RARITY_COMMON))

	return RoguelikeGrenade_CreateWeapon( weapon, baseRarity, RoguelikeGrenade_GetSlot( weapon ) )
}

table function RoguelikeGrenade_CreateWeapon( string name, int rarity, string perk1 = "" )
{
    table runData = Roguelike_GetRunData()

    table item = {
        type = "grenade",
        weapon = name,
        level = 0,
        priceOffset = 0,
        rarity = rarity,
		perk1 = "",
		bonusStat = "",
		mods = [],
        moneyInvested = 30 + 15 * (rarity) // give 10 * rarity dolla when dismantled ()
    }

    item.priceOffset += rarity * 25

    return item
}
