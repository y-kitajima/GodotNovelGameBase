## 表示済みの会話エントリを保存するクラス
extends Node
class_name LogManager

## 会話履歴の配列。各要素は {"speaker": String, "text": String}
var history: Array = []

## 話者とテキストのペアを履歴に追加します。
func add_entry(speaker: String, text: String) -> void:
	history.append({"speaker": speaker, "text": text})

## 全履歴をコピーして返します。
func get_history() -> Array:
	return history.duplicate()

## 履歴をすべて消去します。
func clear_history() -> void:
	history.clear()
