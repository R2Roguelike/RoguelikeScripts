untyped

globalize_all_functions

struct {
    array<RoguelikeMod> mods
} file

void function Mods_Init()
{
    // THIS HAS TO BE FIRST!!!!!!!
    // ALL MODS ARE SET BY DEFAULT TO INDEX 0
    
    {
        RoguelikeMod mod
        mod.uniqueName = "empty"
        mod.name = "EMPTY"
        mod.description = "An empty mod slot. For enough energy, you may equip a mod here."
        mod.icon = $"ui/cog"
        mod.cost = 0
        mod.unlockedByDefault = true
        mod.chip = ALL_CHIP_SLOTS
        Roguelike_RegisterMod(mod)
    }

    // PILOT
    PilotChip1_RegisterMods()
    PilotChip2_RegisterMods()
    PilotChip3_RegisterMods()
    PilotChip4_RegisterMods()

    // TITAN GENERAL
    TitanChip1_RegisterMods()
    TitanChip2_RegisterMods()
    TitanChip3_RegisterMods()
    TitanChip4_RegisterMods()

    // RONIN
    Ronin_RegisterMods()
    
    // SCORCH
    Scorch_RegisterMods()

    // EXPEDITION
    Expedition_RegisterMods()
    
    // LEGION
    Legion_RegisterMods()

    printt("Registered", file.mods.len())
}

void function Roguelike_RegisterMod( RoguelikeMod mod )
{
    mod.index = file.mods.len()
    file.mods.append(mod)
}
RoguelikeMod function Roguelike_NewMod( string uniqueName )
{
    RoguelikeMod mod
    mod.uniqueName = uniqueName
    mod.index = file.mods.len()
    file.mods.append(mod)

    return mod
}


#if UI
array<RoguelikeMod> function GetModsForChipSlot( int chipSlot, bool isTitan, bool includeLocked = false )
{
    array<RoguelikeMod> mods
    foreach (RoguelikeMod mod in file.mods)
    {
        bool unlocked = includeLocked || Roguelike_IsModUnlocked( mod )
        if (Roguelike_IsModCompatibleWithSlot( mod, chipSlot, isTitan ) && unlocked)
            mods.append(mod)
    }

    return mods
}

bool function Roguelike_IsModCompatibleWithSlot( RoguelikeMod mod, int chipSlot, bool isTitan )
{
    if (mod.chip == ALL_CHIP_SLOTS && mod.loadouts.len() <= 0)
        return true
    
    return GetModChipSlotFlags(mod) == chipSlot && isTitan == mod.isTitan
}

bool function Roguelike_IsModUnlocked( RoguelikeMod mod )
{
    if (mod.unlockedByDefault)
        return true

    if (GetConVarBool("roguelike_unlock_all"))
        return true
    
    return expect bool( Roguelike_GetRunData().unlockedMods.contains(mod.uniqueName) )
}
#endif

RoguelikeMod function GetModForIndex( var index )
{
    expect int( index )

    return file.mods[index]
}

RoguelikeMod function GetModByName( var name )
{
    foreach (RoguelikeMod mod in file.mods)
    {
        if (mod.uniqueName == name)
            return mod
    }

    throw "Could not find mod of name " + name
    unreachable
}

// is not typed array cuz this is for storing in rundata
array function GetAllLockedMods()
{
    array result
    foreach (RoguelikeMod mod in file.mods)
    {
        if (!mod.unlockedByDefault && GetModChipSlotFlags(mod) != ALL_CHIP_SLOTS)
            result.append(mod.uniqueName)
    }
    return result
}

int function GetModChipSlotFlags(RoguelikeMod mod)
{
    if (mod.loadouts.len() <= 0)
        return mod.chip
    
    array<string> loadout

    if (mod.isTitan)
        loadout = Roguelike_GetTitanLoadouts()
    else
        loadout = ["mp_weapon_frag_grenade", "mp_ability_cloak"]
    
    int result = 0;
    for (int i = 0; i < loadout.len(); i++)
    {
        if (mod.loadouts.contains(loadout[i]))
        {
            if (mod.useLoadoutChipSlot)
            {
                return (3 + i)
            }
            
            return mod.chip
        }
    }

    return result
}

#if UI
array<RoguelikeMod> function GetModArrayForCategory( int chipIndex, bool isTitanMod )
{
    table runData = Roguelike_GetRunData()
    array<RoguelikeMod> result
    for (int i = 0; i < MOD_SLOTS; i++)
    {
        string runTableIndex = FormatModIndex(chipIndex, isTitanMod, i)
        result.append(GetModForIndex(runData[runTableIndex]))
    }

    return result
}

int function GetTotalEnergyUsed( int chipSlot, bool isTitan )
{
    table runData = Roguelike_GetRunData()
    int result = 0
    for (int i = 0; i < MOD_SLOTS; i++)
    {
        string runTableIndex = FormatModIndex(chipSlot, isTitan, i)
        RoguelikeMod mod = GetModForIndex(runData[runTableIndex])

        result += mod.cost
    }

    return result
}
#endif

string function FormatModIndex( int chipSlot, bool isTitan, int modSlot )
{
    return format("AC%i_%sMod%i", chipSlot, isTitan ? "Titan" : "Pilot", modSlot)
}
