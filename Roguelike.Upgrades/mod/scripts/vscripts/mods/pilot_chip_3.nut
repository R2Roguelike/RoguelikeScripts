global function PilotChip3_RegisterMods

void function PilotChip3_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("pistol_plus")
        mod.name = "SMG+"
        mod.abbreviation = "SM+"
        mod.description = "+30% Base Pistol DMG.\nPistol Range increased."
        mod.shortdesc = "+30% Base Pistol DMG.\nPistol Range increased."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("shotgun_plus")
        mod.name = "Shotgun+"
        mod.abbreviation = "SG+"
        mod.description = "+20% Base Shotgun DMG.\nShotgun Range increased."
        mod.shortdesc = "+20% Base Shotgun DMG.\nShotgun Range increased."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("smg_plus")
        mod.name = "SMG+"
        mod.abbreviation = "SM+"
        mod.description = "+20% Base SMG DMG.\nSMG Range increased."
        mod.shortdesc = "+20% Base SMG DMG.\nSMG Range increased."
        mod.cost = 2
    }

    {
        RoguelikeMod mod = NewMod("ar_plus")
        mod.name = "Assault Rifle+"
        mod.abbreviation = "AR+"
        mod.description = "+20% Base Assault Rifle DMG.\nAR Spread & Recoil decreased."
        mod.shortdesc = "+20% Base Assault Rifle DMG.\nAR Spread & Recoil decreased."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("lmg_plus")
        mod.name = "Machine Gun+"
        mod.abbreviation = "MG+"
        mod.description = "+20% Base Machine Gun DMG.\nLMG Mag Size increased."
        mod.shortdesc = "+20% Base Machine Gun DMG.\nLMG Mag Size increased."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("snipers_dream")
        mod.name = "All-Sniper Style"
        mod.abbreviation = "ASS"
        mod.description = "For Snipers <red>ONLY</>:\n\n" +
        " -80% Hipfire Spread\n" +
        " Zoom reduced by 25%\n" +
        " +33% Fire Rate\n" +
        " -25% Reload Time\n" +
        " Instant Zoom In/Out\n" +
        " +50% Titan Damage"
        mod.shortdesc = "Snipers are <red>much</> stronger."
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("ranger")
        mod.name = "Ranger"
        mod.abbreviation = "Rg"
        mod.description = "Hipfire spread decreased and range increased for all weapons. Overall recoil reduced."
        mod.shortdesc = "Spread and recoil reduced. Range increased."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("loader")
        mod.name = "Loader"
        mod.abbreviation = "Ld"
        mod.description = "Reload time slightly decreased for all weapons."
        mod.shortdesc = "Reload time slightly decreased."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("mag_size_pilot")
        mod.name = "Extended Mag"
        mod.abbreviation = "EM"
        mod.description = "+5 Mag Size for weapons that <cyan>match your grenade type.</>"
        mod.shortdesc = "+5 Mag Size for weapons that <cyan>match your grenade."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("mag_size_inf")
        mod.name = "Blood Mag"
        mod.abbreviation = "BM"
        mod.description = "+1 Mag Size per kill.\nResets between levels."
        mod.shortdesc = "+1 Mag Size per kill.\nResets between levels."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("physical_gain")
        mod.name = "Impending Impact"
        mod.abbreviation = "EG"
        mod.description = "<daze>Physical</> kills make your next hit a guranteed <cyan>headshot.</>"
        mod.shortdesc = "<daze>Physical</> kills make your next hit a guranteed <cyan>headshot.</>"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("energy_gain")
        mod.name = "Energy Recycler"
        mod.abbreviation = "ER"
        mod.description = "<cyan>Energy</> kills restore ammo."
        mod.shortdesc = "<cyan>Energy</> kills restore ammo."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("fire_gain")
        mod.name = "Mending Death"
        mod.abbreviation = "MD"
        mod.description = "<burn>Fire</> kills heal you for a small amount."
        mod.shortdesc = "<burn>Fire</> kills heal you."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("headshot_booster")
        mod.name = "Headshot Booster"
        mod.abbreviation = "HB"
        mod.description = "Hitting a headshot <cyan>heals you</> and grants that headshot <cyan>a +50% damage bonus.</>"
        mod.shortdesc = "Headshots <cyan>heal</> and have <cyan>increased +DMG%.</>"
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("fire_spread")
        mod.name = "Inner Molotov"
        mod.abbreviation = "IM"
        mod.description = "<burn>Fire</> kills apply damage over time to nearby enemies."
        mod.shortdesc = "<burn>Fire</> kills apply damage over time to\nnearby enemies."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("energy_spread")
        mod.name = "Bounty Collector"
        mod.abbreviation = "BC"
        mod.description = "<cyan>Energy</> kills spread damage to nearby enemies."
        mod.shortdesc = "<cyan>Energy</> kills deal damage to nearby enemies."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("physical_spread")
        mod.name = "Bounty Collector"
        mod.abbreviation = "BC"
        mod.description = "<daze>Physical</> kills grant additional cash."
        mod.shortdesc = "<daze>Physical</> kills grant additional cash."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("random_headshot")
        mod.name = "Random Crits"
        mod.abbreviation = "RC"
        mod.description = "All hits have a <cyan>50% chance</> to become a <burn>headshot.</>"
        mod.shortdesc = "Hits sometimes become headshots."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("force_dmg")
        mod.name = "Act of Physics"
        mod.abbreviation = "AoP"
        mod.description = "<green>Movement tools</> gain increased damage against enemies."
        mod.shortdesc = "Increased <green>Movement Tool</> damage against enemies."
        mod.cost = 2
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 3
    mod.isTitan = false

    return mod
}
