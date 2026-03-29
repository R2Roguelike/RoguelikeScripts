resource/ui/menus/panels/inventory_slot.res
{
    BG
    {
		ControlName			ImagePanel

		image			"vgui/hud/white"

		drawColor	"0 0 0 150"
		scaleImage			1

		wide				 80
		tall				 80

		"xpos"			"0"
		"ypos"			"0"
    }

	EnergyBar1
	{
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			0
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			4
		SegmentGap			2
		visible				1

		fgcolor_override	"0 0 0 128"
		scaleImage			1

		wide				72
		tall				2

		"xpos"			"0"
		"ypos"			"-4"

		pin_to_sibling "BG"
		pin_corner_to_sibling	BOTTOM
		pin_to_sibling_corner	BOTTOM
	}
	EnergyBar2
	{
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			0
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			4
		SegmentGap			2
		visible				1

		fgcolor_override	"220 220 220 255"
		scaleImage			1

		wide				72
		tall				2

		"xpos"			"0"
		"ypos"			"-4"

		pin_to_sibling "BG"
		pin_corner_to_sibling	BOTTOM
		pin_to_sibling_corner	BOTTOM
	}

	Icon
	{
		ControlName			RuiPanel

		rui                     "ui/basic_image.rpak"

		drawColor	"255 255 255 255"
		scaleImage			1
		visible				1

		wide				64
		tall				64

		pin_to_sibling "BG"
		pin_corner_to_sibling	CENTER
		pin_to_sibling_corner	CENTER

		ypos			-1

		"xpos"			"0"
		"ypos"			"0"
	}
}