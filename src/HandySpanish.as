package {

	import engine.TestsEngine;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	import ui.KeyButton;
	import ui.KeysPanel;

	[SWF (width = 240, height = 400, frameRate = 40, backgroundColor = 0xFFFFFF)]
	public class HandySpanish extends Sprite {

		[Embed ("dictionary.xml", mimeType="application/octet-stream")] private static const DictionaryClass:Class;
		
		private var exerciseWord:TextField;
		private var resultWord:TextField;
		private var keys:KeysPanel;

		private var words:TestsEngine;
		private var currentCorrect:int = -1;

		public function HandySpanish() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			exerciseWord = new TextField();
			exerciseWord.defaultTextFormat = new TextFormat(null, 24, 0x0);
			exerciseWord.text = "яблоко";
			exerciseWord.selectable = false;
			exerciseWord.autoSize = TextFieldAutoSize.LEFT;
			addChild(exerciseWord);

			words = new TestsEngine();
			words.updateDictionary(XML(new DictionaryClass()));

			exerciseWord.text = words.russian;

			resultWord = new TextField();
			resultWord.defaultTextFormat = new TextFormat(null, 24, 0x0);
			resultWord.text = "";
			resultWord.selectable = false;
			resultWord.autoSize = TextFieldAutoSize.LEFT;
			addChild(resultWord);

			keys = new KeysPanel();
			keys.addEventListener(MouseEvent.CLICK, onKeyClick);
			addChild(keys);

			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
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
						if (currentCorrect == -1) {
							currentCorrect = 1;
							onResize();
						}
					} else {
						if (currentCorrect != 0) {
							currentCorrect = 0;
							onResize();
						}
					}
					if (index == words.spanish.length - 1) {
						// last symbol
						if (currentCorrect == 1) {
							words.passTest();
						} else {
							words.failTest();
						}
						words.nextTest();
						if (words.russian == null) {
							exerciseWord.visible = false;
							resultWord.visible = false;
							return;
						} else {
							currentCorrect = -1;
							exerciseWord.text = words.russian;
							resultWord.text = "";
							onResize();
						}
					}
				}
			}
		}

		private function onResize(event:Event = null):void {
			var hCoeff:Number = stage.stageHeight/400;
			var scale:Number = Math.sqrt(stage.stageWidth*stage.stageWidth + stage.stageHeight*stage.stageHeight)/Math.sqrt(240*240 + 400*400);

			graphics.clear();

			exerciseWord.scaleX = scale;
			exerciseWord.scaleY = scale;
			exerciseWord.x = (stage.stageWidth - exerciseWord.width) >> 1;
			exerciseWord.y = hCoeff*30;

			resultWord.scaleX = scale;
			resultWord.scaleY = scale;
			var text:String = resultWord.text;
			resultWord.text = words.spanish;
			resultWord.x = (stage.stageWidth - resultWord.width) >> 1;
			resultWord.y = hCoeff*80;

			var y:Number = resultWord.y + resultWord.height + hCoeff*5;
			if (currentCorrect == -1) {
				graphics.beginFill(0x0);
			} else if (currentCorrect == 0) {
				graphics.beginFill(0xFF0000);
			} else {
				graphics.beginFill(0xFF00);
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

			graphics.beginFill(0x0);
			graphics.drawRect(0, lineY, stage.stageWidth, hCoeff*5);

			keys.x = 0;
			keys.y = lineY + hCoeff*5;
			keys.resize(stage.stageWidth, stage.stageHeight - lineY - hCoeff*5);
		}

	}
}
