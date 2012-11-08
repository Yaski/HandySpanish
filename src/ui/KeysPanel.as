package ui {
	import flash.display.Sprite;

	public class KeysPanel extends Sprite {

		private var _width:int;
		private var _height:int;

		public function KeysPanel(width:int = 0, height:int = 0) {
			_width = width;
			_height = height;
			if (width > 0 && height > 0) {
				init(width, height);
			}
//			addEventListener(MouseEvent.CLICK, onClick);
		}

//		private function onClick(event:MouseEvent):void {
//			trace("clicked", event.target);
//		}

		private static const ALPHABET:Array = [
			'á', 'ú', 'ó', 'é', 'ü', 'ñ', 'í',
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
			'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
		];
		private function init(w:int, h:int):void {
			while (numChildren) {removeChildAt(0)};

			// 240x245
			var hCoeff:Number = h/245;
			var wCoeff:Number = w/240;
			var scale:Number = Math.sqrt(w*w + h*h)/Math.sqrt(240*240 + 245*245);

			createKeysLine(0, 7, wCoeff*10, hCoeff*20, wCoeff*32, scale);

			// abcd
			createKeysLine(7, 4, wCoeff*60, hCoeff*60, wCoeff*35, scale);
			// efghij
			createKeysLine(11, 6, wCoeff*20, hCoeff*95, wCoeff*35, scale);
			// klmno
			createKeysLine(17, 5, wCoeff*40, hCoeff*130, wCoeff*35, scale);
			// pqrstu
			createKeysLine(22, 6, wCoeff*20, hCoeff*165, wCoeff*35, scale);
			// vwxyz
			createKeysLine(28, 5, wCoeff*40, hCoeff*200, wCoeff*35, scale);
		}

		private function createKeysLine(start:int, count:int, x:Number, y:Number, interval:Number, scale:Number):void {
			for (var i:int = 0; i < count; i++) {
				var button:KeyButton = new KeyButton(ALPHABET[int(start + i)], x + i*interval, y);
				button.scaleX = scale;
				button.scaleY = scale;
				addChild(button);
			}
		}

		public function resize(width:int, height:int):void {
			this._width = width;
			this._height = height;
			init(width, height);
		}

		override public function get width():Number {
			return _width;
		}
		override public function get height():Number {
			return _height;
		}

	}
}
