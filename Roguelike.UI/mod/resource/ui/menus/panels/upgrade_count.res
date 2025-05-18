resource/ui/menus/panels/mod_slot.res
{
    Title
    {
        ControlName				Label
        xpos					0
        ypos				    0
        wide					250
        tall					24
        visible					1
        enabled					1
        //auto_wide_tocontents	1
        //auto_tall_tocontents	1
        labelText				"Utility"
        fgcolor_override		"255 255 255 255"
        textAlignment			west
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_20
        zpos				1
    }
    TitleRight
    {
        ControlName				Label
        xpos					0
        ypos				    0
        wide					250
        tall					24
        visible					1
        enabled					1
        //auto_wide_tocontents	1
        //auto_tall_tocontents	1
        labelText				"Utility"
        fgcolor_override		"255 255 255 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_20
		zpos				1
    }
    BarBG
    {
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			0
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			12
		SegmentGap			5
		visible				1

		fgcolor_override	"25 25 25 128"
		//bgcolor_override	"0 0 0 128"
		scaleImage			1

		wide				250
		tall				12

		"xpos"			"0"
		"ypos"			"0"

		pin_to_sibling "Title"
		pin_to_sibling_corner	BOTTOM_LEFT
		pin_corner_to_sibling	TOP_LEFT
    }
    Bar
    {
		ControlName			CHudProgressBar
		image			    "vgui/hud/white"
		fg_image			"vgui/hud/white"

		ProgressDirection			0
		CircularEnabled 		0
		SegmentFill			1
		SegmentSize			12
		SegmentGap			5
		visible				1

		fgcolor_override	"255 255 255 255"
		//bgcolor_override	"0 0 0 128"
		scaleImage			1

		wide				250
		tall				12

		"xpos"			"0"
		"ypos"			"0"

		pin_to_sibling "BarBG"
		pin_to_sibling_corner	BOTTOM_LEFT
		pin_corner_to_sibling	BOTTOM_LEFT
    }
}