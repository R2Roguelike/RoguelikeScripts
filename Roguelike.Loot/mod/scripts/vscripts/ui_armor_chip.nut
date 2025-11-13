untyped
global function ArmorChips_Init
global function ArmorChip_Generate
global function ArmorChip_GetStats
global function AddStatsArrays
global function ArmorChip_ForceSlot
global function GetRandomWithExclusion
global function ArmorChip_GetMainStatValue
global function ArmorChip_GetSubStatValue
global function ArmorChip_GetHoverFunc


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
    float chanceForBetterRarity = GraphCapped( levelsComplete % 2, 0, 2, 0, 1 )
    if (PRandomFloat(rand) < chanceForBetterRarity)
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
        subStats = [],
        boosts = [],
        mods = [],
        slot = slot,
        level = 0,
        priceOffset = 0,
        rarity = RARITY_COMMON
        moneyInvested = 80 + 20 * (baseRarity) // give 20 dolla when dismantled ()
    }

    chip.isTitan <- expect int(chip.slot) <= 4

    if (chip.isTitan)
    {
        chip.mainStat <- PRandomInt(rand,STAT_TITAN_COUNT)
    }
    else
    {
        chip.slot -= 4
        chip.mainStat <- PRandomInt(rand, STAT_TITAN_COUNT, STAT_TITAN_COUNT * 2)
        

        // REWORK - random mods
        slot = expect int(chip.slot)
        array<RoguelikeMod> pool = GetModsForChipSlot( slot, false, true )

        while (chip.mods.len() < minint(baseRarity + 1, 4))
        {
            int chosen = PRandomInt( rand, pool.len() )
            int index = pool[chosen].index
            if (chip.mods.contains(index))
                continue
            
            chip.mods.append(index)
        }
    }

    chip.rarity <- baseRarity

    chip.energy <- 2

    array<int> subStats = [0,1,2,3]
    for (int i = 0; i < subStats.len() && !chip.isTitan; i++)
        subStats[i] += STAT_TITAN_COUNT
    subStats.fastremovebyvalue(expect int(chip.mainStat))

    int subStatCount = 1
    for (int i = 0; i < minint(subStatCount, 2); i++)
    {
        int result = subStats[PRandomInt(rand, subStats.len())]
        subStats.fastremovebyvalue(result)
        chip.subStats.append(result)
    }
    chip.subStats.sort()

    chip.energy = maxint(expect int(chip.energy) + baseRarity, 0)
    chip.priceOffset += baseRarity * 50

    return chip
}

int function ArmorChip_GetMainStatValue( table data )
{
    return ArmorChip_GetStats( data )[expect int(data.mainStat)]
}

int function ArmorChip_GetSubStatValue( table data )
{
    if (data.subStats.len() < 1)
        return 0
    return ArmorChip_GetStats( data )[expect int(data.subStats[0])]
}

array<int> function ArmorChip_GetStats( table data )
{
    array<int> stats = [0,0,0,0,0,0,0,0]

    int chipStatIndex = expect int(data.mainStat)
    stats[chipStatIndex] += CHIP_MAIN_STAT_MULT * expect int(data.energy)


    foreach (int index, int val in data.subStats)
    {
        int count = 0
        switch (expect int(data.rarity))
        {
            case RARITY_UNCOMMON:
            case RARITY_RARE:
                count += 1
                break
            case RARITY_EPIC:
            case RARITY_LEGENDARY:
                count += 2
                break
            case RARITY_MYTHIC:
            case RARITY_STELLAR:
                count += 3
                break
            case RARITY_RADIANT:
                count += 4
                break
        }
        foreach (var boost in data.boosts)
        {
            if (boost == index)
                count++
        }
        stats[val] += count * CHIP_SUB_STAT_MULT
    }

    return stats
}

void function AddStatsArrays(array<int> a, array<int> b)
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
        int rarity = expect int(data.rarity)
        int price = isOwned ? Roguelike_GetUpgradePrice( data ) : Roguelike_GetPurchasePrice( data )

        table equippedChip = expect table( Roguelike_GetRunData()["AC" + GetTitanOrPilotFromBool(isTitan) + slot ] )

        array<string> options = []
        string hasEnoughMoney = Roguelike_GetMoney() > price ? "^FFC04000" : "^FF404000"
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

        Hud_SetColor( energyLabel, 25, 25, 25, 255 )
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

        int totalEnergy = expect int(data.energy)
        Hud_SetBarProgress( levelBar, float(totalEnergy) / segmentCount - 0.0001 )
        Hud_SetColor( levelBar, 25, 25, 25, 255 )
        Hud_SetColor( title, 25, 25, 25, 255 )
        Hud_SetColor( titleStrip, 40, 40, 40, 255 )
        Hud_SetColor( bg, 25, 25, 25, 255 )


        Hud_SetColor( title, 25, 25, 25, 255 )

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

        int mainStat = expect int(data.mainStat) 
        int statNameIndex = mainStat
        string stat = STAT_NAMES[statNameIndex]
        var statPanel = Hud_GetChild(panel, "Stat0")
        int value = CHIP_MAIN_STAT_MULT
        value *= expect int(data.energy)

        var bar = Hud_GetChild(statPanel, "Bar")
        var label = Hud_GetChild(statPanel, "Label")
        var valueText = Hud_GetChild(statPanel, "Value")
        Hud_SetColor( title, r, g, b, 255 )
        Hud_SetColor( levelBar, r, g, b, 255 )

        Hud_SetColor(bar, r, g, b, 255)
        Hud_SetColor(label, r, g, b, 255)

        Hud_SetBarProgress(bar, value / 60.0)
        Hud_SetText(label, stat)
        Hud_SetText(valueText, "+" + value)

        string text = ""
        text += "<chip>" + STAT_NAMES[data.subStats[0]] + "</> +" + ArmorChip_GetSubStatValue(data) + "\n"
        
        text += "\n<chip>Total:</> " + (ArmorChip_GetMainStatValue(data) + ArmorChip_GetSubStatValue(data)) + "\n"

        if (isTitan)
        {
            
            text += "\n<chip>1st Upgrade:" + (level >= 1 ? "<daze>" :"<note>") + " +1 Energy, +5 Main Stat"
                + "\n<chip>2nd Upgrade:" + (level >= 2 ? "<daze>" :"<note>") + " +1 Mod Slot, +5 Sub Stat"
                + "\n<chip>3rd Upgrade:" + (level >= 3 ? "<daze>" :"<note>") + " +1 Energy, +5 Main Stat"
        }
        else
        {

        }

        text = FormatDescription( text )
        text = StringReplace( text, "<chip>", format("^%02X%02X%02X00", r, g, b), true )
        //print(text)
        Hud_SetText(Hud_GetChild(panel, "SubStats"), text)


        if (data != equippedChip && canEquip)
        {
            for (int i = 0; i < STAT_COUNT; i++)
            {
                string statName = STAT_NAMES[i]
                var statPanel = Hud_GetChild( menu, statName + "Stat" )
                int diff = ArmorChip_GetStats(data)[i] - ArmorChip_GetStats( equippedChip )[i]

                Hud_SetText(Hud_GetChild( statPanel, "Diff"), diff > 0 ? "+" + diff : string(diff))
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
