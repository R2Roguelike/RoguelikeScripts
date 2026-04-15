untyped

globalize_all_functions

struct {
    array<RoguelikeMod> mods
    array<RoguelikeRunModifier> modifiers
    array<RoguelikeWeaponPerk> perks
    array<RoguelikeDatacorePerk> datacorePerks
    array<RoguelikeStat> stats
    table<string, string> tagDescriptions
} file

global array<RoguelikeLoadout> VALID_LOADOUTS = []

void function Roguelike_AddLoadout(RoguelikeLoadout loadout)
{
    loadout.index = VALID_LOADOUTS.len()
    VALID_LOADOUTS.append(loadout)
}

RoguelikeLoadout ornull function Roguelike_GetLoadoutFromWeapon(string loadout)
{
    foreach (RoguelikeLoadout l in VALID_LOADOUTS)
    {
        if (l.primary == loadout)
            return l
    }

    return null
}

void function Loadouts_Init()
{
    {
        RoguelikeLoadout loadout
        loadout.name = "Expedition"
        loadout.primary = "mp_titanweapon_xo16_shorty"
        loadout.offensive = "mp_titanweapon_shoulder_rockets"
        loadout.utility = "mp_titanability_rearm"
        loadout.defensive = "mp_titanweapon_vortex_shield"
        loadout.core = "mp_titancore_amp_core"
        loadout.unlockBit = -1 // expedition
        loadout.statusEffectName = "Weaken"
        loadout.element = RoguelikeElement.physical
        loadout.color = [177, 94, 255, 255]
        loadout.description = "<note>Ol' Reliable... with a twist.</>\n \nExpedition's E-Smoke is replaced with <daze>Rearm.</>" +
                              "\n<daze>Rearm</> <cyan>resets all cooldowns<note> (except itself) <cyan>for both loadouts.</>\n \n" +
                              "Expedition's status effect is <weak>Weaken.</>\n" +
                              "<weak>Weak</> is applied with <daze>Expedition's missiles.</>\n" +
                              "<weak>Weak</> reduces outgoing damage by 50%, and grants <cyan>+35% DMG</> against that target."
		loadout.role = "<cyan>Support</>"
		loadout.role2 = "<weak>CD Reduction"
        Roguelike_AddLoadout(loadout)
    }
    {
        RoguelikeLoadout loadout
        loadout.name = "Tone"
        loadout.primary = "mp_titanweapon_sticky_40mm"
        loadout.offensive = "mp_titanweapon_tracker_rockets"
        loadout.utility = "mp_titanability_sonar_pulse"
        loadout.defensive = "mp_titanability_particle_wall"
        loadout.core = "mp_titancore_salvo_core"
        loadout.element = RoguelikeElement.fire
        loadout.unlockBit = 0 // tone
        loadout.statusEffectName = "Hack"
        loadout.color = [32, 200, 32, 255]
        loadout.description = "<note>Watch your Tone, Pilot.</>\n\nWhen applying 3 Marks, Tone <cyan>immediately and automatically</> fires a rocket barrage at the target.\n\n" +
                              "Tone's Status effect and Offensive is <hack>Hack.</>\n<hack>Hack</> converts enemy Titans into allies for 15s."
		loadout.role = "<red>Damage</>"
		loadout.role2 = "<hack>Procs"
        Roguelike_AddLoadout(loadout)
    }
    {
        RoguelikeLoadout loadout
        loadout.name = "Scorch"
        loadout.primary = "mp_titanweapon_meteor"
        loadout.offensive = "mp_titanweapon_flame_wall"
        loadout.utility = "mp_titanability_slow_trap"
        loadout.defensive = "mp_titanweapon_heat_shield"
        loadout.core = "mp_titancore_flame_wave"
        loadout.element = RoguelikeElement.fire
        loadout.additionalSources = ["mp_titanweapon_meteor_thermite", "mp_titanweapon_meteor_thermite_charged"]
        loadout.unlockBit = 5 // scorch
        loadout.statusEffectName = "Burn"
        loadout.color = [255, 175, 75, 255]
        loadout.description = "<note>Set the world ablaze.</>\n\nScorch's status effect is <burn>Burn.</>" +
                              "\n<burn>Burn</> is inflicted by using <daze>anything in Scorch's kit,</>\n" +
                              "and increases <cyan>all types of damage.</>"
		loadout.role = "<cyan>Support</>"
		loadout.role2 = "<red>Damage"
        Roguelike_AddLoadout(loadout)
    }
    #if BRUTE_ENABLED
    // hello why are you leaking a MOD
    // anyways yeah go dechipher shit yourself or smth
    {
        RoguelikeLoadout loadout
        loadout.name = "Brute"
        loadout.primary = "mp_titanweapon_rocketeer_rocketstream"
        loadout.offensive = "mp_titanweapon_arm_laser"
        loadout.utility = "mp_titanability_rearm_brute"
        loadout.defensive = "mp_titanability_craft_battery"
        loadout.core = "mp_titancore_power_core"
        loadout.element = RoguelikeElement.fire
        loadout.unlockBit = 4
        loadout.statusEffectName = "Arm"
        loadout.color = [255, 64, 192, 255]
        loadout.description = "<note>So much for a 'vanilla' loadout, right?</>\n\n" 
                            + "Brute has no defensive, but can <green>craft batteries</> by <daze>consuming Core charge</> instead.\n\nBrute's Status Effect is <arm>Arm.</>\n\n"
                            + "It's applied using his offensive and makes his Quad Rocket's <daze>primary fire</> home onto marked enemies."
		loadout.role = "<red>Damage</>"
		loadout.role2 = "<green>Healing"
        Roguelike_AddLoadout(loadout)
    }
    #endif
    {
        RoguelikeLoadout loadout
        loadout.name = "Ion"
        loadout.primary = "mp_titanweapon_particle_accelerator"
        loadout.offensive = "mp_titanweapon_laser_lite"
        loadout.utility = "mp_titanability_laser_trip"
        loadout.defensive = "mp_titanweapon_vortex_shield_ion"
        loadout.core = "mp_titancore_laser_cannon"
        loadout.element = RoguelikeElement.electric
        loadout.unlockBit = 1 // ion
        loadout.statusEffectName = "Charge"
        loadout.color = [64, 255, 240, 255]
        loadout.description = "<note>We're all connected. Except me and the enemy team.</>\n\n" +
                              "Ion's status effect is <charge>Charge.</>\n" +
                              "Charge is inflicted by Ion's <daze>Pylon Turrets</> or <daze>primary.</>\n\n" +
                              "When <charge>Charge</> is at max, damage with <cyan>any other source</> " +
                              "will trigger a <charge>Discharge,</> increasing that hit's damage by at least <daze>+100%</> <note>(this is <cyan>multiplicative<note>).</>\n\n" +
                              "If <daze>another status effect</> is also inflicted, <red>Disorder</> will be triggered instead, removing the effect and <cyan>increasing damage further.</>"
		loadout.role2 = "<daze>Burst"
		loadout.role = "<cyan>Support</>"
        Roguelike_AddLoadout(loadout)
    }
    {
        RoguelikeLoadout loadout
        loadout.name = "Ronin"
        loadout.primary = "mp_titanweapon_leadwall"
        loadout.offensive = "mp_titanweapon_arc_wave"
        loadout.utility = "mp_titanability_phase_dash"
        loadout.defensive = "mp_titanability_basic_block"
        loadout.core = "mp_titancore_shift_core"
        loadout.melee = "melee_titan_sword"
        loadout.element = RoguelikeElement.electric
        loadout.unlockBit = 2 // ronin
        loadout.statusEffectName = "Daze"
        loadout.color = [255, 225, 100, 255]
        loadout.description = "<note>No need for a shield if you've got a giant sword...</>\n \nRonin's status effect is <daze>Daze.</>" +
                              "\n\n<daze>Daze</> is inflicted with <cyan>Arc Wave.</>\n" +
                              "Gain <overload>Overload</> stacks from <cyan>Sword hits against Dazed enemies</> or through <cyan>Arc Wave against Dazed enemies.</>\n" +
                              "\n<overload>Overload</> stacks are consumed when you <daze>fire any primary</> for a <red>high base damage increase.</>"
		loadout.role2 = "<daze>Burst"
		loadout.role = "<red>Damage</>"
        Roguelike_AddLoadout(loadout)
    }
    {
        RoguelikeLoadout loadout
        loadout.name = "Northstar"
        loadout.primary = "mp_titanweapon_sniper"
        loadout.offensive = "mp_titanweapon_dumbfire_rockets"
        loadout.utility = "mp_titanability_hover"
        loadout.defensive = "mp_titanability_tether_trap"
        loadout.core = "mp_titancore_flight_core"
        loadout.element = RoguelikeElement.physical
        loadout.unlockBit = 3 // northstar
        loadout.statusEffectName = "Fulminate"
        loadout.color = [64, 96, 255, 255]
        loadout.additionalSources = ["mp_titanweapon_flightcore_rockets"]
        loadout.description = "<note>Welcome to Big Number Inc.! Would you like some big numbers on your screen?</>\n\n" +
                              "Northstar's Railgun does <red>not</> crit randomly, but instead <cyan>crits when hitting the enemy's weak spot.</> Because of this, <daze>all Crit Rate is converted into Crit DMG when using the railgun.</>\n\n" +
                              "Northstar's status effect is <fulm>Fulminate.</>\n\n" +
                              "<fulm>Fulminate</> is dealt with <daze>any source</> of damage, and <cyan>increases the Crit DMG of your next Railgun Crit</> by up to 45%."
		loadout.role2 = "<daze>Burst"
		loadout.role = "<red>Damage</>"
        Roguelike_AddLoadout(loadout)
    }
    {
        RoguelikeLoadout loadout
        loadout.name = "Legion"
        loadout.primary = "mp_titanweapon_predator_cannon"
        loadout.offensive = "mp_titanability_power_shot"
        loadout.utility = "mp_titanability_ammo_swap"
        loadout.defensive = "mp_titanability_gun_shield"
        loadout.core = "mp_titancore_siege_mode"
        loadout.element = RoguelikeElement.physical
        loadout.unlockBit = -1 // legion
        loadout.statusEffectName = "Puncture"
        loadout.color = [255, 64, 64, 255]
        loadout.description = "<note>The answer... is a gun. And if that don't work? Use more gun.</>\n \n" +
                              "<daze>ALL</> of Legion's damage is considered <daze>Weapon DMG,</> and <red>NOT</> Ability DMG.\n\n" +
                              "Legion's status effect is <punc>Puncture.</>\n\n" +
                              "<punc>Puncture</> is inflicted with <daze>Power Shot.</>\n"+
                              "While a target is <punc>Punctured,</> <cyan>Crit Rate</> against it is increased by 25%."
		loadout.role2 = "<daze>Sustain"
		loadout.role = "<red>Damage</>"
        Roguelike_AddLoadout(loadout)
    }
}

array<void functionref()> registrationCallbacks
void function AddCallback_ModRegistration( void functionref() callback )
{
    registrationCallbacks.append(callback)
}

void function Mods_Init()
{
    // THIS HAS TO BE FIRST!!!!!!!
    // ALL MODS ARE HARDCODED TO DEFAULT TO INDEX 0
    Loadouts_Init()
    RoguelikeStats_Init()

    int i = 0
    foreach (RoguelikeStat stat in file.stats)
    {
        if (stat.isHeader)
            continue
        i++
    }
    printt(i, "stats registered")

    {
        RoguelikeMod mod
        mod.uniqueName = "empty"
        mod.name = "EMPTY"
        mod.description = "An empty mod slot. For enough energy, you may equip a mod here."
        mod.shortdesc = ""
        mod.icon = $"ui/cog"
        mod.colorTag = "empty"
        mod.cost = 0
        mod.isTitan = true
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

    // TONE
    Tone_RegisterMods()

    // BRUTE
    #if BRUTE_ENABLED
    Brute_RegisterMods()
    #endif

    foreach (void functionref() c in registrationCallbacks)
        c()

    printt("Registered", file.mods.len())
    int loadoutSpecific = 0
    table<string, int> modsPerLoadout
    table json
    foreach (RoguelikeMod mod in file.mods)
    {
        table t = {
            name = mod.name
            desc = mod.description
            shortdesc = mod.shortdesc,
            cost = mod.cost,
            loadouts = mod.loadouts,
            isTitan = mod.isTitan,
            abbreviation = mod.abbreviation
        }
        json[mod.uniqueName] <- t
        if (mod.loadouts.len() == 1)
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
        
        #if UI
        if (mod.abilityPowerScalar > 0.0)
        {
            HoverSimpleBox box
            box.currentValue = format(mod.abilityPowerFormat, mod.abilityPowerValue + mod.abilityPowerScalar * Roguelike_GetStat( "ability_power" ))
            box.initialValue = format(mod.abilityPowerFormat, mod.abilityPowerValue)
            box.label = mod.abilityPowerLabel + " <burn>(↑↑ Ability Power)"
            box.abilityPowerBox = true
            mod.boxes.append(box)
        }
        #endif

        HoverSimpleBox box
        box.icon = $"ui/lightning"
        box.currentValue = string(mod.cost)
        box.label = "Energy Cost"
        mod.boxes.append(box)

        #if UI
        if (StartsWith( mod.shortdesc, "PLACEHOLDER" ))
        {
            printt(mod.uniqueName, "has a placeholder shortdesc!")
        }
        foreach (string line in split( FormatDescription( mod.shortdesc ), "\n" ))
        {
            if (ActualStringLen( line ) > 49)
            {
                printt(mod.uniqueName, "is too long!", ActualStringLen( line ), line)
            }
        }
        #endif
    }
    NSSaveJSONFile("data.json", json)
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
void function Roguelike_RegisterTag( string tag, string desc )
{
    file.tagDescriptions[tag] <- desc
}
string function Roguelike_GetTagDesc( string tag )
{
    return file.tagDescriptions[tag]
}

RoguelikeStat function Roguelike_NewStat( string uniqueName )
{
    try
    {
        GetStatByName(uniqueName)
        throw "this mod exists already!"
    }
    catch (e)
    {
        // all good, supposed to crash
    }
    RoguelikeStat stat
    stat.uniqueName = uniqueName
    stat.index = file.stats.len()
    file.stats.append(stat)

    return stat
}

RoguelikeMod function Roguelike_NewMod( string uniqueName )
{
    try
    {
        GetModByName(uniqueName)
        throw "this mod exists already!"
    }
    catch (e)
    {
        // all good, supposed to crash
    }
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

RoguelikeDatacorePerk function Roguelike_NewDatacorePerk( string uniqueName )
{
    RoguelikeDatacorePerk perk
    perk.uniqueName = uniqueName
    perk.index = file.datacorePerks.len()
    file.datacorePerks.append(perk)

    return perk
}


#if UI
array<RoguelikeMod> function GetModsForChipSlot( int chipSlot, bool isTitan, bool includeLocked = false )
{
    array<RoguelikeMod> mods
    foreach (RoguelikeMod mod in file.mods)
    {
        bool unlocked = includeLocked || Roguelike_IsModUnlocked( mod ) || GetConVarBool("roguelike_unlock_all")
        if (Roguelike_IsModCompatibleWithSlot( mod, chipSlot, isTitan ) && !mod.isHidden && unlocked)
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
    if ((mod.chip == ALL_CHIP_SLOTS) && mod.loadouts.len() <= 0)
        return true

    return GetModChipSlotFlags(mod) == chipSlot && isTitan == mod.isTitan
}

bool function Roguelike_IsModUnlocked( RoguelikeMod mod )
{
    if (mod.unlockedByDefault)
        return true

    return expect bool( Roguelike_GetRunData().unlockedMods.contains(mod.uniqueName) )
}

int function Roguelike_GetAmountOfModsUnlockedForLoadout( string loadout )
{
    int count = 0
    foreach(var modName in Roguelike_GetRunData().unlockedMods)
    {
        RoguelikeMod mod = GetModByName(expect string(modName))
        if (mod.loadouts.contains(loadout))
            count++
    }
    return count
}
#endif

RoguelikeMod function GetModForIndex( var index )
{
    expect int( index )

    return file.mods[index]
}

int function GetModCount()
{
    return file.mods.len()
}

RoguelikeStat function GetStatForIndex( var index )
{
    expect int( index )

    return file.stats[index]
}

int function GetStatCount()
{
    return file.stats.len()
}

array<RoguelikeRunModifier> function Roguelike_GetRunModifierList()
{
    return file.modifiers
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

RoguelikeDatacorePerk function GetDatacorePerkDataByName( var name )
{
    foreach (RoguelikeDatacorePerk mod in file.datacorePerks)
    {
        if (mod.uniqueName == name)
            return mod
    }

    string error = "Could not find datacore perk of name \"" + name + "\""
    throw error
    unreachable
}

array<RoguelikeDatacorePerk> function Roguelike_GetDatacorePerks(int maxSlot = -1)
{
    if (maxSlot == -1)
        return file.datacorePerks

    array<RoguelikeDatacorePerk> result = []
    foreach (RoguelikeDatacorePerk mod in file.datacorePerks)
    {
        if (mod.slot <= maxSlot)
        {
            result.append(mod)
        }
    }

    return result
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

array<float> function NewStatArray(bool includeBaseValues)
{
    array<float> result = []
    for (int i = 0; i < file.stats.len(); i++)
    {
        result.append(includeBaseValues ? GetStatForIndex(i).baseValue : 0.0)
    }

    return result
}

RoguelikeStat function GetStatByName( var name )
{
    foreach (RoguelikeStat stat in file.stats)
    {
        if (stat.uniqueName == name)
            return stat
    }

    string error = "Could not find mod of name \"" + name + "\""
    throw error
    unreachable
}

array<RoguelikeStat> function Roguelike_GetStatsForSide( bool isTitan, bool includeHeaders = false )
{
    array<RoguelikeStat> result
    foreach (RoguelikeStat stat in file.stats)
    {
        if (stat.isHeader && !includeHeaders)
            continue
        if (stat.isTitan == isTitan)
            result.append(stat)
    }

    return result
}

#if UI
// empty arrays/tables are lost on load - these functions make sure the returned value is never null.
array function GetLockedPilotModsLeft( int chipSlot )
{
    string index = "lockedPilotMods" + chipSlot
    table runData = Roguelike_GetRunData()
    if (!(index in runData))
        runData[index] <- []
    return expect array(runData[index])
}

array function GetLockedTitanModsLeft( int chipSlot )
{
    string index = "lockedTitanMods" + chipSlot
    table runData = Roguelike_GetRunData()
    if (!(index in runData))
        runData[index] <- []
    return expect array(runData[index])
}

table function GetShopRerollTable()
{
    table runData = Roguelike_GetRunData()
    if (!("shopRerolls" in runData))
        runData.shopRerolls <- {}
    return expect table(runData.shopRerolls)
}

table function GetShopPurchasedTable()
{
    table runData = Roguelike_GetRunData()
    if (!("shopPurchased" in runData))
        runData.shopPurchased <- {}
    return expect table(runData.shopPurchased)
}
#endif

// is not typed array cuz this is for storing in runData
array function GetAllLockedMods(bool loadoutCheck = true)
{
    array result
    array<string> loadouts = Roguelike_GetTitanLoadouts()
    foreach (RoguelikeMod mod in file.mods)
    {
        bool isModAvailable = true
        foreach (string loadout in mod.loadouts)
        {
            if (!loadouts.contains(loadout))
            {
                isModAvailable = false
                break;
            }
        }
        if (!loadoutCheck || (!mod.unlockedByDefault && isModAvailable))
            result.append(mod.uniqueName)
    }
    printt("total pool of", result.len(), "mods")
    return result
}
bool function IsModAvailable(RoguelikeMod mod)
{
    array<string> loadouts = Roguelike_GetTitanLoadouts()

    bool isModAvailable = true

    foreach (string loadout in mod.loadouts)
    {
        if (!loadouts.contains(loadout))
        {
            isModAvailable = false
            break;
        }
    }

    return !mod.unlockedByDefault && isModAvailable
}
#if UI
array function GetAllPilotModsInLootPool( int chipSlot )
{
    array result
    array<string> loadouts = Roguelike_GetTitanLoadouts()
    foreach (RoguelikeMod mod in file.mods)
    {
        bool isModAvailable = IsModAvailable(mod)
        bool isCorrectSlot = chipSlot == -1 || Roguelike_IsModCompatibleWithSlot(mod, chipSlot, false)
        if (isModAvailable && isCorrectSlot && !mod.isHidden && !mod.doNotUnlock)
            result.append(mod.uniqueName)
    }
    
    return result
}
array function GetAllTitanModsInLootPool( int chipSlot )
{
    array result
    array<string> loadouts = Roguelike_GetTitanLoadouts()
    foreach (RoguelikeMod mod in file.mods)
    {
        bool isModAvailable = IsModAvailable(mod)
        bool isCorrectSlot = chipSlot == -1 || Roguelike_IsModCompatibleWithSlot(mod, chipSlot, true)
        if (isModAvailable && isCorrectSlot && !mod.isHidden && !mod.doNotUnlock)
            result.append(mod.uniqueName)
    }
    
    return result
}
array function GetAllModsForLootPool( bool isTitan, int chipSlot )
{
    array result
    array<string> loadouts = Roguelike_GetTitanLoadouts()
    foreach (RoguelikeMod mod in file.mods)
    {
        bool isModAvailable = IsModAvailable(mod)
        bool isCorrectSlot = mod.isTitan == isTitan && Roguelike_IsModCompatibleWithSlot(mod, chipSlot, isTitan)
        if (isModAvailable && isCorrectSlot
             && !mod.isHidden 
             && !mod.doNotUnlock 
             && !mod.unlockedByDefault)
            result.append(mod.uniqueName)
    }
    
    return result
}
#endif

int function GetModChipSlotFlags(RoguelikeMod mod)
{
    if (mod.loadouts.len() <= 0)
        return mod.chip

    array<string> loadout

    if (mod.isTitan)
        loadout = Roguelike_GetTitanLoadouts()
    else
        loadout = ["mp_ability_cloak"]

    for (int i = 0; i < loadout.len(); i++)
    {
        if (mod.loadouts.contains(loadout[i]))
        {
            if (mod.useLoadoutChipSlot && mod.chip >= 3) // chips 3/4 are 
            {
                return (3 + i)
            }

            return mod.chip
        }
    }

    return -1
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

bool function IsSlotLocked( int chipSlot, bool isTitan, int indexSlot )
{
    var data = Roguelike_GetRunData()[(isTitan ? "ACTitan" : "ACPilot") + chipSlot]


    int slots = 1
    if (data.rarity >= RARITY_RARE)
        slots++
    if (data.rarity >= RARITY_LEGENDARY)
        slots++
    if (data.level > 1)
        slots++
    return indexSlot >= slots
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

bool function Roguelike_LoadoutHasWeapon(RoguelikeLoadout loadout, string weapon)
{
    if (loadout.primary == weapon)
        return true
    if (loadout.offensive == weapon)
        return true
    if (loadout.utility == weapon)
        return true
    if (loadout.defensive == weapon)
        return true
    if (loadout.core == weapon)
        return true
    if (loadout.melee == weapon)
        return true
    if (loadout.additionalSources.contains(weapon))
        return true
        
    return false
}

int function Roguelike_GetWeaponElement( string weapon )
{
    if (weapon == "melee_titan_punch")
        return 0
    
    foreach (RoguelikeLoadout loadout in VALID_LOADOUTS)
    {
        if (Roguelike_LoadoutHasWeapon(loadout, weapon))
            return ((loadout.index + 1) << 11)
    }
    int offset = 0
    if (ROGUELIKE_FIRE_WEAPONS.contains(weapon))
        return RoguelikeElement.fire | offset
    if (ROGUELIKE_ELECTRIC_WEAPONS.contains(weapon))
        return RoguelikeElement.electric | offset
    return RoguelikeElement.physical | offset
}

#if UI
void function  Roguelike_UnlockLoadout( int bit )
{
    int convar = GetConVarInt("roguelike_loadouts_unlocked")
    bool playerHint = convar == 0
    convar = convar | (1 << bit)

    string loadoutName = "???"
    foreach (RoguelikeLoadout loadout in VALID_LOADOUTS)
    {
        if (loadout.unlockBit == bit)
            loadoutName = loadout.name
    }
    SetConVarInt("roguelike_loadouts_unlocked", convar)
    RunClientScript("Roguelike_UnlockLoadoutAnim", loadoutName, playerHint)

    Roguelike_WriteSaveToDisk()
}
#endif