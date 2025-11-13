resource/ui/menus/panels/inventory_slot.res
{
	EnergyBarBG
	{
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			3
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			16
		SegmentGap			4
		visible				1

		fgcolor_override	"255 255 255 255"
		scaleImage			1

		wide				4
		tall				80

		"xpos"			"20"
		"ypos"			"0"
	}
    Icon
    {
        ControlName			ImagePanel

        image			"ui/lightning"

        drawColor	"255 255 255 255"
        scaleImage			1

        wide				16
        tall			    16

		visible			1

        "xpos"			"4"
        "ypos"			"0"

		pin_to_sibling "EnergyBarBG"
		pin_corner_to_sibling	TOP_RIGHT
		pin_to_sibling_corner	TOP_LEFT
    }
	EnergyBar
	{
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			3
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			16
		SegmentGap			4
		visible				1

		fgcolor_override	"255 64 64 255"
		scaleImage			1

		wide				4
		tall				80

		"xpos"			"20"
		"ypos"			"0"
	}
    
}