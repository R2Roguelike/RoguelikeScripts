resource/ui/menus/panels/stat.res
{
    BG
    {
        ControlName			ImagePanel

        image			"ui/stats/energy"

        drawColor	"255 255 255 255"
        scaleImage			1

        wide				64
        tall			    64

        "xpos"			"16"
        "ypos"			"8"
    }

    Value
    {
        
        ControlName				Label
        visible					1
        enabled					1
        //auto_wide_tocontents	1
        auto_tall_tocontents	0
        labelText				"45"
        fgcolor_override		"255 255 255 255"
        textAlignment			center
        //fgcolor_override 		"255 255 255 255"
        //bgcolor_override 		"0 0 0 200"
        font					JetBrainsMonoBold_36

		wide				96
        tall                32
        wrap                0

		"xpos"			"0"
		"ypos"			"4"
		pin_to_sibling			BG
		pin_corner_to_sibling	TOP
		pin_to_sibling_corner	BOTTOM
    }
}