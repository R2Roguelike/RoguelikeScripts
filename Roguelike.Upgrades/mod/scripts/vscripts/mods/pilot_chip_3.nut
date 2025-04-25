global function PilotChip3_RegisterMods

void function PilotChip3_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("weapons_plus")
        mod.name = "Weapons+"
        mod.abbreviation = "W+"
        mod.description = "Provides a different effect for each weapon type:\n\n" + 
        " SMGs: Reload time decreased.\n" +
        " LMGs: Magazine Size increased.\n" +
        " Pistols: Damage increased.\n" +
        " Shotguns: Range increased.\n" +
        " Assault Rifles: Recoil decreased.\n" +
        " Snipers: Fire rate increased.\n" +
        " Grenadiers: Blast Radius increased."
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
        RoguelikeMod mod = NewMod("compensator")
        mod.name = "Compensator"
        mod.abbreviation = "Cs"
        mod.description = "Recoil randomness significantly reduced. Overall recoil slightly reduced."
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
