package states;

import haxe.io.Bytes;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxObject;
import flixel.FlxSprite;

class ModsMenuState extends FlxState {
	var daMods:FlxTypedGroup<FlxText>;
	var iconArray:Array<ModIcon> = [];
	var description:FlxText;
	var curSelected:Int = 0;
    private var gridLines:FlxTypedGroup<FlxSprite>;
    var camFollow:FlxObject;

	override function create() {
        super.create();

        camFollow = new FlxObject(80, 0, 0, 0);
		camFollow.screenCenter(X);

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


		daMods = new FlxTypedGroup<FlxText>();
		add(daMods);

		for (i in 0...Modding.trackedMods.length) {
			var text:FlxText = new FlxText(20, 60 + (i * 60), Modding.trackedMods[i].title, 32);
			text.setFormat(Paths.font('vcr.ttf'), 60, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.ID = i;
			daMods.add(text);

			var icon:ModIcon = new ModIcon(Modding.trackedMods[i].icon);
			icon.sprTracker = text;
			iconArray.push(icon);
			add(icon);
		}

		description = new FlxText(0, FlxG.height * 0.1, FlxG.width * 0.9, '', 28);
		description.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		description.screenCenter(X);
		description.scrollFactor.set();
		description.borderSize = 3;
		add(description);

		changeSelection();

        FlxG.camera.follow(camFollow, LOCKON, 0.25);
	}

	override function update(elapsed:Float) {
        super.update(elapsed);

		var up = FlxG.keys.anyPressed([UP, W]);
		var down = FlxG.keys.anyPressed([DOWN, S]);
		var accept = FlxG.keys.anyPressed([ENTER, Z]);
		var exit = FlxG.keys.anyPressed([ESCAPE, BACKSPACE]);

		if (up || down)
			changeSelection(up ? -1 : 1);

		if (exit) {
			Modding.reload();
			FlxG.switchState(new PlayState());
		} else if (accept) {
			if (!FlxG.save.data.disabledMods.contains(Modding.trackedMods[curSelected].id)) {
				FlxG.save.data.disabledMods.push(Modding.trackedMods[curSelected].id);
				FlxG.save.flush();
				changeSelection();
			} else {
				FlxG.save.data.disabledMods.remove(Modding.trackedMods[curSelected].id);
				FlxG.save.flush();
				changeSelection();
			}
		}
	}

	function changeSelection(change:Int = 0) {
        curSelected = FlxMath.wrap(curSelected + change, 0, Modding.trackedMods.length - 1);

		for (i in 0...iconArray.length)
			iconArray[i].alpha = (!FlxG.save.data.disabledMods.contains(Modding.trackedMods[i].id)) ? 1 : 0.6;

        daMods.forEach(function(txt:FlxText) {
			txt.alpha = (!FlxG.save.data.disabledMods.contains(Modding.trackedMods[txt.ID].id)) ? 1 : 0.6;
			if (txt.ID == curSelected)
				camFollow.y = txt.y;
		});

		if (Modding.trackedMods[curSelected].description != null) {
			description.text = Modding.trackedMods[curSelected].description;
			description.screenCenter(X);
		}
	}
}

class ModIcon extends FlxSprite {
	public var sprTracker:FlxSprite;

	public function new(bytes:Bytes) {
		super();

        try {
		    loadGraphic(BitmapData.fromBytes(bytes));
        } catch (e:Dynamic) {
            trace('error getting mod icon: $e');
            loadGraphic(Paths.image('menu/unknownMod'));
        }
		setGraphicSize(75, 75);
        scrollFactor.set();
		updateHitbox();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y);
			scrollFactor.set(sprTracker.scrollFactor.x, sprTracker.scrollFactor.y);
		}
	}
}
