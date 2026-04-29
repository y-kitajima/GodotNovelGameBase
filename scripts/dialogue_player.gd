## 会話の表示（タイピングアニメーション）を管理するクラス
## シナリオの行単位で話者・テキストを表示し、選択肢があれば通知します。
extends Node
class_name DialoguePlayer

#region シグナル
## 新しい行の話者情報が変わったことを通知（引数：speaker）
signal line_changed(speaker: String)
## タイピング途中のテキストが更新されるたびに通知（引数：表示途中の文字列）
signal typing_updated(partial: String)
## 一行のタイピングが完了したことを通知
signal typing_finished
## すべての行の表示が終了したことを通知
signal dialogue_finished
## 選択肢がある場合、その配列を通知
signal choice_required(choices: Array)
## 行に付随するエフェクト情報を通知（引数：effects辞書）
signal effect_required(effects: Dictionary)
#endregion

## 現在再生中のシナリオデータ
var scenario: ScenarioData
## 現在表示している行の情報（id, speaker, text, choices など）
var current_line: Dictionary = {}
## 会話が進行中かどうか
var is_playing: bool = false

## タイピング用のタイマー
var typing_timer: Timer
## 1文字あたりの待ち時間（秒）
var text_speed: float = 0.05
## 現在タイピング中の完全なテキスト
var typing_text: String = ""
## 次に表示する文字のインデックス（0始まり）
var typing_index: int = 0

## ノードがシーンに追加されたときにタイマーを作成・登録します。
func _ready() -> void:
	typing_timer = Timer.new()
	typing_timer.one_shot = false
	typing_timer.timeout.connect(_on_typing_tick)
	add_child(typing_timer)

## シナリオの再生を開始します。
## lines: シナリオデータ（ScenarioData）
## start_id: 開始する行のID。空文字の場合は最初の行から。
## speed: タイピング速度（1文字あたりの秒数）
func start(lines: ScenarioData, start_id: String = "", speed: float = 0.05) -> void:
	text_speed = speed
	scenario = lines
	if not start_id.is_empty():
		current_line = scenario.get_line_by_id(start_id)
	else:
		if scenario.lines.size() > 0:
			current_line = scenario.lines[0]
	is_playing = true
	show_current_line()

## 現在の行を表示します（話者通知、タイピング開始、選択肢通知、エフェクト通知）
func show_current_line() -> void:
	if current_line.is_empty():
		dialogue_finished.emit()
		return
	line_changed.emit(current_line.get("speaker", ""))
	start_typing(current_line.get("text", ""))
	var choices = current_line.get("choices", [])
	if choices.size() > 0:
		choice_required.emit(choices)
	var effects = current_line.get("effects", {})
	if not effects.is_empty():
		effect_required.emit(effects)

## タイピングアニメーションを始めます。
## 速度が0以下の場合は即座に全文を表示します。
func start_typing(text: String) -> void:
	typing_text = text
	typing_index = 0
	if text_speed <= 0:
		typing_index = text.length()
		typing_updated.emit(text)
		typing_finished.emit()
	else:
		typing_timer.start(text_speed)

## タイマーがタイムアウトするたびに1文字ずつ表示を進めます。
func _on_typing_tick() -> void:
	typing_index += 1
	var partial = typing_text.substr(0, typing_index)
	typing_updated.emit(partial)
	if typing_index >= typing_text.length():
		typing_timer.stop()
		typing_finished.emit()

## 次の行へ進みます。
## nextプロパティがあればそれに従い、なければ配列順に移動します。
func advance() -> void:
	if not is_playing:
		return
	typing_timer.stop()
	var next_id = current_line.get("next", "")
	if not next_id.is_empty():
		current_line = scenario.get_line_by_id(next_id)
	else:
		var idx = scenario.lines.find(current_line)
		if idx >= 0 and idx < scenario.lines.size() - 1:
			current_line = scenario.lines[idx + 1]
		else:
			current_line = {}
	show_current_line()

## 指定されたIDの行に直接移動します（選択肢や演出用）。
func jump_to(id: String) -> void:
	if not is_playing:
		return
	typing_timer.stop()
	current_line = scenario.get_line_by_id(id)
	show_current_line()

## 状態をクリアして再生を停止します。
func reset() -> void:
	typing_timer.stop()
	current_line = {}
	scenario = null
	is_playing = false
	typing_text = ""
	typing_index = 0
