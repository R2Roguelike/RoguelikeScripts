resource/ui/menus/hovers/stat_bar.res
{
    Label
    {
        ControlName				Label
        visible					1
        enabled					1
        auto_wide_tocontents	0
        auto_tall_tocontents	0
        labelText				"Endurance"
        fgcolor_override		"25 25 25 255"
        textAlignment			east
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMono_18

		wide				80
        tall                24
        wrap                0

		"xpos"			"0"
		"ypos"			"0"
    }

    Bar
    {
		ControlName			CHudProgressBar
		bg_image			"vgui/hud/white"
		fg_image			"vgui/hud/white"
		//change_image		vgui/HUD/white

		fgcolor_override	"25 25 25 255"
		bgcolor_override	"0 0 0 75"
		Inset				0
		Margin				0
		ProgressDirection			0
		SegmentFill			0
		SegmentSize			1000
		ChangeStyle			0
		scaleImage			1

		wide				300
		tall				24

		"xpos"			"8"
		"ypos"			"0"

		pin_to_sibling			Label
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_RIGHT
    }
    Value
    {
        ControlName				Label
        visible					1
        enabled					1
        //auto_wide_tocontents	1
        auto_tall_tocontents	0
        labelText				"++25"
        fgcolor_override		"255 255 255 255"
        textAlignment			west
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_24

		wide				40
        tall                24
        wrap                0

		"xpos"			"8"
		"ypos"			"0"
		pin_to_sibling			Bar
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_RIGHT
    }
}