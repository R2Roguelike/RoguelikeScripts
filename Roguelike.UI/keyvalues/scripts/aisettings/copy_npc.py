import os

path = "C:/Program Files (x86)/Steam/steamapps/common/Titanfall2/vpk_exports/sp_beacon/scripts/aisettings"
newPath = "C:/Program Files (x86)/Steam/steamapps/common/Titanfall2/"\
    "R2Roguelike/mods/Roguelike.UI/keyvalues/scripts/aisettings/"
toPaste = '''{
    ui_targetinfo ""
    ui_targetinfo "" [$mp]
    ui_targetinfo "" [$sp]

	evasiveCombatShieldPct					0.0
	
	evasiveCombatHealthSegmentPct			1.0
	aggressiveCombatHealthSegmentPct		0.0
	
	evasiveCombatHealthChangeRateDiff		-10000
	aggresiveCombatHealthChangeRateDiff		500

	waitBetweenWeaponBurst			0
	resetBurstOnStopShootOverlay	1
	circleStrafeDist			900
}'''

for filename in os.listdir(path):
    f = os.path.join(path, filename)
    # checking if it is a file
    if os.path.isfile(f):
        content = open(f, "r").read()
        newFile = open(os.path.join(newPath, filename), "w+")
        newFile.write(filename.split(".")[0] + "\n" + toPaste)