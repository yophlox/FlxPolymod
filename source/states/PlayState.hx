package states;

import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.text.FlxText;

class PlayState extends FlxState
{
	private var gridLines:FlxTypedGroup<FlxSprite>;
	override public function create()
	{
		gridLines = new FlxTypedGroup<FlxSprite>();
        for (i in 0...20) {
            var hLine = new FlxSprite(0, i * 40);
            hLine.makeGraphic(FlxG.width, 1, 0x33FFFFFF);
            hLine.scrollFactor.set(0, 0);  // Add this line
            gridLines.add(hLine);

            var vLine = new FlxSprite(i * 40, 0);
            vLine.makeGraphic(1, FlxG.height, 0x33FFFFFF);
            vLine.scrollFactor.set(0, 0);  // Add this line
            gridLines.add(vLine);
        }
        add(gridLines);

		var text:FlxText = new FlxText(0, 0, 0, 'Press 7 to open the mods menu lol', 12);
		add(text);
		#if desktop
		Modding.reload();
		#end
		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.SEVEN)
			if (Modding.trackedMods != [])
				FlxG.switchState(new ModsMenuState());
			else {
				Main.toast.create('No Mods Installed!', 0xFFFFFF00, 'Please add mods to be able to access the menu!');
			}
		super.update(elapsed);
	}
}
