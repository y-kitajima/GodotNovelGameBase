## JSONファイルからシナリオデータを読み込み、行単位のリストとして保持するクラス
extends Node
class_name ScenarioData

## シナリオの各行データを格納する配列
var lines: Array = []
## シナリオのタイトル（任意）
var title: String = ""

## 指定されたパスのJSONシナリオファイルを読み込み、内部データに変換します。
## 戻り値：成功ならtrue、失敗ならfalse
func load_from_file(path: String) -> bool:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ファイルを開けません: %s" % path)
		return false
	var content = file.get_as_text()
	var json = JSON.parse_string(content)
	if json == null:
		push_error("JSONの解析に失敗しました")
		return false
	title = json.get("title", "")
	var raw_lines = json.get("lines", [])
	lines.clear()
	for line_dict in raw_lines:
		var line = {}
		line["id"] = line_dict.get("id", "")
		line["speaker"] = line_dict.get("speaker", "")
		line["text"] = line_dict.get("text", "")
		line["next"] = line_dict.get("next", "")
		line["choices"] = line_dict.get("choices", [])
		line["effects"] = line_dict.get("effects", {})
		lines.append(line)
	return true

## 指定されたIDの行データを返します。見つからない場合は空の辞書を返します。
func get_line_by_id(id: String) -> Dictionary:
	for line in lines:
		if line["id"] == id:
			return line
	return {}
