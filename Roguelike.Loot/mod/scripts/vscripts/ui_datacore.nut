untyped
global function RoguelikeDatacore_Init
global function RoguelikeDatacore_Generate
global function RoguelikeDatacore_CreateDatacore
global function RoguelikeDatacore_GetHoverFunc

void function RoguelikeDatacore_Init()
{
}

table function RoguelikeDatacore_Generate(PRandom rand)
{
	table runData = Roguelike_GetRunData()

    int levelsComplete = expect int(runData.levelsCompleted)
    int baseRarity = levelsComplete / 2
    float chanceForBetterRarity = GraphCapped( levelsComplete % 2, 0, 2, 0, 1 )
    if (PRandomFloat(rand) < chanceForBetterRarity)
        baseRarity++

    baseRarity = minint(RARITY_RADIANT, maxint(baseRarity, RARITY_COMMON))

	return RoguelikeDatacore_CreateDatacore( rand, baseRarity )
}

table function RoguelikeDatacore_CreateDatacore( PRandom rand, int rarity, string perk1 = "" )
{
    table runData = Roguelike_GetRunData()

	int dashes = PRandomInt( rand, 1, 4 ) // 1-3 inclusive
    table item = {
        type = "datacore",
        level = 0,
        priceOffset = 0,
        rarity = rarity,
		perk1 = "",
        moneyInvested = 80 + 20 * (rarity),
		dashes = dashes
    }

	// dashes
	// 1 dash - 6s cooldown
	// 2 dash - 6s cooldown
	// 3 dash - 6s cooldown

	array<RoguelikeDatacorePerk> perkArr = Roguelike_GetDatacorePerks(rarity + 1)
	if (perkArr.len() > 0)
		item.perk1 = perkArr[PRandomInt(rand, perkArr.len())].uniqueName

    item.priceOffset += rarity * 50

    return item
}

void functionref (var, var) function RoguelikeDatacore_GetHoverFunc( var menu, bool canEquip, bool canUpgrade, bool isOwned, table ornull item = null )
{
	return void function( var slot, var panel ) : (menu, canEquip, canUpgrade, isOwned, item)
	{
		table data = {}
		bool isEquipped = Hud_GetHudName(slot) == "Datacore"
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

		string description = "Titan Datacore"
		Hud_SetText( Hud_GetChild( panel, "SubTitle" ), FormatDescription( description ) )

		Hud_SetText( Hud_GetChild(panel, "Title"), "Datacore" )
		string weaponDesc = ""

		if (data.perk1 != "")
		{
			RoguelikeDatacorePerk perk1 = GetDatacorePerkDataByName( data.perk1 )
			weaponDesc += FormatDescription( format("<daze>%s</>: %s\n\n", perk1.name, perk1.description) )
		}

		int rarity = expect int(data.rarity)

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
