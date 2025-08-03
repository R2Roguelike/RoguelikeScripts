global function Tone_RegisterMods

global const float UPGRADE_LOCKON_CD_REDUCTION = 0.5

void function Tone_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("routine_exposure")
        mod.name = "Routine Exposure"
        mod.abbreviation = "RE"
        mod.description = "<cyan>-0.1s Lock-on cooldown</>.\n\nSonar Pulse emits 3 additional pulses."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("routine_exposure")
        mod.name = "Routine Exposure"
        mod.abbreviation = "RE"
        mod.description = "<cyan>-0.1s Lock-on cooldown</>.\n\nSonar Pulse emits 3 additional pulses."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("you_fucking_bitch")
        mod.name = "Animal Cruelty"
        mod.abbreviation = "AC"
        mod.description = "<cyan>+1 rocket per Rocket Barrage</>.\n\nFriendly fire is enabled against hacked enemies.\n\n<note>You cruel, cruel bastard.</>"
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("clone_lockons_generic")
        mod.name = "Hack Lock-on Gen."
        mod.abbreviation = "CLG"
        mod.description = "<cyan>-0.1s Lock-on cooldown</>.\n\nWhen a hacked Titan hits an enemy, apply a mark. This has a 1s cooldown."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("hit_locks")
        mod.name = "Lock-on Generation"
        mod.abbreviation = "LoG"
        mod.description = "<cyan>-0.1s Lock-on cooldown</>.\n\nWhen you hit an enemy with any damage source <note>(that is not the 40mm)</>, apply a mark. This has a 0.5s cooldown."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("barrage_cd")
        mod.name = "Sonar Barrage"
        mod.abbreviation = "SnB"
        mod.description = "<cyan>+1 rocket per Rocket Barrage</>.\n\nFiring a rocket barrage <cyan>reduces Sonar Pulse cooldown by 2s</>."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("salvo_lock")
        mod.name = "Salvo Lock"
        mod.abbreviation = "SL"
        mod.description = "<cyan>-0.1s Lock-on cooldown</>.\n\nSalvo Core rockets apply lockons."
        mod.cost = 2
        mod.chip = TITAN_CHIP_CORE
    }
    {
        RoguelikeMod mod = NewMod("rockets_crits")
        mod.name = "Rockets to Crits"
        mod.abbreviation = "HP"
        mod.description = "<cyan>-0.1s Lock-on cooldown</>.\n\nCritical hits from Rocket Barrages increase Crit Rate by 2%, lasting 5 seconds and stacking up to 10 times."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("hack_dmg")
        mod.name = "Overclock"
        mod.abbreviation = "Oc"
        mod.description = "<cyan>-0.1s Lock-on cooldown</>.\n\nHacked enemies are overclocked, increasing their damage by 50%."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("crit_marks")
        mod.name = "Crit Marks"
        mod.abbreviation = "CM"
        mod.description = "<cyan>+1 rocket per Rocket Barrage</>.\n\nCritical hits from Tone's Primary apply an additional Mark."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("40mm_fire_rate")
        mod.name = "40MM RPM"
        mod.abbreviation = "RPM"
        mod.description = "<cyan>-0.1s Lock-on cooldown</>.\n\n40MM Fire Rate +25%."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("dual_fire")
        mod.name = "Dual Barrage"
        mod.abbreviation = "DB"
        mod.description = "<cyan>+1 rocket per Rocket Barrage</>.\n\nWhen firing a rocket barrage: Your hacked Titan also fires a Rocket Barrage at the same target.\n\n<note>The Hacked Titan's rocket barrage base damage is equivalent to 33% of your own.</>"
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("40mm_restore")
        mod.name = "Bullet Wormhole"
        mod.abbreviation = "BW"
        mod.description = "<cyan>+1 rocket per Rocket Barrage</>.\n\nWhen a rocket from your rocket barrage hits an enemy, 50% chance to restore a bullet for your primary, and a separate 20% chance to grant 25% increased damage for 5s."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
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