package {

	import engine.TestsEngine;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	import ui.KeyButton;
	import ui.KeysPanel;

	[SWF (width = 240, height = 400, frameRate = 40, backgroundColor = 0xFFFFFF)]
	public class HandySpanish extends Sprite {

		private var numRightInd:TextField;
		private var numTestsInd:TextField;
		private var removeButton:KeyButton;
		private var exerciseZone:Sprite;
		private var exerciseWord:TextField;
		private var prefixWord:TextField;
		private var resultWord:TextField;
		private var keys:KeysPanel;

		private var words:TestsEngine;
		private var numErratas:int = -1;

		public function HandySpanish() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			exerciseZone = new Sprite();
			addChild(exerciseZone);

			numRightInd = new TextField();
			numRightInd.mouseEnabled = false;
			numRightInd.defaultTextFormat = new TextFormat(null, 10, 0x7F7F7F);
			numRightInd.text = "Верных: 100";
			numRightInd.selectable = false;
			numRightInd.autoSize = TextFieldAutoSize.LEFT;
			addChild(numRightInd);

			numTestsInd = new TextField();
			numTestsInd.x = 100;
			numTestsInd.mouseEnabled = false;
			numTestsInd.defaultTextFormat = new TextFormat(null, 10, 0x7F7F7F);
			numTestsInd.text = "Осталось: 100";
			numTestsInd.selectable = false;
			numTestsInd.autoSize = TextFieldAutoSize.LEFT;
			addChild(numTestsInd);

			removeButton = new KeyButton("X", 200);
			addChild(removeButton);

			exerciseWord = new TextField();
			exerciseWord.mouseEnabled = false;
			exerciseWord.defaultTextFormat = new TextFormat(null, 24, 0x0);
			exerciseWord.text = "яблоко";
			exerciseWord.selectable = false;
			exerciseWord.autoSize = TextFieldAutoSize.LEFT;
			addChild(exerciseWord);

			words = new TestsEngine();
			words.init();
			loadDictionary("dictionaries/nouns.xml", "nounsVersion");
			loadDictionary("dictionaries/adjectives.xml", "adjectVersion");
			loadDictionary("dictionaries/verbs.xml", "verbsVersion");
			loadDictionary("dictionaries/other.xml", "otherVersion");

			prefixWord = new TextField();
			prefixWord.mouseEnabled = false;
			prefixWord.defaultTextFormat = new TextFormat(null, 24, 0x0);
			prefixWord.selectable = false;
			prefixWord.autoSize = TextFieldAutoSize.LEFT;
			addChild(prefixWord);

			resultWord = new TextField();
			resultWord.mouseEnabled = false;
			resultWord.defaultTextFormat = new TextFormat(null, 24, 0x0);
			resultWord.selectable = false;
			resultWord.autoSize = TextFieldAutoSize.LEFT;
			addChild(resultWord);

			keys = new KeysPanel();
			addChild(keys);

			updateTest();

			keys.addEventListener(MouseEvent.CLICK, onKeyClick);
			removeButton.addEventListener(MouseEvent.CLICK, onRemoveTest);
			exerciseZone.addEventListener(MouseEvent.CLICK, nextWord);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}

		private function loadDictionary(path:String, versionKey:String):void {
			var file:File = File.applicationDirectory.resolvePath(path);
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var content:XML = XML(stream.readUTFBytes(stream.bytesAvailable));
			stream.close();

			var so:SharedObject = SharedObject.getLocal("database");
//			so.clear();
			var version:String = so.data[versionKey];
			if (version != content.@version.toString()) {
				trace("import dict: " + path);
				words.importDictionary(content);
				so.data[versionKey] = content.@version.toString();
			}
		}

		private function onRemoveTest(event:MouseEvent):void {
			words.removeTest();
			updateTest();
		}

		private function onKeyClick(event:MouseEvent):void {
			var button:KeyButton = event.target as KeyButton;
			if (button != null) {
				var index:int = resultWord.text.length;
				if (index < words.spanish.length) {
					if (words.spanish.charAt(index) == ' ') {
						resultWord.appendText(' ');
						index++;
					}

					if (words.spanish.charAt(index) == button.text) {
						resultWord.appendText(button.text);
						if (numErratas == -1) {
							numErratas = 0;
						}
						onResize();
					} else {
						numErratas = numErratas < 1 ? 1 : numErratas + 1;
						onResize();
					}
				}
			}
		}

		private function nextWord(e:Event):void {
			if (resultWord.text.length >= words.spanish.length) {
				// full world
				if (numErratas <= 1) {
					words.passTest();
				} else {
					words.failTest();
				}
				updateTest();
			}
		}

		private function updateTest():void {
			words.selectTest();
			numRightInd.text = "Верных: " + words.rightAnswersCount;
			numTestsInd.text = "Осталось: " + words.restTestsCount;
			numErratas = -1;
			exerciseWord.text = words.russian;
			prefixWord.text = words.prefix != "" ? words.prefix + " " : "";
			resultWord.text = "";
			onResize();
		}

		private function onResize(event:Event = null):void {
			var s:Number;
			var wCoeff:Number = stage.stageWidth/240;
			var hCoeff:Number = stage.stageHeight/400;
			var scale:Number = Math.sqrt(stage.stageWidth*stage.stageWidth + stage.stageHeight*stage.stageHeight)/Math.sqrt(240*240 + 400*400);

			graphics.clear();

			numRightInd.scaleX = scale;
			numRightInd.scaleY = scale;
			numRightInd.x = 0;
			numRightInd.y = 0;
			numTestsInd.scaleX = scale;
			numTestsInd.scaleY = scale;
			numTestsInd.x = wCoeff*100;
			numTestsInd.y = 0;

			exerciseWord.scaleX = scale;
			exerciseWord.scaleY = scale;
			if ((exerciseWord.width + hCoeff*10) > stage.stageWidth) {
				s = stage.stageWidth/(exerciseWord.width + hCoeff*10);
				exerciseWord.scaleX *= s;
				exerciseWord.scaleY *= s;
			}

			exerciseWord.x = (stage.stageWidth - exerciseWord.width) >> 1;
			exerciseWord.y = hCoeff*30;

			prefixWord.scaleX = scale;
			prefixWord.scaleY = scale;
			resultWord.scaleX = scale;
			resultWord.scaleY = scale;
			var text:String = resultWord.text;
			resultWord.text = words.spanish;

			if ((prefixWord.width + resultWord.width + hCoeff*10) > stage.stageWidth) {
				s = stage.stageWidth/(prefixWord.width + resultWord.width + hCoeff*10);
				prefixWord.scaleX *= s;
				prefixWord.scaleY *= s;
				resultWord.scaleX *= s;
				resultWord.scaleY *= s;
			}

			prefixWord.x = (stage.stageWidth - prefixWord.width - resultWord.width) >> 1;
			prefixWord.y = hCoeff*80;
			resultWord.x = prefixWord.x + prefixWord.width;
			resultWord.y = prefixWord.y;

			var y:Number = resultWord.y + resultWord.height + hCoeff*5;
			if (numErratas == -1) {
				graphics.beginFill(0x0);
			} else if (numErratas == 0) {
				graphics.beginFill(0xFF00);
			} else if (numErratas == 1) {
				graphics.beginFill(0xFFFF00);
			} else {
				graphics.beginFill(0xFF0000);
			}
			var lineStartX:Number = 0;
			var wasWhitespace:Boolean = true;
			resultWord.text = "";
			for (var index:int = 0; index < words.spanish.length; index++) {
				// draw rect
				var char:String = words.spanish.charAt(index);
				if (char == ' ') {
					if (!wasWhitespace) {
						graphics.drawRect(resultWord.x + lineStartX, y, resultWord.width - lineStartX, hCoeff*2);
					}
					wasWhitespace = true;
					resultWord.appendText(char);
					lineStartX = resultWord.width;
				} else if (index == (words.spanish.length - 1)) {
					resultWord.appendText(char);
					graphics.drawRect(resultWord.x + lineStartX, y, resultWord.width - lineStartX, hCoeff*2);
				} else {
					resultWord.appendText(char);
					wasWhitespace = false;
				}
			}
			resultWord.text = text;

			var lineY:int = (stage.stageHeight >> 1) - hCoeff*50;

			removeButton.scaleX = scale*0.7;
			removeButton.scaleY = scale*0.7;
			removeButton.x = stage.stageWidth - removeButton.width;
			removeButton.y = lineY - removeButton.height;

			exerciseZone.graphics.clear();
			exerciseZone.graphics.beginFill(0xFFFFFF, 0);
			exerciseZone.graphics.drawRect(0, 0, stage.stageWidth, lineY + hCoeff*5);

			graphics.beginFill(0x0);
			graphics.drawRect(0, lineY, stage.stageWidth, hCoeff*5);

			keys.x = 0;
			keys.y = lineY + hCoeff*5;
			keys.resize(stage.stageWidth, stage.stageHeight - lineY - hCoeff*5);
		}

	}
}
