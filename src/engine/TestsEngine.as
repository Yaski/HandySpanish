package engine {
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.filesystem.File;

	public class TestsEngine {

		private var _currentTest:SimpleTest;

		private var hasTestStm:SQLStatement;
		private var insertTestStm:SQLStatement;
		private var selectTestStm:SQLStatement;
		private var updateTestStm:SQLStatement;
		private var rightAnswersCounterStm:SQLStatement;
		private var restTestsCounterStm:SQLStatement;
		private var removeTestStm:SQLStatement;

		private var _rightAnswersCount:int;
		private var _restTestsCount:int;

		public function TestsEngine() {
		}

		public function init():void {
			var dbFile:File = File.applicationStorageDirectory.resolvePath("tests.db");
//			trace("Database:", dbFile.nativePath);
			var con:SQLConnection = new SQLConnection();
			con.open(dbFile);
			var createStmt:SQLStatement = new SQLStatement();
			createStmt.sqlConnection = con;
			var sql:String = "";
			sql += "CREATE TABLE IF NOT EXISTS tests (";
			sql += " id INTEGER PRIMARY KEY AUTOINCREMENT,";
			sql += " question String CHECK (question != ''),";
			sql += " prefix String,";
			sql += " answer String CHECK (answer != ''),";
			sql += " passed int CHECK (passed >= 0) DEFAULT 0,";
			sql += " whenTested INTEGER";
			sql += ")";
			createStmt.text = sql;
			createStmt.execute();
//			con.loadSchema(SQLTableSchema);
//			con.loadSchema();
//			trace(con.getSchemaResult().tables);
			insertTestStm = new SQLStatement();
			insertTestStm.sqlConnection = con;
			sql = "INSERT INTO tests (question, prefix, answer, whenTested) ";
			sql += "VALUES (:russian, :prefix, :spanish, :whenTested)";
			insertTestStm.text = sql;
			insertTestStm.parameters[":russian"] = "дом";
			insertTestStm.parameters[":prefix"] = "";
			insertTestStm.parameters[":spanish"] = "la casa";
			insertTestStm.parameters[":whenTested"] = int((new Date()).time/1000);
//			insertTestStm.execute();

			hasTestStm = new SQLStatement();
			hasTestStm.sqlConnection = con;
			sql = "SELECT id FROM tests WHERE question=:russian AND prefix=:prefix AND answer=:spanish";
			hasTestStm.text = sql;
			hasTestStm.parameters[":russian"] = "кот";
			hasTestStm.parameters[":prefix"] = "a";
			hasTestStm.parameters[":spanish"] = "el gato";
//			selectStmt.execute();

			// passed 0 : get all
			// passed 1 : get 1 day old
			// passed 2 : get 2 days old
			// passed 3 : get 1 week old
			// passed 4 : get 2 weeks old
			// passed 5 : get 1 month old
			selectTestStm = new SQLStatement();
			selectTestStm.sqlConnection = con;
			selectTestStm.itemClass = SimpleTest;
			sql = "SELECT id, question, prefix, answer, passed FROM tests WHERE passed=0 ";
			sql += "OR (passed=1 AND whenTested<:oneDayAgo) ";
			sql += "OR (passed=2 AND whenTested<:twoDaysAgo) ";
			sql += "OR (passed=3 AND whenTested<:oneWeekAgo) ";
			sql += "OR (passed=4 AND whenTested<:twoWeeksAgo) ";
			sql += "OR (passed=5 AND whenTested<:oneMonthAgo) ";
			sql += "ORDER BY whenTested LIMIT 1";
//			sql += "ORDER BY whenTested LIMIT 100";
			selectTestStm.text = sql;

			updateTestStm = new SQLStatement();
			updateTestStm.sqlConnection = con;
			sql = "UPDATE tests SET passed=:passed, whenTested=:whenTested WHERE id=:id";
			updateTestStm.text = sql;

			removeTestStm = new SQLStatement();
			removeTestStm.sqlConnection = con;
			sql = "DELETE FROM tests WHERE id=:id";
			removeTestStm.text = sql;

			rightAnswersCounterStm = new SQLStatement();
			rightAnswersCounterStm.sqlConnection = con;
			sql = "SELECT COUNT(*) FROM tests WHERE passed>0";
			rightAnswersCounterStm.text = sql;
			restTestsCounterStm = new SQLStatement();
			restTestsCounterStm.sqlConnection = con;
			sql = "SELECT COUNT(*) FROM tests WHERE passed=0";
			restTestsCounterStm.text = sql;

			countTests();
//			con.close();

			selectTest();
		}

		private function countTests():void {
			var result:SQLResult;
			rightAnswersCounterStm.execute();
			result = rightAnswersCounterStm.getResult();
			_rightAnswersCount = (result.data == null || result.data.length == 0) ? 0 : result.data[0]["COUNT(*)"];
			restTestsCounterStm.execute();
			result = restTestsCounterStm.getResult();
			_restTestsCount = (result.data == null || result.data.length == 0) ? 0 : result.data[0]["COUNT(*)"];
		}

		public function importDictionary(dictionary:XML):void {
			insertTestStm.parameters[":whenTested"] = int((new Date()).time/1000);
			var words:XMLList = dictionary.words.word;
			for (var i:int = 0; i < words.length(); i++) {
				var forms:XMLList = words[i].form;
				for (var j:int = 0; j < forms.length(); j++) {
					var form:XML = forms[j];
					var rus:String = form.@russian.toString();
					var spa:String = form.@spanish.toString();
					if (!checkCorrectness(spa)) {
						throw new Error("Incorrect test: " + forms[j].@name.toString() + ' "' + spa + '"');
					}
					var pre:String = form.@prefix == null ? "" : form.@prefix.toString();
					hasTestStm.parameters[":russian"] = rus;
					hasTestStm.parameters[":prefix"] = pre;
					hasTestStm.parameters[":spanish"] = spa;
					hasTestStm.execute();
					var result:SQLResult = hasTestStm.getResult();
					if (result.data == null || result.data.length == 0) {
						insertTestStm.parameters[":russian"] = rus;
						insertTestStm.parameters[":prefix"] = pre;
						insertTestStm.parameters[":spanish"] = spa;
						insertTestStm.execute();
					}
				}
			}
			countTests();
			selectTest();
		}

		private function checkCorrectness(word:String):Boolean {
			// can not be spaces at the end
			// no more than one space in the word
			// using of unknown symbols
			const space:Number = ' '.charCodeAt(0);

			if (word.length == 0) return false;
			if (word.charCodeAt(word.length - 1) == space) return false;
			var wasSpace:Boolean = false;
			for (var i:int = 0; i < word.length; i++) {
				var code:Number = word.charCodeAt(i);
				if (code == space) {
					if (wasSpace) return false;
					wasSpace = true;
				} else {
					if (code < 97) {
						return false;
					}
					if (code > 122 && code != 225 && code != 250 && code != 243 && code != 233 && code != 252 && code != 241 && code != 237) {
						return false;
					}
					wasSpace = false;
				}
			}
			return true;
		}

		public function selectTest():void {
			// find next unpassed test
			var today:Number = int((new Date()).time/1000);
			selectTestStm.parameters[":oneDayAgo"] = today - 24*60*60;
			selectTestStm.parameters[":twoDaysAgo"] = today - 48*60*60;
			selectTestStm.parameters[":oneWeekAgo"] = today - 7*24*60*60;
			selectTestStm.parameters[":twoWeeksAgo"] = today - 14*24*60*60;
			selectTestStm.parameters[":oneMonthAgo"] = today - 30*24*60*60;
			selectTestStm.execute();

			var result:SQLResult = selectTestStm.getResult();
			if (result.data != null && result.data.length > 0) {
				_currentTest = result.data[0];
			} else {
				_currentTest = null;
			}
		}

		public function passTest():void {
			if (_currentTest == null) return;

			if (_currentTest.passed == 0) {
				_rightAnswersCount++;
				_restTestsCount--;
			}

			updateTestStm.parameters[":id"] = _currentTest.id;
			updateTestStm.parameters[":passed"] = _currentTest.passed + 1;
			updateTestStm.parameters[":whenTested"] = int((new Date()).time/1000);
			updateTestStm.execute();
		}

		public function failTest():void {
			if (_currentTest == null) return;

			if (_currentTest.passed > 0) {
				_rightAnswersCount--;
				_restTestsCount++;
			}

			updateTestStm.parameters[":id"] = _currentTest.id;
			updateTestStm.parameters[":passed"] = 0;
			updateTestStm.parameters[":whenTested"] = int((new Date()).time/1000);
			updateTestStm.execute();
		}

		public function removeTest():void {
			if (_currentTest == null) return;

			if (_currentTest.passed > 0) {
				_rightAnswersCount--;
			} else {
				_restTestsCount--;
			}

			removeTestStm.parameters[":id"] = _currentTest.id;
			removeTestStm.execute();
			_currentTest = null;
		}

		public function get rightAnswersCount():int {
			return _rightAnswersCount;
		}

		public function get restTestsCount():int {
			return _restTestsCount;
		}

		public function get russian():String {
			return (_currentTest == null ? "" : _currentTest.question);
		}

		public function get prefix():String {
			return (_currentTest == null ? "" : _currentTest.prefix);
		}

		public function get spanish():String {
			return (_currentTest == null ? "" : _currentTest.answer);
		}

	}
}
