untyped
global function RoguelikeWeapon_Init
global function RoguelikeWeapon_Generate
global function RoguelikeWeapon_CreateWeapon
global function RoguelikeWeapon_GetSlot
global function RoguelikeWeapon_GenerateSmartPistol
global function RoguelikeWeapon_GetHoverFunc

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

table function RoguelikeWeapon_Generate(PRandom rand)
{
	table runData = Roguelike_GetRunData()

	string weapon = ROGUELIKE_PILOT_WEAPONS[PRandomInt(rand) % ROGUELIKE_PILOT_WEAPONS.len()]
	if (PRandomInt(rand, 0, 2) == 0)
		weapon = ROGUELIKE_MOVEMENT_TOOLS[PRandomInt(rand) % ROGUELIKE_MOVEMENT_TOOLS.len()]

    int levelsComplete = expect int(runData.levelsCompleted)
    int baseRarity = levelsComplete / 2
    float chanceForBetterRarity = GraphCapped( levelsComplete % 2, 0, 2, 0, 1 )
    if (PRandomFloat(rand) < chanceForBetterRarity)
        baseRarity++

    baseRarity = minint(RARITY_RADIANT, maxint(baseRarity, RARITY_COMMON))

	return RoguelikeWeapon_CreateWeapon( rand, weapon, baseRarity, RoguelikeWeapon_GetSlot( weapon ) )
}

table function RoguelikeWeapon_GenerateSmartPistol(PRandom rand)
{
    table weapon = RoguelikeWeapon_CreateWeapon( rand, "mp_weapon_smart_pistol_og", RARITY_LEGENDARY, "primary" )

	weapon.mods.append("og_pilot")
	weapon.mods.append("pas_fast_reload")

	return weapon
}


table function RoguelikeWeapon_CreateWeapon( PRandom rand, string name, int rarity, string slot, string perk1 = "" )
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
        moneyInvested = 80 + 20 * (rarity) // give 10 * rarity dolla when dismantled ()
    }

	array<RoguelikeWeaponPerk> perkArr = Roguelike_GetWeaponPerksForSlotAndWeapon( PERK_SLOT_INHERIT, name )
	if (perkArr.len() > 0)
	{
		item.perkInherited = perkArr[PRandomInt(rand, perkArr.len())].uniqueName
	}
	perkArr = Roguelike_GetWeaponPerksForSlotAndWeapon( PERK_SLOT_PERK, name )
	if (rarity > RARITY_UNCOMMON && perkArr.len() > 0)
		item.perk1 = perkArr[PRandomInt(rand, perkArr.len())].uniqueName

	if (perk1 != "")
		item.perk1 = perk1

	perkArr = Roguelike_GetWeaponPerksForSlotAndWeapon( PERK_SLOT_STAT, name )
	if (rarity > RARITY_COMMON)
		item.bonusStat = perkArr.getrandom().uniqueName

    item.priceOffset += rarity * 50

    return item
}

void functionref (var, var) function RoguelikeWeapon_GetHoverFunc( var menu, bool canEquip, bool canUpgrade, bool isOwned, table ornull item = null )
{
	return void function( var slot, var panel ) : (menu, canEquip, canUpgrade, isOwned, item)
	{
		table data = {}
		bool isEquipped = StartsWith( Hud_GetHudName(slot), "Weapon" )
		if (item != null)
        {
            data = expect table(item)
        }
        else if (isEquipped)
		{
			data = expect table( Roguelike_GetRunData()[Hud_GetHudName(slot)] )
		}
		else
		{
			int elemNum = Grid_GetElemNumForButton( slot )
			data = expect table(Roguelike_GetInventory()[elemNum])
		}

		Hud_EnableKeyBindingIcons( Hud_GetChild( panel, "FooterText") )
		int level = expect int(data.level)
		int price = isOwned ? Roguelike_GetUpgradePrice( data ) : Roguelike_GetPurchasePrice( data )
        string hasEnoughMoney = Roguelike_GetMoney() > price ? "^FFC04000" : "^FF404000"
		array<string> options = []
		if (canUpgrade)
		{
			if (level < Roguelike_GetItemMaxLevel( data ) && isOwned)
			{
				options.append( "%[X_BUTTON|MOUSE2]%Upgrade for " + hasEnoughMoney + price + "$" )
			}
			else
			{
				options.append("MAX LEVEL") 
			}
		}
		if (!isOwned)
		{
			options.append("%[A_BUTTON|MOUSE1]%Purchase for " + hasEnoughMoney + price + "$") 
		}
		if (!isEquipped && isOwned)
			options.append("%[X_BUTTON|F]%Dismantle")
		Hud_SetText( Hud_GetChild( panel, "LevelLabel"), format("Level %i/%i", level, Roguelike_GetItemMaxLevel( data )))
		Hud_SetText( Hud_GetChild( panel, "FooterText" ), JoinStringArray( options, " " ) )

		string weaponClassName = expect string(data.weapon)

		string description = "Primary Weapon"
		string slot = RoguelikeWeapon_GetSlot( weaponClassName )
		switch (slot)
		{
			case "special":
				description = "<green>Movement Tool"
				break
			case "secondary":
				description = "Secondary Weapon"
				break
		}
		Hud_SetText( Hud_GetChild( panel, "SubTitle" ), FormatDescription( description ) )

		Hud_SetText( Hud_GetChild(panel, "Title"), GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "shortprintname" ))
		string weaponDesc =  GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "description" ) 

		switch (Roguelike_GetWeaponElement( weaponClassName ))
		{
			case RoguelikeElement.fire: 
				weaponDesc += FormatDescription( " Deals <burn>Fire</> damage." )
				break
			case RoguelikeElement.electric: 
				weaponDesc += FormatDescription(" Deals <cyan>Energy</> damage.")
				break
			case RoguelikeElement.physical: 
				weaponDesc += FormatDescription(" Deals <daze>Physical</> damage.")
				break
		}

		weaponDesc += "\n\n"


		string formatting = "+%i%% Non-Titan Damage\n"
		string levelFormatting = "Level %i: +%i%% Non-Titan Damage"

		table<int, int> values = {
			[ RARITY_UNCOMMON ] = 0,
			[ RARITY_RARE ] = 0,
			[ RARITY_EPIC ] = 15,
			[ RARITY_LEGENDARY ] = 25
		}
		int valuePerLevel = 15
		table<int, string> rarityNames = {
			[ RARITY_COMMON ] = "Common",
			[ RARITY_UNCOMMON ] = "Uncommon",
			[ RARITY_RARE ] = "Rare",
			[ RARITY_EPIC ] = "Epic",
			[ RARITY_LEGENDARY ] = "Legendary"
		}

		if (slot == "special")
		{
			formatting = "+%i%% Explosion Force\n"
			levelFormatting = "Level %i: +%i%% Explosion Force"
			values = {
				[ RARITY_UNCOMMON ] = 25,
				[ RARITY_RARE ] = 40,
				[ RARITY_EPIC ] = 55,
				[ RARITY_LEGENDARY ] = 70
			}
			valuePerLevel = 25

			int damage = GetWeaponInfoFileKeyField_GlobalInt( weaponClassName, "explosion_damage" )
			float selfDMGMult = Roguelike_GetPilotSelfDamageMult(Roguelike_GetStat( STAT_ENDURANCE ))
			weaponDesc += "Explosion Damage: " + damage
			if (weaponClassName == "mp_weapon_shotgun" || weaponClassName == "mp_weapon_mastiff")
				weaponDesc += "x8"

			weaponDesc += " (" + (damage * selfDMGMult) + " Self Damage)" + "\n\n"
		}

		if (data.bonusStat != "")
		{
			RoguelikeWeaponPerk statPerk = GetWeaponPerkDataByName( data.bonusStat )
			weaponDesc += format(statPerk.description + "\n\n", (statPerk.baseValue + statPerk.valuePerLevel * level) * 100)
		}

		if (data.perkInherited != "")
		{
			RoguelikeWeaponPerk perk1 = GetWeaponPerkDataByName( data.perkInherited )
			weaponDesc += FormatDescription( format("<daze>%s</>: %s\n\n", perk1.name, perk1.description) )
		}

		if (data.perk1 != "")
		{
			RoguelikeWeaponPerk perk1 = GetWeaponPerkDataByName( data.perk1 )
			weaponDesc += FormatDescription( format("<daze>%s</>: %s\n\n", perk1.name, perk1.description) )
		}

		int rarity = expect int(data.rarity)

		if (rarity in values && values[rarity] != 0)
			weaponDesc += FormatDescription(format(rarityNames[rarity] + ": " + formatting, values[rarity]))

		if (level > 0)
		{
			weaponDesc += FormatDescription(format(levelFormatting + "\n\n", level, valuePerLevel * level))
		}

		if (GetDismantleFrac() != -1.0)
		{
			Hud_SetBarProgress( Hud_GetChild( panel, "FooterBar" ), GetDismantleFrac() )
		}
		else
		{
			Hud_SetBarProgress( Hud_GetChild( panel, "FooterBar" ), 0.0 )
		}

		Hud_SetText( Hud_GetChild(panel, "Description"), weaponDesc )
	}
}
