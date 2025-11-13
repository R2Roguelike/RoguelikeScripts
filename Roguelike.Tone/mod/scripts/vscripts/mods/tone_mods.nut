global function Tone_RegisterMods

global const float UPGRADE_LOCKON_CD_REDUCTION = 0.5

void function Tone_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("hacked_battery")
        mod.name = "Exposed Battery"
        mod.abbreviation = "EB"
        mod.description = "<cyan>+1 rocket per rocket barrage.</>\n\n<hack>Hacked Titan</> damage restores shields."
        mod.shortdesc = "<hack>Hacked Titan</> DMG restores shields."
        mod.cost = 2
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("routine_exposure")
        mod.name = "Routine Exposure"
        mod.abbreviation = "RE"
        mod.description = "<cyan>-0.2s Lock-on cooldown.</>\n\nSonar Pulse emits 3 additional pulses."
        mod.shortdesc = "Sonar Pulse emits 3 additional pulses."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("wall_locks")
        mod.name = "Wallock"
        mod.abbreviation = "Wal"
        mod.description = "<cyan>+1 rocket per rocket barrage.</>\n\n+400% Particle Wall Max HP. <red>Instantly</> fire a rocket barrage against enemies that hit your particle wall. This has a 2s cooldown." + 
                          "\n\n<note>\"Wallock. Wallock. Wallock, Wallock, Wallock, Wallock.\"</>"
        mod.shortdesc = "<red>Instantly</> fire a rocket barrage against enemies\nthat hit your particle wall."
        mod.cost = 3
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("you_fucking_bitch")
        mod.name = "Animal Cruelty"
        mod.abbreviation = "AC"
        mod.description = "<cyan>+1 rocket per Rocket Barrage.</>\n\nFriendly fire is enabled against hacked enemies.\n\n<note>You cruel, cruel bastard.</>"
        mod.shortdesc = "Friendly fire is enabled against hacked enemies."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("clone_lockons_generic")
        mod.name = "Hack Lock-on Gen."
        mod.abbreviation = "CLG"
        mod.description = "<cyan>-0.2s Lock-on cooldown.</>\n\nWhen a hacked Titan hits an enemy, apply a mark. This has a 1s cooldown."
        mod.shortdesc = "When a hacked Titan hits an enemy, apply a mark."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("hit_locks")
        mod.name = "Lock-on Generation"
        mod.abbreviation = "LoG"
        mod.description = "<cyan>-0.2s Lock-on cooldown.</>\n\nWhen you hit an enemy with any damage source <note>(that is not the 40mm),</> apply a mark. This has a 0.5s cooldown."
        mod.shortdesc = "<daze>On hit:</> Apply a mark."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("barrage_cd")
        mod.name = "Sonar Barrage"
        mod.abbreviation = "SnB"
        mod.description = "<cyan>+1 rocket per Rocket Barrage.</>\n\nFiring a rocket barrage <cyan>reduces Sonar Pulse cooldown by 1s.</>"
        mod.shortdesc = "Rocket barrages <cyan>reduce Sonar Pulse cooldown."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("salvo_locks")
        mod.name = "Salvo Lock"
        mod.abbreviation = "SL"
        mod.description = "<cyan>-0.2s Lock-on cooldown.</>\n\nSalvo Core rockets apply lockons."
        mod.shortdesc = "Salvo Core rockets apply lockons."
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("hack_dmg")
        mod.name = "Overclock"
        mod.abbreviation = "Oc"
        mod.description = "<cyan>-0.2s Lock-on cooldown.</>\n\nHacked enemies are overclocked, increasing their damage by 50%."
        mod.shortdesc = "Hacked enemies gain <cyan>+DMG%."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("crit_marks")
        mod.name = "Crit Marks"
        mod.abbreviation = "CM"
        mod.description = "<cyan>+1 rocket per Rocket Barrage.</>\n\nCritical hits from Tone's Primary apply an additional Mark."
        mod.shortdesc = "Crits from Tone's 40mm apply an additional Mark."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("red_sonar")
        mod.name = "Exposed"
        mod.abbreviation = "Ep"
        mod.description = "<cyan>+1 rocket per Rocket Barrage.</>\n\nEnemies take +25% DMG while revealed by Sonar Pulse."
        mod.shortdesc = "Enemies take +DMG% while revealed by Sonar Pulse."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("40mm_fire_rate")
        mod.name = "40MM RPM"
        mod.abbreviation = "RPM"
        mod.description = "<cyan>-0.2s Lock-on cooldown.</>\n\n40MM Fire Rate +25%."
        mod.shortdesc = "40MM Fire Rate increased."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("dual_fire")
        mod.name = "Dual Barrage"
        mod.abbreviation = "DB"
        mod.description = "<cyan>+1 rocket per Rocket Barrage.</>\n\nWhen firing a rocket barrage: Your hacked Titan also fires a Rocket Barrage at the same target.\n\n<note>The Hacked Titan's rocket barrage base damage is equivalent to 20% of your own.</>"
        mod.shortdesc = "Hacked Titans also fire rocket barrages."
        mod.cost = 3
        mod.chip = TITAN_CHIP_UTILITY
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = false
    mod.loadouts = [PRIMARY_TONE]
    mod.isTitan = true

    return mod
}