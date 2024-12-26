untyped
global function ArmorChips_Init
global function ArmorChip_Generate
global function GetRandomWithExclusion

// use plug_generator.py to generate, then paste in here and format
const array< array<int> > ALL_PLUG_COMBINATIONS = [
    [1, 1, 4], [1, 2, 3], [1, 3, 2], [1, 4, 1], [2, 1, 3], [2, 2, 2], [2, 3, 1], [3, 1, 2], [3, 2, 1], [4, 1, 1]
]

void function ArmorChips_Init()
{
}

table function ArmorChip_Generate()
{
    table runData = Roguelike_GetRunData()
    int slotIndex = expect int(runData.chipSlotIndex)
    array chipSlotOrder = expect array(runData.chipSlotOrder)

    table chip = {
        type = "armor_chip",
        stats = [0,0,0,0,0,0],
        slot = expect int(chipSlotOrder[slotIndex]),
        level = 1,
        moneyInvested = 15 // give 10 dolla when dismantled ()
    }

    chip.pilotEnergy <- GetRandomWithExclusion(1, 8, [])
    chip.titanEnergy <- 9 - chip.pilotEnergy

    runData.chipSlotIndex = (++slotIndex) % 4

    array<int> plug = ALL_PLUG_COMBINATIONS.getrandom()
    for (int i = 0; i < 3; i++)
    {
        chip.stats[i] += plug[i]
    }

    plug = ALL_PLUG_COMBINATIONS.getrandom()
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
