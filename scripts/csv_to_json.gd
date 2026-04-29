@tool
extends EditorScript

## Google Sheets からエクスポートした CSV をシナリオ JSON に変換するツール
## 使い方: エディタでこのスクリプトを開き、実行ボタンを押すと、
## 指定された CSV ファイルを読み込み、JSON ファイルを出力します。

const CSV_PATH = "res://data/sample_scenario.csv"
const JSON_OUTPUT_PATH = "res://data/scenario.json"

## CSV の1行をダブルクォートに対応して分割します。
static func parse_csv_line(line: String) -> PackedStringArray:
	var result = PackedStringArray()
	var current = ""
	var in_quotes = false
	for i in range(line.length()):
		var c = line[i]
		if in_quotes:
			if c == '"':
				if i + 1 < line.length() and line[i + 1] == '"':
					current += '"'
					i += 1
				else:
					in_quotes = false
			else:
				current += c
		else:
			if c == '"':
				in_quotes = true
			elif c == ',':
				result.append(current.strip_edges())
				current = ""
			else:
				current += c
	result.append(current.strip_edges())
	return result

func _run() -> void:
	var csv_file = FileAccess.open(CSV_PATH, FileAccess.READ)
	if csv_file == null:
		print("CSVファイルを開けません: ", CSV_PATH)
		return
	var csv_text = csv_file.get_as_text()
	csv_file.close()
	var raw_lines = csv_text.split("\n")
	if raw_lines.size() < 2:
		print("CSVにデータがありません")
		return
	# ヘッダー行を解析
	var headers = parse_csv_line(raw_lines[0])
	var id_idx = headers.find("id")
	var speaker_idx = headers.find("speaker")
	var text_idx = headers.find("text")
	var next_idx = headers.find("next")
	var choices_idx = headers.find("choices")
	var effects_idx = headers.find("effects")
	if id_idx == -1 or speaker_idx == -1 or text_idx == -1:
		print("必須列(id, speaker, text)がありません")
		return
	var scenario_lines = []
	for i in range(1, raw_lines.size()):
		var row = raw_lines[i].strip_edges()
		if row.is_empty():
			continue
		var cols = parse_csv_line(row)
		if cols.size() <= max(id_idx, speaker_idx, text_idx):
			continue
		var line_dict = {}
		line_dict["id"] = cols[id_idx].strip_edges()
		line_dict["speaker"] = cols[speaker_idx].strip_edges()
		line_dict["text"] = cols[text_idx].strip_edges()
		if next_idx != -1 and next_idx < cols.size():
			line_dict["next"] = cols[next_idx].strip_edges()
		else:
			line_dict["next"] = ""
		# choices は JSON 配列文字列として扱う
		if choices_idx != -1 and choices_idx < cols.size():
			var choices_str = cols[choices_idx].strip_edges()
			if not choices_str.is_empty():
				var parsed = JSON.parse_string(choices_str)
				if parsed is Array:
					line_dict["choices"] = parsed
				else:
					line_dict["choices"] = []
			else:
				line_dict["choices"] = []
		else:
			line_dict["choices"] = []
		# effects は JSON オブジェクト文字列として扱う
		if effects_idx != -1 and effects_idx < cols.size():
			var effects_str = cols[effects_idx].strip_edges()
			if not effects_str.is_empty():
				var parsed = JSON.parse_string(effects_str)
				if parsed is Dictionary:
					line_dict["effects"] = parsed
				else:
					line_dict["effects"] = {}
			else:
				line_dict["effects"] = {}
		else:
			line_dict["effects"] = {}
		scenario_lines.append(line_dict)
	var json_data = {
		"title": "CSVから変換",
		"lines": scenario_lines
	}
	var json_string = JSON.stringify(json_data, "\t")
	var out_file = FileAccess.open(JSON_OUTPUT_PATH, FileAccess.WRITE)
	if out_file == null:
		print("出力ファイルを開けません: ", JSON_OUTPUT_PATH)
		return
	out_file.store_string(json_string)
	out_file.close()
	print("変換完了: ", JSON_OUTPUT_PATH)
