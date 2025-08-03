
resource/ui/layouts/Destiny2/Healthbar_Champion.res
{
	BG
	{
		ControlName			ImagePanel
		image			"vgui/hud/white"
		fg_image			"vgui/hud/white"
		//change_image		vgui/HUD/white

		drawColor	"0 0 0 200"
		Inset				0
		Margin				0
		ProgressDirection			2
		SegmentFill			1
		ChangeStyle			0
		scaleImage			1

		wide				278
		tall				8

		"xpos"			"0"
		"ypos"			"64"
	}

    ChangeBar
	{
		ControlName			CHudProgressBar
		bg_image			"ui/healthbar"
		fg_image			"ui/healthbar"

		fgcolor_override	"255 255 255 255"
		bgcolor_override	"255 255 255 0"
		Inset				0
		Margin				0
		ProgressDirection			0
		SegmentFill			1
		SegmentSize			20
		SegmentGap			1
		scaleImage			1

		wide				278
		tall				8

		"xpos"			"0"
		"ypos"			"0"

		pin_to_sibling			BG
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_LEFT
	}

    Bar
	{
		ControlName			CHudProgressBar
		bg_image			"ui/healthbar"
		fg_image			"ui/healthbar"

		fgcolor_override	"200 150 50 255"
		bgcolor_override	"255 255 255 0"
		Inset				0
		Margin				0
		ProgressDirection			0
		SegmentFill			1
		SegmentSize			20
		SegmentGap			1
		scaleImage			1

		wide				278
		tall				8

		"xpos"			"0"
		"ypos"			"0"

		pin_to_sibling			BG
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_LEFT
	}

	ShieldBar
	{
		ControlName			CHudProgressBar
		bg_image			"vgui/hud/white"
		fg_image			"vgui/hud/white"
		change_image		vgui/HUD/white

		fgcolor_override	"221 221 221 255"
		bgcolor_override	"255 255 255 0"
		ChangeColor			"255 255 255 0"
		Inset				0
		Margin				0
		ProgressDirection			0
		SegmentFill			1
		SegmentSize			10000
		SegmentGap			0
		ChangeStyle			0
		ChangeTime			0
		scaleImage			1

		wide				278
		tall				3

		"xpos"			"0"
		"ypos"			"0"

		pin_to_sibling			Bar
		pin_corner_to_sibling	BOTTOM_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
	}



	StatusEffectText
	{
		ControlName				Label
		xpos					-18
		ypos					2
		wide					400
		tall					12
		visible					1
		enabled					1
		//auto_tall_tocontents	1
		auto_wide_tocontents	1
		labelText				"Daze"
		textAlignment			east
		fgcolor_override 		"255 225 100 255"
		//bgcolor_override 		"0 0 0 200"
		font					JetBrainsMono_11
		//fgcolor_override		""
		allcaps					0
		pin_to_sibling			Bar
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
	}
	StatusEffectBar
	{
		ControlName			CHudProgressBar
		bg_image			"vgui/hud/white"
		fg_image			"vgui/hud/white"
		change_image		vgui/HUD/white

		fgcolor_override	"255 175 75 255"
		bgcolor_override	"0 0 0 200"
		ChangeColor			"255 255 255 0"
		Inset				0
		Margin				0
		ProgressDirection			0
		SegmentFill			1
		SegmentSize			10000
		SegmentGap			0
		ChangeStyle			0
		ChangeTime			0
		scaleImage			1

		wide				48
		tall				4

		"xpos"			"0"
		"ypos"			"0"

		pin_to_sibling			StatusEffectText
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
	}
	StatusEffectIcon
	{
		ControlName			ImagePanel
		image			"vgui/hud/white"
		fg_image			"vgui/hud/white"
		//change_image		vgui/HUD/white

		drawColor	"255 255 255 255"
		Inset				0
		Margin				0
		ProgressDirection			2
		SegmentFill			1
		ChangeStyle			0
		scaleImage			1

		wide				16
		tall				16

		"xpos"			"2"
		"ypos"			"0"
		pin_to_sibling			StatusEffectText
		pin_corner_to_sibling	TOP_RIGHT
		pin_to_sibling_corner	TOP_LEFT
	}
	
	StatusEffectText2
	{
		ControlName				Label
		xpos					0
		ypos					2
		wide					400
		tall					12
		visible					1
		enabled					1
		//auto_tall_tocontents	1
		auto_wide_tocontents	1
		labelText				"Burn"
		fgcolor_override 		"255 225 100 255"
		font					JetBrainsMono_11
		allcaps					0
		pin_to_sibling			StatusEffectBar
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
	}
	StatusEffectBar2
	{
		ControlName			CHudProgressBar
		bg_image			"vgui/hud/white"
		fg_image			"vgui/hud/white"
		change_image		vgui/HUD/white

		fgcolor_override	"255 175 75 255"
		bgcolor_override	"0 0 0 200"
		ChangeColor			"255 255 255 0"
		Inset				0
		Margin				0
		ProgressDirection			0
		SegmentFill			1
		SegmentSize			10000
		SegmentGap			0
		ChangeStyle			0
		ChangeTime			0
		scaleImage			1

		wide				48
		tall				4

		"xpos"			"0"
		"ypos"			"0"

		pin_to_sibling			StatusEffectText2
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
	}
	StatusEffectIcon2
	{
		ControlName			ImagePanel
		image			"vgui/hud/white"
		fg_image			"vgui/hud/white"
		//change_image		vgui/HUD/white

		drawColor	"255 255 255 255"
		Inset				0
		Margin				0
		ProgressDirection			2
		SegmentFill			1
		ChangeStyle			0
		scaleImage			1

		wide				16
		tall				16

		"xpos"			"2"
		"ypos"			"0"
		pin_to_sibling			StatusEffectText2
		pin_corner_to_sibling	TOP_RIGHT
		pin_to_sibling_corner	TOP_LEFT
	}
}