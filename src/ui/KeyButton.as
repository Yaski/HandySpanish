package ui {
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class KeyButton extends TextField {

		private static const SIZE:int = 25;

		public function KeyButton(label:String, x:Number = 0, y:Number = 0) {
			var tf:TextFormat = new TextFormat(null, 16, 0x0);
			tf.align = TextFormatAlign.CENTER;
			defaultTextFormat = tf;
			selectable = false;
			autoSize = TextFieldAutoSize.NONE;
			border = true;
			borderColor = 0x0;
			background = true;
			backgroundColor = 0xEFEFEF;
			text = label;

			this.x = x;
			this.y = y;
			width = SIZE;
			height = SIZE;
		}

	}
}
