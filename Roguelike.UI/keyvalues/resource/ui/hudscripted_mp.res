Resource/UI/HudScripted_mp.res
{
	Screen
	{
		ControlName		ImagePanel
		wide			%100
		tall			%100
		visible			1
		scaleImage		1
		fillColor		"0 0 0 0"
		drawColor		"0 0 0 0"
	}

	RoguelikeTimer
    {
		ControlName			CNestedPanel
 
		wide				768
		tall				128

		ypos				-16

		zpos				200
		visible				1
		controlSettingsFile	"resource/UI/roguelike_timer.res"

		pin_to_sibling				Screen
		pin_corner_to_sibling		TOP
		pin_to_sibling_corner		TOP
    }

	Healthbars
	{
		ControlName			CNestedPanel
 
		wide				%100
		tall				%100

		zpos				0
		visible				1
		controlSettingsFile	"resource/UI/healthbars.res"

		pin_to_sibling				Screen
		pin_corner_to_sibling		TOP
		pin_to_sibling_corner		TOP
	}

	CrosshairBar
	{
		ControlName				CHudProgressBar
		zpos					306
		wide					200
		tall					200
		visible					1
		fg_image				"ui/arc"
		bg_image				"ui/arc"
		
		fgcolor_override 		"255 255 255 255"
		bgcolor_override 		"0 0 0 128"
		paintborder				0
		CircularEnabled 		1
		CircularClockwise		0

		pin_to_sibling				Screen
		pin_corner_to_sibling		CENTER
		pin_to_sibling_corner		CENTER
	}
}
