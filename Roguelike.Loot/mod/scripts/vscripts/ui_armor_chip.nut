untyped
global function ArmorChips_Init
global function ArmorChip_Generate
global function ArmorChip_GetStats
global function AddStatsArrays
global function ArmorChip_ForceSlot
global function GetRandomWithExclusion
global function ArmorChip_GetMainStatValue
//global function ArmorChip_GetSubStatValue
global function ArmorChip_GetHoverFunc
global function ArmorChip_GetMaxEnergy


void function ArmorChips_Init()
{
}

table function ArmorChip_Generate(PRandom rand, bool isShop, int forceSlot = -1)
{
    table runData = Roguelike_GetRunData()
    int slotIndex = expect int(runData.chipSlotIndex)
    array chipSlotOrder = expect array(runData.chipSlotOrder)

    int levelsComplete = expect int(runData.levelsCompleted)
    int baseRarity = levelsComplete / 2
    int chanceForBetterRarity = levelsComplete % 2
    if (PRandomInt(rand, 2) < chanceForBetterRarity)
        baseRarity++

    baseRarity = minint(RARITY_RADIANT, maxint(baseRarity, RARITY_COMMON))

    int slot = PRandomInt(rand, 1, 9)
    if (forceSlot != -1)
        slot = forceSlot
    if (!isShop)
    {
        slot = expect int(chipSlotOrder[slotIndex])
        runData.chipSlotIndex = (++slotIndex) % 8
    }
    table chip = {
        type = "armor_chip",
        mainStats = [],
        //subStats = [],
        mods = [],
        slot = slot,
        level = 0,
        rarity = RARITY_COMMON
        moneyInvested = 80 + 20 * (baseRarity) // give 20 dolla when dismantled ()
    }

    chip.isTitan <- expect int(chip.slot) <= 4
    
    array<RoguelikeStat> stats
    if (chip.isTitan)
    {
        stats = Roguelike_GetStatsForSide(true)
        for (int i = 0; i < 3; i++)
        {
            int selection = PRandomInt(rand, stats.len())
            chip.mainStats.append( stats[selection].index )
            stats.fastremove(selection)
        }
    }
    else
    {
        stats = Roguelike_GetStatsForSide(false)
        chip.slot -= 4
        for (int i = 0; i < 3; i++)
        {
            int selection = PRandomInt(rand, stats.len())
            chip.mainStats.append( stats[selection].index )
            stats.fastremove(selection)
        }
    }

    chip.rarity <- baseRarity

    /*array<int> subStats = []
    foreach (RoguelikeStat stat in stats)
    {
        if (stat.index != chip.mainStat)
            subStats.append(stat.index)
    }*/

    /*int subStatCount = 2
    for (int i = 0; i < minint(subStatCount, 2); i++)
    {
        int result = subStats[PRandomInt(rand, subStats.len())]
        subStats.fastremovebyvalue(result)
        chip.subStats.append(result)
    }*/
    //chip.subStats.sort()

    return chip
}

float function ArmorChip_GetMainStatValue( table data, int index )
{
    return ArmorChip_GetStats( data )[expect int(data.mainStats[index])]
}

/*float function ArmorChip_GetSubStatValue( table data, int index )
{
    if (data.subStats.len() <= index)
        return 0
    return ArmorChip_GetStats( data )[expect int(data.subStats[index])]
}*/

array<float> function ArmorChip_GetStats( table data )
{
    array<float> stats = NewStatArray(false)

    //int chipStatIndex = expect int(data.mainStat)
    int baseRarity = expect int(data.rarity)
    int mainStatValue = 3 + baseRarity
    if (data.level >= 1)
        mainStatValue++
    if (data.level >= 3)
        mainStatValue++

    foreach (int index, int val in data.mainStats)
    {
        RoguelikeStat subStat = GetStatForIndex(val)
        /*int count = 0 // 3 / 0 - 5 / 1
        switch (expect int(data.rarity))
        {
            case RARITY_COMMON: // 3 / 0 - 5 / 1
                count = 0
                break
            case RARITY_UNCOMMON: // 4 / 1 - 6 / 2 
                count = 1
                break
            case RARITY_RARE: // 5 / 2 - 7 / 3
                count = 2
                break
            case RARITY_EPIC: // 6 / 3 - 8 / 4
                count = 3
                break
            case RARITY_LEGENDARY: // 7 / 4 - 9 / 5
                count = 4
                break
            case RARITY_MYTHIC: // 8 / 4 - 10 / 5
                count = 5
                break
            case RARITY_STELLAR: // 8 / 4 - 10 / 5
                count = 5
                break
            case RARITY_RADIANT: // 9 / 5 - 11 / 6
            default:
                count = 6
                break
        }
        if (data.level >= 2)
            count++*/
        
        stats[val] += mainStatValue * subStat.chipValue
    }

    return stats
}

void function AddStatsArrays(array<float> a, array<float> b)
{
    if (a.len() != b.len())
        throw "arrays not of equal len"

    for (int i = 0; i < a.len(); i++)
    {
        a[i] += b[i]
    }
}

table function ArmorChip_ForceSlot( PRandom rand, int slot, bool isTitan )
{
    int actualSlot = isTitan ? slot : slot + 4
    table data = ArmorChip_Generate(rand, true, actualSlot)

    return data
}

// returns between [min, max) excluding the inner results
// 3, 12, 2
// 3, 4, 5, 6, [7, 8], 9, 10, 11
int function GetRandomWithExclusion(int start, int end, array<int> exclude) {
    int random = start + RandomInt(end - start - exclude.len());
    foreach (int ex in exclude) {
        if (random < ex) {
            break;
        }
        random++;
    }
    return random;
}

int function ArmorChip_GetMaxEnergy(var data)
{
    expect table(data)
    int base = 2
    base += expect int(data.rarity)
    if (data.level >= 1)
        base++
    if (data.level >= 3)
        base++

    return base
}

void functionref(var, var) function ArmorChip_GetHoverFunc( var menu, bool canEquip, bool canUpgrade, bool isOwned, table ornull item = null )
{
    return void function( var slot, var panel ) : (menu, canEquip, canUpgrade, isOwned, item)
    {
        table data = {}
        bool isEquipped = StartsWith( Hud_GetHudName(slot), "AC" )
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
        bool isTitan = expect bool(data.isTitan)
        int slot = expect int( data.slot )
        int level = expect int(data.level)
        int price = isOwned ? Roguelike_GetUpgradePrice( data ) : Roguelike_GetPurchasePrice( data )
        int maxRarityObtained = expect int(Roguelike_GetRunData().maxRarityObtained)

        table equippedChip = expect table( Roguelike_GetRunData()["AC" + GetTitanOrPilotFromBool(isTitan) + slot ] )

        array<string> options = []
        string hasEnoughMoney = Roguelike_GetMoney() > price ? "^FFC04000" : "^FF404000"
		if (canUpgrade)
		{
			if (level < Roguelike_GetItemMaxLevel( data ) || maxRarityObtained > data.rarity)
			{
				options.append( "%[X_BUTTON|MOUSE2]%Upgrade - " + hasEnoughMoney + price + "$" )
			}
			else
			{
				options.append("NEXT UPGRADE LOCKED") 
			}
		}
		if (!isOwned)
		{
			options.append("%[A_BUTTON|MOUSE1]%Purchase for " + hasEnoughMoney + price + "$") 
		}
        if (!isEquipped && isOwned)
            options.append("%[X_BUTTON|F]%Dismantle")
        Hud_SetText( Hud_GetChild( panel, "FooterText" ), JoinStringArray( options, " " ) )

        Hud_SetText( Hud_GetChild( panel, "Title" ), isTitan ? "TITAN CHIP" : "PILOT CHIP")

        var titleStrip = Hud_GetChild(panel, "TitleStrip")
        var title = Hud_GetChild(panel, "Title")
        var bg = Hud_GetChild(panel, "BG")
        var levelBar = Hud_GetChild(panel, "EnergyBar1")
        var barBG = Hud_GetChild(panel, "EnergyBarBG")
        var energyLabel = Hud_GetChild(panel, "EnergyCount")

        Hud_SetColor( energyLabel, 20, 20, 20, 255 )
        Hud_SetText( energyLabel, format("Level %i/%i", data.level, Roguelike_GetItemMaxLevel( data )) )

        Hud_SetBarProgress( barBG, 1.0 )
        Hud_SetX( levelBar, 0 )


        int segmentCount = 8
        int length = Hud_GetWidth( levelBar )
        int gap = segmentCount - length % segmentCount
        if (segmentCount - length % segmentCount < 1)
            gap = (segmentCount - length % segmentCount) + segmentCount

        int segmentWidth = (length + gap) / segmentCount - gap

        Hud_SetBarSegmentInfo( levelBar, gap, segmentWidth )
        Hud_SetBarSegmentInfo( barBG, gap, segmentWidth )

        int totalEnergy = ArmorChip_GetMaxEnergy(data)
        Hud_SetBarProgress( levelBar, float(totalEnergy) / segmentCount - 0.0001 )
        Hud_SetColor( levelBar, 20, 20, 20, 255 )
        Hud_SetColor( title, 20, 20, 20, 255 )
        Hud_SetColor( titleStrip, 40, 40, 40, 255 )
        Hud_SetColor( bg, 20, 20, 20, 255 )


        Hud_SetColor( title, 20, 20, 20, 255 )

        int r = 0, g = 0, b = 0
        int color = isTitan ? slot : 5 - slot
        switch (color)
        {
            case 1:
                r = 0
                g = 214
                b = 255
                break
            case 2:
                r = 165
                g = 255
                b = 0
                break
            case 3:
                r = 197
                g = 0
                b = 255
                // note, this  slightly breaks the square pallette in favor of accessibility
                break
            case 4:
                r = 255
                g = 117
                b = 0
                break
        }

        for (int i = 0; i < 3; i++)
        {
            int mainStat = expect int(data.mainStats[i]) 
            int statNameIndex = mainStat
            RoguelikeStat mainStatData = GetStatForIndex(mainStat)
            string stat = mainStatData.name

            var statPanel = Hud_GetChild(panel, "Stat" + i)
            float value = ArmorChip_GetMainStatValue(data, i)

            //var bar = Hud_GetChild(statPanel, "Bar")
            var label = Hud_GetChild(statPanel, "Label")
            var valueText = Hud_GetChild(statPanel, "Value")

            Hud_SetColor(label, r, g, b, 255)

            Hud_SetText(label, FormatDescription(stat))
            Hud_SetText(valueText, "+" + Roguelike_FormatStatValue(mainStatData, value))
        }
        Hud_SetColor( Hud_GetChild(panel, "EnergyIcon"), r, g, b, 255 )
        Hud_SetColor( title, r, g, b, 255 )
        Hud_SetColor( levelBar, r, g, b, 255 )

        //Hud_SetColor(bar, r, g, b, 255)
        
        string text = ""
        /*foreach (int index, var subStat in data.subStats)
        {
            expect int (subStat)
            RoguelikeStat subStatData = GetStatForIndex(subStat)
            text += "+" + Roguelike_FormatStatValue(subStatData, ArmorChip_GetSubStatValue(data, index)) + " <chip>" + subStatData.name + "</>" + "\n"
        }*/
        
        //text += "\n<chip>Total:</> " + (ArmorChip_GetMainStatValue(data) + ArmorChip_GetSubStatValue(data)) + "\n"

        if (isTitan)
        {
            
            text += "\n<chip>1st Upgrade:" + (level >= 1 ? "<daze>" :"<note>") + " +1 Energy, All Stats Increase"
                + "\n<chip>2nd Upgrade:" + (level >= 2 ? "<daze>" :"<note>") + " +1 Mod Slot"
                + "\n<chip>3rd Upgrade:" + (level >= 3 ? "<daze>" :"<note>") + " +1 Energy, All Stats Increase"
                + "\n<chip>4th Upgrade:<note> " + (maxRarityObtained > data.rarity ? "Rarity increases, Upgrades reset." : "LOCKED (Obtain item of higher\nrarity first)") 
        }
        else
        {
            text += "\n<chip>1st Upgrade:" + (level >= 1 ? "<daze>" :"<note>") + " +1 Energy, Main Stat Increases"
                + "\n<chip>2nd Upgrade:" + (level >= 2 ? "<daze>" :"<note>") + " +1 Mod Slot, Sub Stats Increase"
                + "\n<chip>3rd Upgrade:" + (level >= 3 ? "<daze>" :"<note>") + " +1 Energy, Main Stat Increases"
                + "\n<chip>4th Upgrade:<note> " + (maxRarityObtained > data.rarity ? "Rarity increases, Upgrades reset." : "LOCKED (Obtain item of higher\nrarity first)") 
        }

        text = FormatDescription( text )
        text = StringReplace( text, "<chip>", format("^%02X%02X%02X00", r, g, b), true )
        //print(text)
        Hud_SetText(Hud_GetChild(panel, "SubStats"), text)


        if (data != equippedChip && canEquip)
        {
            array<float> dataStats = ArmorChip_GetStats(data)
            array<float> equippedStats = ArmorChip_GetStats( equippedChip )
            array<RoguelikeStat> stats = Roguelike_GetStatsForSide(isTitan, true)
            for (int i = 0; i < stats.len(); i++)
            {
                if (stats[i].isHeader)
                    continue
                int statIndex = stats[i].index
                string statName = stats[i].name
                var statPanel = Inventory_GetStatPanel( isTitan, i )
                float diff = dataStats[statIndex] - equippedStats[statIndex]
                string text = Roguelike_FormatStatValue(stats[i], diff)
                if (stats[i].diminishingReturns)
                {
                    float curValue = Roguelike_GetStatRaw(stats[i].uniqueName)
                    
                    text = format("%.1f%%", (100.0 / (1.0 + curValue * 1.0)) - (100.0 / (1.0 + (curValue + diff))))
                }


                Hud_SetText(Hud_GetChild( statPanel, "Diff"), diff > 0 ? "+" + text : text)
                if (diff > 0)
                {
                Hud_SetColor(Hud_GetChild( statPanel, "Diff"), 0, 255,0, 255)
                }
                else if (diff == 0)
                {
                Hud_SetColor(Hud_GetChild( statPanel, "Diff"), 128, 128,128, 255)
                }
                else
                {
                Hud_SetColor(Hud_GetChild( statPanel, "Diff"), 255, 0,0, 255)
                }
            }
            stats = Roguelike_GetStatsForSide(!isTitan, true)
            for (int i = 0; i < stats.len(); i++)
            {
                Hud_SetText(Hud_GetChild( Inventory_GetStatPanel( !isTitan, i ), "Diff"), "")
            }
            if (panel.GetPanelAlpha() > 0.0)
                Roguelike_InventorySetLastDiffSetTime(Time())
        }

        if (GetDismantleFrac() != -1.0)
        {
            Hud_SetBarProgress( Hud_GetChild( panel, "FooterBar" ), GetDismantleFrac() )
        }
        else
        {
            Hud_SetBarProgress( Hud_GetChild( panel, "FooterBar" ), 0.0 )
        }
    }
}
