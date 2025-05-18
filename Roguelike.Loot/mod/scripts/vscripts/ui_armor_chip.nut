untyped
global function ArmorChips_Init
global function ArmorChip_Generate
global function ArmorChip_GetStats
global function AddStatsArrays
global function ArmorChip_ForceSlot
global function GetRandomWithExclusion

void function ArmorChips_Init()
{
}

table function ArmorChip_Generate()
{
    table runData = Roguelike_GetRunData()
    int slotIndex = expect int(runData.chipSlotIndex)
    array chipSlotOrder = expect array(runData.chipSlotOrder)

    int levelsComplete = expect int(runData.levelsCompleted)
    int baseRarity = levelsComplete / 2
    float chanceForBetterRarity = GraphCapped( levelsComplete % 2, 0, 2, 0, 1 )
    if (RandomFloat(1) < chanceForBetterRarity)
        baseRarity++

    baseRarity = minint(RARITY_LEGENDARY, maxint(baseRarity, RARITY_COMMON))

    table chip = {
        type = "armor_chip",
        subStats = [],
        boosts = [],
        slot = expect int(chipSlotOrder[slotIndex]),
        level = 0,
        priceOffset = 0,
        rarity = RARITY_COMMON
        moneyInvested = 30 + 15 * (baseRarity) // give 20 dolla when dismantled ()
    }

    chip.isTitan <- expect int(chip.slot) <= 4

    if (chip.isTitan)
    {
        chip.mainStat <- RandomIntRange(0,3)
    }
    else
    {
        chip.slot -= 4
        chip.mainStat <- RandomIntRange(3,6)
    }

    chip.rarity <- baseRarity

    chip.energy <- 2

    array<int> subStats = [0,1,2]
    for (int i = 0; i < subStats.len() && !chip.isTitan; i++)
        subStats[i] += 3
    subStats.fastremovebyvalue(expect int(chip.mainStat))

    int subStatCount = 0
    if (baseRarity > RARITY_COMMON)
        subStatCount++
    for (int i = 0; i < minint(subStatCount, 2); i++)
    {
        int result = subStats.getrandom()
        subStats.fastremovebyvalue(result)
        chip.subStats.append(result)
    }
    chip.subStats.sort()

    chip.energy = maxint(expect int(chip.energy) + minint(baseRarity, RARITY_EPIC), 0)
    chip.priceOffset += baseRarity * 25

    runData.chipSlotIndex = (++slotIndex) % 8

    return chip
}

int function ArmorChip_GetMainStatValue( table data )
{
    return ArmorChip_GetStats( data )[expect int(data.mainStat)]
}

int function ArmorChip_GetSubStatValue( table data )
{
    return ArmorChip_GetStats( data )[expect int(data.subStats[0])]
}

array<int> function ArmorChip_GetStats( table data )
{
    array<int> stats = [0,0,0,0,0,0]

    int chipStatIndex = expect int(data.mainStat)
    stats[chipStatIndex] += CHIP_MAIN_STAT_MULT * expect int(data.energy)


    foreach (int index, int val in data.subStats)
    {
        int count = 1
        if (data.rarity == RARITY_EPIC)
            count = 2
        if (data.rarity == RARITY_LEGENDARY)
            count = 3
        foreach (var boost in data.boosts)
        {
            if (boost == index)
                count++
        }
        stats[val] += count * 4
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

table function ArmorChip_ForceSlot( int slot, bool isTitan )
{
    table data = ArmorChip_Generate()
    data.isTitan = isTitan
    data.slot = slot
    data.mainStat = RandomInt( 3 ) + (isTitan ? 0 : 3)
    data.subStats.clear()

    array<int> subStats = [0,1,2,3,4,5]
    subStats.fastremovebyvalue(expect int(data.mainStat))

    for (int i = 0; i < data.rarity; i++)
    {
        int result = subStats.getrandom()
        subStats.fastremovebyvalue(result)
        data.subStats.append(result)
    }
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
