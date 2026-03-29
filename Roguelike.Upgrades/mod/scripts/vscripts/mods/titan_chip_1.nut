global function TitanChip1_RegisterMods

void function TitanChip1_RegisterMods()
{
    {
        RoguelikeMod mod = NewMod("max_shield")
        mod.name = "Extra Shield"
        mod.abbreviation = "ExS"
        mod.description = "Max shields increased by 50%. This is <cyan>multiplicative</>."
        mod.shortdesc = "Max shields increased by 50%."
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("armor_2")
        mod.name = "Armor+2"
        mod.abbreviation = "A+2"
        mod.description = "-10% <cyan>DMG Taken.</>"
        mod.shortdesc = "-10% <cyan>DMG Taken."
        mod.statModifiers = [NewStatModifier("dmg_taken", 0.11111)]
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("lifesteal")
        mod.name = "Jumpstart"
        mod.abbreviation = "Js"
        mod.description = "<daze>On hit:</> Start shield regeneration immediately."
        mod.shortdesc = "<daze>On hit:</>\nStart shield regeneration immediately."
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("titan_long_range_resist")
        mod.name = "Anti-Bullshitinator"
        mod.abbreviation = "A-B"
        mod.description = "Reduce damage taken by 25% from faraway targets."
        mod.shortdesc = "Reduce damage taken from faraway targets."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("battery_core")
        mod.name = "Offensive Restoration"
        mod.abbreviation = "OR"
        mod.description = "Gain 15% Core when you pick up a battery."
        mod.shortdesc = "Gain 15% Core when you pick up a battery."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("battery_shield")
        mod.name = "Superior Restoration"
        mod.abbreviation = "SR"
        mod.description = "Gain 500 Shields when you pick up a battery."
        mod.shortdesc = "Gain 500 Shields when you pick up a battery."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("titan_brawler")
        mod.name = "Brawler"
        mod.abbreviation = "Bl"
        mod.description = "Reduce damage taken by 33% from close targets."
        mod.shortdesc = "Reduce damage taken from close targets."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("titan_slide")
        mod.name = "Sliding With Style"
        mod.abbreviation = "SWS"
        mod.description = "BT gains <cyan>+25% Dash Speed</> and can now <cyan>Slide.</>\nBT is <cyan>Invulnerable</> while sliding."
        mod.shortdesc = "Increased Dash speed and enabled <cyan>Sliding.</>\nYou are <cyan>Invulnerable</> while sliding."
        mod.cost = 1
    }
    // TODO: CONVERT TO PERMANENT UPGRADE?
    {
        RoguelikeMod mod = NewMod("battery_heals")
        mod.name = "Healing++"
        mod.abbreviation = "H++"
        mod.description = "Healing from batteries increased by 35%. This is <cyan>multiplicative</>."
        mod.shortdesc = "Healing from batteries increased."
        mod.cost = 2
    }
    {
        RoguelikeMod mod = NewMod("shield_core")
        mod.name = "Shield Defensive"
        mod.abbreviation = "SD"
        mod.description = "On Defensive use: Start shield regeneration immediately."
        mod.shortdesc = "On Defensive use:\nStart shield regeneration immediately."
        mod.cost = 1
    }
    {
        RoguelikeMod mod = NewMod("checkpoint")
        mod.name = "???'s Time Machine"
        mod.abbreviation = "?TM"
        mod.description = "The next death will <cyan>ALWAYS</> load a checkpoint.\n\n<red>Once consumed, this mod cannot be swapped, -15% Base DMG and no more checkpoints for this run. AT ALL.</>" + 
                        "\n\n<note>This mod may be used multiple times.</>"
        mod.shortdesc = "Death will always load a checkpoint...\n<red>Once consumed, this mod cannot be swapped.</>"
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("checkpoint_used")
        mod.name = "Consumed Time Machine"
        mod.abbreviation = "CTM"
        mod.description = "<red>YOU AVOIDED DEATH ALREADY. NOW BEAR THE COST.</>\nYour next death loses the run <red>REGARDLESS OF THE REASON.</>"
        mod.shortdesc = "<red>-15% Base DMG.</> Your next death loses\nthe run, <red>REGARDLESS OF THE REASON.</>"
        mod.isSwappable = false
        mod.isHidden = true
        mod.cost = 3
    }
    {
        RoguelikeMod mod = NewMod("checkpoint_used_2")
        mod.name = ">:("
        mod.abbreviation = ">:("
        mod.description = "YOU THINK THIS IS FUNNY? THAT YOU HIDE YOUR PROBLEMS BENEATH THE RUG? FUCK YOU.\n\n<red>ALL Heat modifiers at maximum now.</>"
        mod.shortdesc = "<red>ALL Heat modifiers are active and\nAT MAXIMUM."
        mod.isSwappable = false
        mod.isHidden = true
        mod.cost = 99
    }
}

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.chip = 1
    mod.isTitan = true

    return mod
}