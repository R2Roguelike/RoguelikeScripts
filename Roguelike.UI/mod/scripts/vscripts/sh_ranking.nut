globalize_all_functions

array<int> function GetKillsForMaxRank(string map)
{
    switch (map)
    {
        case "sp_training":
            return [15,12,9,6]
        case "sp_sewers1":
            return [135,115,95,75]
        case "sp_tday":
            return [400,350,300,250]
    }

    //     [C,B,A,S]
    return [100,75,62,50]
}

array<int> function GetTimeForMaxRank(string map)
{
    switch (map)
    {
        case "sp_training":
            return [120, 165, 210, 255]
        case "sp_sewers1":
            return [420, 600, 780, 960]
        case "sp_boomtown_start":
            return [180, 240, 300, 420]
        case "sp_boomtown":
            return [420, 480, 540, 600]
        case "sp_boomtown_end":
            return [120, 480, 540, 600]
        case "sp_timeshift_spoke02":
            return [180, 220, 270, 320]
        case "sp_hub_timeshift":
            return [150, 200, 250, 300]
        case "sp_tday":
            return [300, 400, 500, 600]
    }

    //     [S,A,B,C]
    return [360, 540, 720, 900]
}

float function GetTimeRankMultiplier()
{
    switch (GetConVarInt( "sp_difficulty" ))
    {
        case 0:
            return 1.5
        case 1:
            return 1.25
    }
    return 1
}

array< array > rankColors = [
    [255, 32, 32,255],
    [255,128, 32,255],
    [255,255, 32,255],
    [ 32,255, 32,255],
    [ 32, 32,255,255]
]
array function GetColorForRank(int rank)
{
    rank = maxint(0, minint(rank, 4))
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
        case 3:
            return "C"
        case 4:
            return "D"
    }

    return "?"
}