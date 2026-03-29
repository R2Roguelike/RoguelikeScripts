globalize_all_functions

RoguelikeStatModifier function NewStatModifier(string stat, float val)
{
    RoguelikeStatModifier mod
    mod.stat = stat
    mod.amount = val

    return mod
}

bool function Roguelike_HasTitanLoadout(string weapon)
{
    return Roguelike_GetTitanLoadouts().contains(weapon)
}

int function Roguelike_GetUpgradePrice( table item )
{
    int level = expect int(item.level)
    int price = 100 + (level * 50) + expect int(item.rarity) * 50

    if (item.type == "armor_chip" && item.level == 3)
        return 200

    return price
}

int function Roguelike_GetPurchasePrice( table item )
{
    return SHOP_LOOT_PRICE + SHOP_LOOT_PRICE_PERRARITY * expect int(item.rarity)
}

int function Roguelike_GetItemMaxLevel( table item )
{
    switch (item.type)
    {
        case "armor_chip":
            return MAX_CHIP_LEVEL
        case "weapon":
        case "grenade":
            return 3
    }

    return 0
}

string function GetTitanOrPilotFromBool( bool isTitan )
{
    return isTitan ? "Titan" : "Pilot"
}

// first element is name, 2nd element is description
array function GetTitanTextColor(string primary)
{
    switch (primary)
    {
        case "mp_titanweapon_leadwall":
        case "mp_titanweapon_particle_accelerator":
            return [0, 0, 0, 255]
    }

    return [255, 255, 255, 255]
}

array function GetModColor( RoguelikeMod mod )
{
    if (mod.colorTag != "")
        return GetTitanColor( mod.colorTag )
    
    if (mod.loadouts.len() == 1 && mod.isTitan)
    {
        RoguelikeLoadout ornull loadout = Roguelike_GetLoadoutFromWeapon( mod.loadouts[0] )
        expect RoguelikeLoadout( loadout )
        return loadout.color
    }
    if (mod.loadouts.len() == 2)
    {
        return [151, 255, 33, 255]
    }

    return [255,255,255,255]
}

// first element is name, 2nd element is description
array function GetTitanColor(string primary)
{
    switch (primary)
    {
        case "mp_titanweapon_leadwall":
            return [255, 225, 100, 255]
        case "mp_titanweapon_meteor":
            return [255, 175, 75, 255]
        case "mp_titanweapon_xo16_shorty":
            return [177, 94, 255, 255]
        case "mp_titanweapon_predator_cannon":
            return [255, 64, 64, 255]
        case "mp_titanweapon_sniper":
            return [64, 96, 255, 255]
        case "mp_titanweapon_particle_accelerator":
            return [64, 255, 255, 255]
        case "mp_titanweapon_sticky_40mm":
            return [32, 200, 32, 255]
        case "empty":
            return [255, 255, 255, 255]
    }

    return [255,255,255,255]
}

// first element is name, 2nd element is description
array<string> function GetTitanLoadoutPassiveData()
{
    return ["No Passive", "No passive is active for this loadout combination."]
}

