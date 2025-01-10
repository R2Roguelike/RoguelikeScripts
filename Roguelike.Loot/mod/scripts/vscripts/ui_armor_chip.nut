untyped
global function ArmorChips_Init
global function ArmorChip_Generate
global function GetRandomWithExclusion

// use plug_generator.py to generate, then paste in here and format
const array< array<int> > ALL_PLUG_COMBINATIONS = [
    [1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]
]

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
        stats = [0,0,0,0,0,0],
        slot = expect int(chipSlotOrder[slotIndex]),
        level = 0,
        priceOffset = 0,
        rarity = RARITY_COMMON
        moneyInvested = 30 + 15 * (baseRarity) // give 20 dolla when dismantled ()
    }

    chip.rarity <- baseRarity

    chip.pilotEnergy <- GetRandomWithExclusion(0, 3, [])
    chip.titanEnergy <- 3 - chip.pilotEnergy

    chip.pilotEnergy = maxint(expect int(chip.pilotEnergy) + baseRarity - 1, 0)
    chip.titanEnergy = maxint(expect int(chip.titanEnergy) + baseRarity - 1, 0)
    chip.priceOffset += baseRarity * 25

    runData.chipSlotIndex = (++slotIndex) % 4

    array<int> plug = [1, 2, 4]
    plug.randomize()
    for (int i = 0; i < 3; i++)
    {
        chip.stats[i] += plug[i]
    }

    plug = [1, 2, 4]
    plug.randomize()
    for (int i = 0; i < 3; i++)
    {
        chip.stats[i + 3] += plug[i]
    }

    return chip
}

// returns between [min, max] excluding the inner results
// 3, 12, 2
// 3, 4, 5, 6, [7, 8], 9, 10, 11, 12\
int function GetRandomWithExclusion(int start, int end, array<int> exclude) {
    int random = start + RandomInt(end - start + 1 - exclude.len());
    foreach (int ex in exclude) {
        if (random < ex) {
            break;
        }
        random++;
    }
    return random;
}
