globalize_all_functions

int function Roguelike_GetRunSeed()
{
	return GetConVarInt("roguelike_run_seed")
}

int function Roguelike_GetLevelSeed()
{
    return Roguelike_GetRunSeed() + 0xa0b5146f * GetConVarInt("roguelike_levels_completed")
}

PRandom function NewPRandom(int seed)
{
    PRandom rand;
    rand.originalSeed = seed
    rand.seed = seed
    return rand;
}

// uses splitmix32
// probably poor quality in terms of results, but since we have no 64/128 bit types in squirrel
// cant really use a proper algorithm - i could instead do this through native but who wants to bother amirite
int function PRandomInt(PRandom x, int min = 0, int max = 2147483647)
{
    x.seed += 0x9e3779b9
    int z = x.seed;
    z = (z ^ (z >> 16)) * 0x85ebca6b;
    z = (z ^ (z >> 13)) * 0xc2b2ae35;
    z = z ^ (z >> 16);

    if (min != 0 || max != 2147483647)
    {
        if (max != 2147483647)
            return (z % (max - min)) + min
        else
            return (z % min)
    }

    return z
}
float function PRandomFloat(PRandom x, float min = 0, float max = 1)
{
    return PRandomInt(x) / pow(2,31) * (max - min) + min;
}
