resource/ui/roguelike_timer.res
{
    Screen
    {
		ControlName		ImagePanel
		wide			768
		tall			128
		visible			1
		scaleImage		1
		fillColor		"0 0 0 0"
		drawColor		"0 0 0 0"
    }
    Time
    {
		ControlName			Label
		xpos				0
		ypos				0

		visible				1
		zpos				200
        wide                96
		tall				45
		labelText			"12:51"
		allCaps				1
		font				JetBrainsMonoBold_36
		auto_wide_to_contents	0
        auto_tall_tocontents    1
		textAlignment		center
		fgcolor_override 	"255 255 255 255"

		pin_to_sibling				Screen
		pin_corner_to_sibling		TOP
		pin_to_sibling_corner		TOP
    }


    KillsBG
    {
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"0 0 0 135"
		scaleImage			1

		wide				128
		tall				6

		"xpos"			"3"
		"ypos"			"-7"

        pin_to_sibling "Time"
		pin_corner_to_sibling	BOTTOM_RIGHT
		pin_to_sibling_corner	BOTTOM_LEFT
    }

    KillsBar
    {
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			1
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			1000

		fgcolor_override	"79 121 1278 255"
		scaleImage			1

		wide				124
		tall				2

		"xpos"			"-2"
		"ypos"			"-2"

    	pin_to_sibling "KillsBG"
		pin_corner_to_sibling	TOP_RIGHT
		pin_to_sibling_corner	TOP_RIGHT
    }

    KillsRank
    {
		ControlName			Label
		xpos				0
		ypos				8

		visible				1
		zpos				200
        wide                32
		tall				32
		labelText			"S"
		allCaps				1
		font				JetBrainsMonoBold_36
		auto_wide_to_contents	0
        auto_tall_tocontents    1
		textAlignment		north
		fgcolor_override 	"255 0 0 255"

		pin_to_sibling				KillsBG
		pin_corner_to_sibling		BOTTOM_RIGHT
		pin_to_sibling_corner		BOTTOM_LEFT
    }
    KillsLabel
    {
		ControlName			Label
		xpos				-1
		ypos				0

		visible				1
		zpos				200
        wide                128
		tall				24
		labelText			"Kills"
		allCaps				1
		font				JetBrainsMono_17
		auto_wide_to_contents	0
        auto_tall_tocontents    1
		textAlignment		east
		fgcolor_override 	"255 255 255 255"

		pin_to_sibling				KillsBG
		pin_corner_to_sibling		BOTTOM_RIGHT
		pin_to_sibling_corner		TOP_RIGHT
    }

    TimeBG
    {
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"0 0 0 135"
		scaleImage			1

		wide				128
		tall				6

		"xpos"			"2"
		"ypos"			"-7"

        pin_to_sibling "Time"
		pin_corner_to_sibling	BOTTOM_LEFT
		pin_to_sibling_corner	BOTTOM_RIGHT
    }

    TimeBar
    {
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			0
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			1000

		fgcolor_override	"79 121 255 255"
		scaleImage			1

		wide				124 
		tall				2

		"xpos"			"-2"
		"ypos"			"-2"

    	pin_to_sibling "TimeBG"
		pin_corner_to_sibling	TOP_RIGHT
		pin_to_sibling_corner	TOP_RIGHT
    }

    TimeRank
    {
		ControlName			Label
		xpos				0
		ypos				8

		visible				1
		zpos				200
        wide                32
		tall				32
		labelText			"S"
		allCaps				1
		font				JetBrainsMonoBold_36
		auto_wide_to_contents	0
        auto_tall_tocontents    1
		textAlignment		north
		fgcolor_override 	"255 0 0 255"

		pin_to_sibling				TimeBG
		pin_corner_to_sibling		BOTTOM_LEFT
		pin_to_sibling_corner		BOTTOM_RIGHT
    }
    TimeLabel
    {
		ControlName			Label
		xpos				-1
		ypos				0

		visible				1
		zpos				200
        wide                128
		tall				24
		labelText			"Time"
		allCaps				1
		font				JetBrainsMono_17
		auto_wide_to_contents	0
        auto_tall_tocontents    1
		textAlignment		west
		fgcolor_override 	"255 255 255 255"

		pin_to_sibling				TimeBG
		pin_corner_to_sibling		BOTTOM_LEFT
		pin_to_sibling_corner		TOP_LEFT
    }

}