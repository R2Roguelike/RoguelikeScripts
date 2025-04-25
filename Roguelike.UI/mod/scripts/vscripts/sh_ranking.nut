globalize_all_functions

array<int> function GetKillsForMaxRank(string map)
{
    switch (map)
    {
        case "sp_training":
            return [15,9]
        case "sp_tday":
            return [400,300]
        case "sp_timeshift_spoke02":
            return [40,30]
        case "sp_hub_timeshift":
            return [40,20]
        case "sp_boomtown_end":
            return [110, 60]
        case "sp_beacon_spoke0":
            return [50, 30]
        case "sp_sewers1":
            return [300, 200]
    }

    //     [S,A]
    return [350,200]
}

bool function AllowGruntKills(string map)
{
    switch (map)
    {
        case "sp_training":
            return true
        case "sp_timeshift_spoke02":
            return true
        case "sp_beacon_spoke0":
            return true
    }

    //     [S,A]
    return true
}

array<int> function GetTimeForMaxRank(string map)
{
    switch (map)
    {
        case "sp_training":
            return [180, 210]
        case "sp_crashsite":
            return [480, 900]
        case "sp_sewers1":
            return [480, 720]
        case "sp_boomtown_start":
            return [180, 300]
        case "sp_boomtown":
            return [420, 540]
        case "sp_boomtown_end":
            return [240, 360]
        case "sp_timeshift_spoke02":
            return [210, 360]
        case "sp_beacon_spoke0":
            return [180, 270]
        case "sp_hub_timeshift":
            return [210, 420]
        case "sp_tday":
            return [500, 700]
        case "sp_s2s":
            return [720, 1200]
        case "sp_skyway_v1":
            return [720, 1200]
    }

    //     [S,A,B,C]
    return [400, 600]
}

float function GetTimeRankMultiplier()
{
    return 1
}

array< array > rankColors = [
    [255,192, 64,255],
    [192, 64,192,255],
    [ 64,192,255,255],
    [255,255, 64,255],
    [ 64,255, 64,255],
]
array function GetColorForRank(int rank)
{
    rank = maxint(0, minint(rank, 2))
    return rankColors[rank]
}

string function GetRankName(int rank)
{
    switch (rank)
    {
        case 0:
            return "S"
        case 1:
            return "A"
        case 2:
            return "B"
    }

    return "?"
}