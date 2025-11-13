untyped
global function RoguelikeGrenade_Init
global function RoguelikeGrenade_Generate
global function RoguelikeGrenade_CreateWeapon
global function RoguelikeGrenade_GetSlot
global function RoguelikeGrenade_GetHoverFunc

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

table function RoguelikeGrenade_Generate(PRandom rand)
{
	table runData = Roguelike_GetRunData()

	string weapon = ROGUELIKE_GRENADES[PRandomInt(rand, ROGUELIKE_GRENADES.len())]

    int levelsComplete = expect int(runData.levelsCompleted)
    int baseRarity = levelsComplete / 2
    float chanceForBetterRarity = GraphCapped( levelsComplete % 2, 0, 2, 0, 1 )
    if (RandomFloat(1) < chanceForBetterRarity)
        baseRarity++

    baseRarity = minint(RARITY_RADIANT, maxint(baseRarity, RARITY_COMMON))

	return RoguelikeGrenade_CreateWeapon( rand, weapon, baseRarity, RoguelikeGrenade_GetSlot( weapon ) )
}

table function RoguelikeGrenade_CreateWeapon( PRandom rand, string name, int rarity, string perk1 = "" )
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
        moneyInvested = 80 + 20 * (rarity) // give 10 * rarity dolla when dismantled ()
    }

	array<RoguelikeWeaponPerk> perkArr = Roguelike_GetWeaponPerksForSlotAndWeapon( PERK_SLOT_GRENADE, name )
    if (rarity > RARITY_UNCOMMON && perkArr.len() > 0)
        item.perk1 = perkArr[PRandomInt( rand, perkArr.len() )].uniqueName

    item.priceOffset += rarity * 50

    return item
}

void functionref(var, var) function RoguelikeGrenade_GetHoverFunc( var menu, bool canEquip, bool canUpgrade, bool isOwned, table ornull item = null )
{
    return void function(var slot, var panel) : (menu, canEquip, canUpgrade, isOwned, item)
    {
        table data = {}
        bool isEquipped = Hud_GetHudName(slot) ==  "Grenade"
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
            if (level < Roguelike_GetItemMaxLevel( data ))
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
            options.append("%[A_BUTTON|MOUSE1]%Purchase for " + price + "$") 
        }
        if (!isEquipped && isOwned)
            options.append("%[X_BUTTON|F]%Dismantle")
        Hud_SetText( Hud_GetChild( panel, "LevelLabel"), format("Level %i/%i", level, Roguelike_GetItemMaxLevel( data )))
        Hud_SetText( Hud_GetChild( panel, "FooterText" ), JoinStringArray( options, " " ) )

        string weaponClassName = expect string(data.weapon)
        int rarity = expect int(data.rarity)

        string description = "Grenade"
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
        string formatting = "+%i%% Damage\n"
        string levelFormatting = "Level %i: -%i%% Cooldown\n\n"
        table<int, string> rarityNames = {
            [ RARITY_COMMON ] = "Common",
            [ RARITY_UNCOMMON ] = "Uncommon",
            [ RARITY_RARE ] = "Rare",
            [ RARITY_EPIC ] = "Epic",
            [ RARITY_LEGENDARY ] = "Legendary"
        }
        table<int, int> values = {
            [ RARITY_UNCOMMON ] = 0,
            [ RARITY_RARE ] = 0,
            [ RARITY_EPIC ] = 15,
            [ RARITY_LEGENDARY ] = 25
        }
        if (rarity in values && values[rarity] != 0)
            weaponDesc += FormatDescription(format(rarityNames[rarity] + ": " + formatting, values[rarity]))
        
        if (level > 0)
            weaponDesc += FormatDescription(format(levelFormatting, level, level * 10))

        if (data.bonusStat != "")
        {
            RoguelikeWeaponPerk statPerk = GetWeaponPerkDataByName( data.bonusStat )
            weaponDesc += format(statPerk.description + "\n", (statPerk.baseValue + statPerk.valuePerLevel * level) * 100)
        }

        if (data.perk1 != "")
        {
            RoguelikeWeaponPerk perk1 = GetWeaponPerkDataByName( data.perk1 )
            weaponDesc += format("%s: %s\n", perk1.name, perk1.description)
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