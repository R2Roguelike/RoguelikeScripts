global function PilotChip3_RegisterMods

void function PilotChip3_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("cq_plus")
        mod.name = "Close Quarters+"
        mod.abbreviation = "CQ+"
        mod.description = "Provides a different effect for each weapon type:\n\n" +
        " SMGs: Reload time decreased.\n" +
        " Pistols: Damage increased.\n" +
        " Shotguns: Range increased."
        mod.cost = 2
    }

    {
        RoguelikeMod mod = NewMod("long_plus")
        mod.name = "Long Range+"
        mod.abbreviation = "LR+"
        mod.description = "Provides a different effect for each weapon type:\n\n" +
        " LMGs: Magazine Size increased.\n" +
        " Assault Rifles: Recoil decreased.\n" +
        " Snipers: Fire rate increased."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("snipers_dream")
        mod.name = "All-Sniper Style"
        mod.abbreviation = "ASS"
        mod.description = "For Snipers <red>ONLY</>:\n\n" +
        " -80% Hipfire Spread\n" +
        " Zoom reduced by 25%\n" +
        " +25% Fire Rate\n" +
        " -25% Reload Time\n" +
        " Instant Zoom In/Out\n" +
        " +200% Titan Damage"
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("ranger")
        mod.name = "Ranger"
        mod.abbreviation = "Rg"
        mod.description = "Hipfire spread decreased and range increased for all weapons."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("loader")
        mod.name = "Loader"
        mod.abbreviation = "Ld"
        mod.description = "Reload time slightly decreased for all weapons."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("mag_size_pilot")
        mod.name = "Bigger Mag"
        mod.abbreviation = "BM"
        mod.description = "+5 Mag Size for all weapons."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("compensator")
        mod.name = "Compensator"
        mod.abbreviation = "Cs"
        mod.description = "Overall recoil reduced."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("headshot_booster")
        mod.name = "Headshot Booster"
        mod.abbreviation = "HB"
        mod.description = "Hitting a headshot <cyan>heals you</> and grants that headshot <cyan>a +50% damage bonus</>."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("random_headshot")
        mod.name = "Random Crits"
        mod.abbreviation = "RC"
        mod.description = "All hits have a <cyan>20% chance</> to become a <burn>headshot</>."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("force_dmg")
        mod.name = "Act of Physics"
        mod.abbreviation = "AoP"
        mod.description = "Bonus Explosion Force increases damage <note>except self-damage</>."
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
