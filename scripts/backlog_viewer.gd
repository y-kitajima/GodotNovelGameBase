## 既読の会話を一覧表示するパネルクラス
extends Control
class_name BacklogViewer

## スクロール付きの履歴表示領域
@onready var scroll: ScrollContainer = $ScrollContainer
## 履歴のテキストを追加するためのVBox
@onready var vbox: VBoxContainer = $ScrollContainer/VBoxContainer
## パネルを閉じるボタン
@onready var close_btn: Button = $CloseButton

## 履歴を提供するログマネージャ
var log_manager: LogManager

## 外部からログマネージャを設定します。
func set_log_manager(manager: LogManager) -> void:
	log_manager = manager

## 履歴を再構築して表示します。
func show_log() -> void:
	clear()
	if not log_manager:
		return
	var history = log_manager.get_history()
	for entry in history:
		var speaker_label = Label.new()
		speaker_label.text = entry["speaker"]
		var text_label = Label.new()
		text_label.text = entry["text"]
		text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(speaker_label)
		vbox.add_child(text_label)
	visible = true

## パネルを非表示にします。
func hide_log() -> void:
	visible = false

## 表示中の履歴ラベルをすべて削除します。
func clear() -> void:
	for child in vbox.get_children():
		child.queue_free()

func _ready() -> void:
	close_btn.pressed.connect(hide_log)
