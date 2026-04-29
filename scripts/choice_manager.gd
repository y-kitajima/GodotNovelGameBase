## 選択肢を表示し、プレイヤーの選択に応じて次のIDをメイン側に伝えるクラス
extends Node
class_name ChoiceManager

## 選択肢が選ばれたときに通知（引数：次に進むID）
signal choice_selected(next_id: String)

## 選択肢ボタンを配置するコンテナ
var container: VBoxContainer
## 現在表示中のボタン一覧
var choice_buttons: Array = []

## 外部から選択肢表示用のコンテナを設定します。
func set_container(node: VBoxContainer) -> void:
	container = node

## 選択肢の一覧を受け取って表示します。
## choices は [{"text": "...", "next": "..."}] の形式の配列です。
func show_choices(choices: Array) -> void:
	clear_buttons()
	if not container:
		return
	for choice in choices:
		var btn = Button.new()
		btn.text = choice.get("text", "")
		var next_id = choice.get("next", "")
		btn.pressed.connect(_on_choice_pressed.bind(next_id))
		container.add_child(btn)
		choice_buttons.append(btn)
	container.visible = true

## 選択肢を非表示にします。
func hide_choices() -> void:
	clear_buttons()
	if container:
		container.visible = false

## 表示中のボタンをすべて削除します。
func clear_buttons() -> void:
	for btn in choice_buttons:
		if is_instance_valid(btn):
			btn.queue_free()
	choice_buttons.clear()

## ボタンが押されたときの内部処理
func _on_choice_pressed(next_id: String) -> void:
	choice_selected.emit(next_id)
