untyped

globalize_all_functions

struct {
    array<RoguelikeMod> mods
    array<RoguelikeRunModifier> modifiers
    array<RoguelikeWeaponPerk> perks
} file

void function Mods_Init()
{
    // THIS HAS TO BE FIRST!!!!!!!
    // ALL MODS ARE HARDCODED TO DEFAULT TO INDEX 0

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

    // NORTHSTAR
    Northstar_RegisterMods()

    // SCORCH
    Scorch_RegisterMods()

    // EXPEDITION
    Expedition_RegisterMods()

    // LEGION
    Legion_RegisterMods()

    // ION
    Ion_RegisterMods()

    printt("Registered", file.mods.len())
    int loadoutSpecific = 0
    table<string, int> modsPerLoadout
    foreach (RoguelikeMod mod in file.mods)
    {
        if (mod.loadouts.len() > 0)
        {
            loadoutSpecific++
            foreach (string loadout in mod.loadouts)
            {
                if (loadout in modsPerLoadout)
                    modsPerLoadout[loadout]++
                else
                    modsPerLoadout[loadout] <- 1
            }
        }
    }
    printt(loadoutSpecific, "of which are loadout specific")
    foreach (string loadout, int val in modsPerLoadout)
    {
        printt(loadout, val)
    }
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

RoguelikeRunModifier function Roguelike_NewRunModifier( string uniqueName )
{
    RoguelikeRunModifier mod
    mod.uniqueName = uniqueName
    mod.index = file.modifiers.len()
    file.modifiers.append(mod)

    return mod
}

RoguelikeWeaponPerk function Roguelike_NewWeaponPerk( string uniqueName )
{
    RoguelikeWeaponPerk perk
    perk.uniqueName = uniqueName
    perk.index = file.perks.len()
    file.perks.append(perk)

    return perk
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

bool function CheckMods()
{
    bool result = true
    array<string> abbreviationsPilot = []
    array<string> abbreviationsTitan = []
    foreach (RoguelikeMod mod in file.mods)
    {
        array<string> target = abbreviationsPilot
        if (mod.isTitan)
            target = abbreviationsTitan
        if (mod.abbreviation == "XXX")
        {
            result = false
            printt("mod", mod.name, "has no abberviation")
        }
        else if (target.contains(mod.abbreviation))
        {
            result = false
            printt(mod.name, "uses abbreviation", mod.abbreviation, "which is already used by another mod")
        }
        else
        {
            target.append(mod.abbreviation)
        }
    }

    return result
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

RoguelikeRunModifier function GetRunModifierDataByName( var name )
{
    foreach (RoguelikeRunModifier mod in file.modifiers)
    {
        if (mod.uniqueName == name)
            return mod
    }

    string error = "Could not find modifier of name \"" + name + "\""
    throw error
    unreachable
}

RoguelikeWeaponPerk function GetWeaponPerkDataByName( var name )
{
    foreach (RoguelikeWeaponPerk mod in file.perks)
    {
        if (mod.uniqueName == name)
            return mod
    }

    string error = "Could not find modifier of name \"" + name + "\""
    throw error
    unreachable
}

array<RoguelikeWeaponPerk> function Roguelike_GetWeaponPerksForSlotAndWeapon( int slot, string weapon = "" )
{
    array<RoguelikeWeaponPerk> result = []
    foreach (RoguelikeWeaponPerk mod in file.perks)
    {
        if (mod.slot == slot)
        {
            if (mod.allowedWeapons.len() <= 0 || mod.allowedWeapons.contains(weapon))
                result.append(mod)
        }
    }

    return result
}

RoguelikeMod function GetModByName( var name )
{
    foreach (RoguelikeMod mod in file.mods)
    {
        if (mod.uniqueName == name)
            return mod
    }

    string error = "Could not find mod of name \"" + name + "\""
    throw error
    unreachable
}

// is not typed array cuz this is for storing in rundata
array function GetAllLockedMods()
{
    array result
    array<string> loadouts = Roguelike_GetTitanLoadouts()
    foreach (RoguelikeMod mod in file.mods)
    {
        bool isModAvailable = mod.loadouts.len() == 0
        foreach (string loadout in mod.loadouts)
        {
            if (loadouts.contains(loadout))
            {
                isModAvailable = true
                break;
            }
        }
        if (!mod.unlockedByDefault && isModAvailable)
            result.append(mod.uniqueName)
    }
    printt("total pool of", result.len(), "mods")
    return result
}
array function GetAllLockedPilotMods()
{
    array result
    array<string> loadouts = Roguelike_GetTitanLoadouts()
    foreach (RoguelikeMod mod in file.mods)
    {
        bool isModAvailable = mod.loadouts.len() == 0
        foreach (string loadout in mod.loadouts)
        {
            if (loadouts.contains(loadout))
            {
                isModAvailable = true
                break;
            }
        }
        if (!mod.unlockedByDefault && isModAvailable && !mod.isTitan)
            result.append(mod.uniqueName)
    }
    printt("PILOT: total pool of", result.len(), "mods")
    return result
}
array function GetAllLockedTitanMods()
{
    array result
    array<string> loadouts = Roguelike_GetTitanLoadouts()
    foreach (RoguelikeMod mod in file.mods)
    {
        bool isModAvailable = mod.loadouts.len() == 0
        foreach (string loadout in mod.loadouts)
        {
            if (loadouts.contains(loadout))
            {
                isModAvailable = true
                break;
            }
        }
        if (!mod.unlockedByDefault && isModAvailable && mod.isTitan)
            result.append(mod.uniqueName)
    }
    printt("TITAN: total pool of", result.len(), "mods")
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

int function Roguelike_GetWeaponElement( string weapon )
{
    if (ROGUELIKE_FIRE_WEAPONS.contains(weapon))
        return RoguelikeElement.fire
    if (ROGUELIKE_ELECTRIC_WEAPONS.contains(weapon))
        return RoguelikeElement.electric
    return RoguelikeElement.physical
}
