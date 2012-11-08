package engine {
	import flash.net.SharedObject;
	import flash.net.registerClassAlias;

	public class TestsEngine {

		public var russian:String;
		public var spanish:String;

		private var tests:Array;
		private var currentTestIndex:int = 0;

		private static function get sharedObject():SharedObject {
			return SharedObject.getLocal("database");
		}

		public function TestsEngine() {
		}

		private function getReadyTest(tests:Array, russian:String, spanish:String):SimpleTest {
			for (var i:int = 0; i < tests.length; i++) {
				var test:SimpleTest = tests[i];
				if (test.russian == russian && test.spanish == spanish) {
					return test;
				}
			}
			return null;
		}

		public function updateDictionary(dictionary:XML):void {
			// regenerate tests if needed
			registerClassAlias("SimpleTest", SimpleTest);

			var so:SharedObject = sharedObject;
//			so.clear();
			var v:String = so.data["version"];
			tests = so.data["tests"];

			if (v != dictionary.@version.toString() || tests == null) {
				// regenerate tests
				var newTests:Array = [];
				var nouns:XMLList = dictionary.nouns.noun;
				for (var i:int = 0; i < nouns.length(); i++) {
					var forms:XMLList = nouns[i].form;
					for (var j:int = 0; j < forms.length(); j++) {
						var form:XML = forms[j];
						var rus:String = form.@russian.toString();
						var spa:String = form.@spanish.toString();
						var test:SimpleTest = tests == null ? null : getReadyTest(tests, rus, spa);
						if (test == null) {
							test = new SimpleTest(rus, spa)
						}
						newTests.push(test);
					}
				}
				tests = newTests;
				so.data["tests"] = tests;
				so.data["version"] = dictionary.@version.toString();
			}
			currentTestIndex = -1;
			nextTest();
		}

		public function nextTest():void {
			// find next unpassed test
			var test:SimpleTest;
			currentTestIndex++;
			while (currentTestIndex < tests.length) {
				test = tests[currentTestIndex];
				if (test.passedCount == 0) {
					break;
				}
				currentTestIndex++;
			}
			if (currentTestIndex < tests.length) {
				russian = test.russian;
				spanish = test.spanish;
			} else {
				russian = null;
				spanish = null;
			}
		}

		public function passTest():void {
			var test:SimpleTest = tests[currentTestIndex];
			test.passedCount++;
			test.lastPassedTime = (new Date()).valueOf();
			sharedObject.data["tests"] = tests;
		}

		public function failTest():void {
			var test:SimpleTest = tests[currentTestIndex];
			test.passedCount = 0;
			test.lastPassedTime = 0;
			sharedObject.data["tests"] = tests;
		}

	}
}
