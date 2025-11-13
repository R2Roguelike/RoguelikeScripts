global function PilotChip1_RegisterMods

void function PilotChip1_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("bloodthirst")
        mod.name = "Bloodthirst"
        mod.abbreviation = "Bt"
        mod.description = "Dealing <burn>Fire</> damage within 10 meters starts regeneration immediately."
        mod.shortdesc = "<burn>Fire</> DMG to close enemies starts regen."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("endurance_2")
        mod.name = "Endurance+2"
        mod.abbreviation = "E+2"
        mod.description = "+10 <cyan>Endurance.</>"
        mod.shortdesc = "+10 <cyan>Endurance."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("titan_aptitude")
        mod.name = "Titan Aptitude"
        mod.abbreviation = "TA"
        mod.description = "One-Shot protection and 60% damage reduction against titans."
        mod.shortdesc = "DMG reduction against titans."
        mod.cost = 2
    }
    {
        // NOT IMPLEMENTED
        RoguelikeMod mod = NewMod("pilot_long_range_resist")
        mod.name = "Anti-Bullshitinator"
        mod.abbreviation = "A-B"
        mod.description = "Take reduced damage from faraway targets."
        mod.shortdesc = "Reduced damage from faraway targets."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("pilot_brawler")
        mod.name = "Brawler"
        mod.abbreviation = "Bl"
        mod.description = "Take reduced damage from close targets."
        mod.shortdesc = "Reduced damage from close targets."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("speed_shield")
        mod.name = "SPEED-BASED SHIELD"
        mod.abbreviation = "SBS"
        mod.description = "When moving at 50km/h or above, you are invulnerable."
        mod.shortdesc = "Moving fast makes you <cyan>invulnerable."
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("quick_regen")
        mod.name = "Quick Regen"
        mod.abbreviation = "QR"
        mod.description = "Health regeneration rate increased by 100%."
        mod.shortdesc = "Health regenerates faster."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("always_regen")
        mod.name = "Immediate Regen"
        mod.abbreviation = "IR"
        mod.description = "Regeneration delay reduced by 50%. Regeneration rate reduced by 25%."
        mod.shortdesc = "Health regenerates <cyan>sooner,</> but <red>slower.</>"
        mod.cost = 2
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)
    mod.chip = 1
    mod.isTitan = false
    return mod
}