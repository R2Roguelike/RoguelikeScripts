globalize_all_functions

int function Roguelike_GetRunSeed()
{
	return GetConVarInt("roguelike_run_seed")
}

int function Roguelike_GetLevelSeed()
{
    return Roguelike_GetRunSeed() + 0xa0b5146f * GetConVarInt("roguelike_levels_completed")
}

PRandom function NewPRandom(int seed, int iterations = 0)
{
    PRandom rand;
    rand.iterations = iterations
    rand.seed = seed
    return rand;
}

// uses splitmix32
// probably poor quality in terms of results, but since we have no 64/128 bit types in squirrel
// cant really use a proper algorithm - i could instead do this through native but who wants to bother amirite
int function PRandomInt(PRandom x, int min = 0, int max = 2147483647)
{
    int result = PRandomInt_Internal(x.seed, x.iterations) // mersenne twister
    x.iterations += 1

    if (max == 2147483647 && min > 0)
    {
        max = min
        min = 0
    }
    if (max == min)
        return min
    result = result % (max - min)
    if (result < 0)
        result *= -1 // force positive
    return result + min
}
float function PRandomFloat(PRandom x, float min = 0, float max = 1)
{
    return float(PRandomInt(x)) / pow(2,31) * (max - min) + min;
}
