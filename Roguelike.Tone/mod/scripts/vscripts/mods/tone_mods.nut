global function Tone_RegisterMods

global const float UPGRADE_LOCKON_CD_REDUCTION = 0.5
global const string TONE_BENEFIT_1 = "tone_rocket"
global const string TONE_BENEFIT_2 = "tone_cooldown"

void function Tone_RegisterMods()
{
    Roguelike_RegisterTag(TONE_BENEFIT_1, "+1 rocket per rocket barrage.")
    Roguelike_RegisterTag(TONE_BENEFIT_2, "-0.2s Lock-on cooldown.")
    {
        RoguelikeMod mod = NewMod("hacked_battery")
        mod.name = "Distributed Armor"
        mod.abbreviation = "DA"
        mod.description = "When taking damage, your <hack>Hacked Titan(s)</> will take some of the damage for you."
        mod.shortdesc = "Your <hack>Hacked Titan</> partially protects\nyou from damage."
        mod.tags = [TONE_BENEFIT_1]
        mod.cost = 2
        mod.chip = TITAN_CHIP_CHASSIS
    }
    {
        RoguelikeMod mod = NewMod("routine_exposure")
        mod.name = "Routine Exposure"
        mod.abbreviation = "RE"
        mod.description = "Sonar Pulse emits 3 additional pulses. Additionally, Hacked Titans emit Sonar Pulses."
        mod.shortdesc = "Sonar Pulse emits 3 additional pulses.\nHacked Titans emit Sonar Pulses."
        mod.tags = [TONE_BENEFIT_2]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("wall_locks")
        mod.name = "Wallock"
        mod.abbreviation = "Wal"
        mod.description = "+400% Particle Wall Max HP. <red>Instantly</> fire a rocket barrage against enemies that hit your particle wall. This has a 2s cooldown." + 
                          "\n\n<note>\"Wallock. Wallock. Wallock, Wallock, Wallock, Wallock.\"</>"
        mod.shortdesc = "<red>Instantly</> fire a rocket barrage against\nenemies that hit your particle wall."
        mod.tags = [TONE_BENEFIT_1]
        mod.cost = 3
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("you_fucking_bitch")
        mod.name = "Animal Cruelty"
        mod.abbreviation = "AC"
        mod.description = "Friendly fire is enabled against hacked enemies.\n\n<note>You cruel, cruel bastard.</>"
        mod.shortdesc = "Friendly fire is enabled against hacked enemies."
        mod.tags = [TONE_BENEFIT_1]
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("clone_lockons_offensive")
        mod.name = "Power Lock"
        mod.abbreviation = "PL"
        mod.description = "Offensive abilities apply a mark on hit. <note>Power Shot counts as Weapon DMG, and does not proc this.</>"
        mod.shortdesc = "<daze>Offensive abilities</> apply marks."
        mod.tags = [TONE_BENEFIT_2]
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("clone_lockons_primary")
        mod.name = "Sticky Weapons"
        mod.abbreviation = "SW"
        mod.description = "Weapon DMG applies a mark."
        mod.shortdesc = "<daze>Weapon DMG</> applies a mark."
        mod.tags = [TONE_BENEFIT_2]
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("hit_locks")
        mod.name = "Lock-on Generation"
        mod.abbreviation = "LoG"
        mod.description = "Enemies within 20m automatically accumulate 1 Mark every 1s."
        mod.shortdesc = "<daze>Nearby enemies</> <cyan>accumulate Marks</>\nover time."
        mod.tags = [TONE_BENEFIT_2]
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("barrage_cd")
        mod.name = "Sonar Barrage"
        mod.abbreviation = "SnB"
        mod.description = "Firing a rocket barrage <cyan>reduces Sonar Pulse cooldown by 1s.</>"
        mod.shortdesc = "Rocket barrages <cyan>reduce Sonar Pulse cooldown."
        mod.tags = [TONE_BENEFIT_1]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("salvo_locks")
        mod.name = "Salvo Lock"
        mod.abbreviation = "SL"
        mod.description = "Salvo Core rockets apply lockons."
        mod.shortdesc = "Salvo Core rockets apply lockons."
        mod.tags = [TONE_BENEFIT_2]
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("hack_dmg")
        mod.name = "Overclock"
        mod.abbreviation = "Oc"
        mod.description = "Hacked enemies are overclocked, increasing their damage by 50%."
        mod.shortdesc = "Hacked enemies gain <cyan>+DMG%."
        mod.tags = [TONE_BENEFIT_2]
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("crit_marks")
        mod.name = "Crit Marks"
        mod.abbreviation = "CM"
        mod.description = "Critical hits from Tone's Primary apply an additional Mark."
        mod.shortdesc = "Crits from Tone's 40mm apply an additional Mark."
        mod.tags = [TONE_BENEFIT_1]
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("red_sonar")
        mod.name = "Exposed"
        mod.abbreviation = "Ep"
        mod.description = "Enemies take +DMG% while revealed by Sonar Pulse."
        mod.shortdesc = "Enemies take +DMG% while revealed by Sonar Pulse.\nScales with <burn>Ability Power."
        mod.abilityPowerValue = 25.0
        mod.abilityPowerScalar = 1.0
        mod.abilityPowerLabel = "Damage Bonus"
        mod.abilityPowerFormat = "+%.0f%%"
        mod.tags = [TONE_BENEFIT_1]
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("40mm_fire_rate")
        mod.name = "40MM RPM"
        mod.abbreviation = "RPM"
        mod.description = "40MM Fire Rate increased.\n\nScales with <burn>Ability Power."
        mod.shortdesc = "40MM Fire Rate increased.\nScales with <burn>Ability Power."
        mod.abilityPowerValue = 25.0
        mod.abilityPowerScalar = 0.5
        mod.abilityPowerLabel = "Fire Rate Bonus"
        mod.tags = [TONE_BENEFIT_2]
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("dual_fire")
        mod.name = "Dual Barrage"
        mod.abbreviation = "DB"
        mod.description = "When firing a rocket barrage: Your hacked Titan(s) also fires a Rocket Barrage at the same target.\n\n<note>The Hacked Titan's rocket barrage base damage is equivalent to 30% of your own.</>"
        mod.shortdesc = "Hacked Titans also fire rocket barrages."
        mod.tags = [TONE_BENEFIT_1]
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("sonar_proc")
        mod.name = "Sonar Bullets"
        mod.abbreviation = "SB"
        mod.description = "Hits have a 10% chance to <cyan>emit a Sonar Pulse."
        mod.shortdesc = "Hits may <cyan>emit Sonar Pulses."
        mod.tags = [TONE_BENEFIT_2]
        mod.cost = 3
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 3
    mod.useLoadoutChipSlot = true
    mod.loadouts = [PRIMARY_TONE]
    mod.isTitan = true

    return mod
}