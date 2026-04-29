## このクラスはビジュアルノベル全体の進行を管理します。
## UIボタン（次へ、オート、スキップ、ログ表示、設定）の操作を受け付け、
## シナリオデータの読み込みや表示、およびログへの記録を連携させます。
## 選択肢がある場合は選択ボタンを表示し、プレイヤーの選択に応じて分岐します。

extends Node

## シナリオデータを保持するノード
@onready var scenario_data: ScenarioData = $ScenarioData
## セリフ表示（タイピング）を制御するノード
@onready var dialogue_player: DialoguePlayer = $DialoguePlayer
## オート・スキップの状態とタイマーを管理するノード
@onready var auto_skip: AutoSkipManager = $AutoSkipManager
## 表示済みテキストを保存するログ管理ノード
@onready var log_manager: LogManager = $LogManager
## 設定値（テキスト速度など）を持つノード
@onready var config: Config = $Config
## 選択肢を表示するノード
@onready var choice_manager: ChoiceManager = $ChoiceManager
## バックログ表示パネル
@onready var backlog_viewer: BacklogViewer = $BacklogViewer
## 設定画面パネル
@onready var config_menu: ConfigMenu = $ConfigMenu
## サウンド管理ノード
@onready var sound_manager: SoundManager = $SoundManager
## 演出・アニメーション管理ノード
@onready var effect_manager: EffectManager = $EffectManager

## 話者名を表示するラベル
@onready var speaker_label: Label = $UI/SpeakerLabel
## 会話テキストを表示するラベル
@onready var dialogue_text_label: Label = $UI/DialogueTextLabel

## UIの「ログ」ボタン
@onready var backlog_button: Button = $UI/HBoxContainer/BacklogButton
## UIの「設定」ボタン
@onready var config_button: Button = $UI/HBoxContainer/ConfigButton
## 選択肢用のコンテナ（メイン側で選択肢管理ノードに渡す）
@onready var choice_container: VBoxContainer = $UI/ChoiceContainer


## シーンの準備処理
## UIボタンのシグナルを接続し、シナリオJSONを読み込んで再生を開始します。
func _ready() -> void:
	dialogue_player.line_changed.connect(_on_line_changed)
	dialogue_player.typing_updated.connect(_on_typing_updated)
	dialogue_player.typing_finished.connect(_on_typing_finished)
	dialogue_player.dialogue_finished.connect(_on_dialogue_finished)
	dialogue_player.choice_required.connect(_on_choice_required)
	dialogue_player.effect_required.connect(effect_manager.apply_effects)
	auto_skip.auto_advance_triggered.connect(_on_auto_advance)
	choice_manager.choice_selected.connect(_on_choice_selected)

	# UIボタン
	$UI/VBoxContainer/NextButton.pressed.connect(_on_next_pressed)
	$UI/VBoxContainer/AutoButton.toggled.connect(_on_auto_toggled)
	$UI/VBoxContainer/SkipButton.toggled.connect(_on_skip_toggled)
	backlog_button.pressed.connect(_on_backlog_pressed)
	config_button.pressed.connect(_on_config_pressed)

	# 各マネージャーへの参照設定
	choice_manager.set_container(choice_container)
	backlog_viewer.set_log_manager(log_manager)
	config_menu.set_config(config)

	var path = "res://scenario.json"
	if not scenario_data.load_from_file(path):
		push_error("シナリオの読み込みに失敗しました")
		return

	dialogue_player.start(scenario_data, "", config.text_speed)

## 行が切り替わったときの処理
## 話者ラベルを更新し、スキップ中であれば即座に次へ進めます。
func _on_line_changed(speaker: String) -> void:
	speaker_label.text = speaker if not speaker.is_empty() else "???"
	if auto_skip.is_skip:
		call_deferred("advance_dialogue")

## タイピング表示が更新されるたびに呼ばれ、表示テキストを書き換えます。
func _on_typing_updated(partial: String) -> void:
	dialogue_text_label.text = partial

## 一行の表示が完了したときの処理
## ログに記録し、オートモードであれば次へのタイマーを開始します。
func _on_typing_finished() -> void:
	var speaker = speaker_label.text
	var text = dialogue_text_label.text
	log_manager.add_entry(speaker, text)
	if auto_skip.is_auto:
		auto_skip.start_auto()

## すべてのセリフが終了したときの処理
func _on_dialogue_finished() -> void:
	dialogue_text_label.text = "会話終了"
	speaker_label.text = ""

## 選択肢が必要になったときの処理
func _on_choice_required(choices: Array) -> void:
	choice_manager.show_choices(choices)

## プレイヤーが選択肢を選んだときの処理
## 指定されたIDの行にジャンプします。
func _on_choice_selected(choice_id: String) -> void:
	choice_manager.hide_choices()
	dialogue_player.jump_to(choice_id)

## オートタイマーが発火したときに呼ばれ、次のセリフに進みます。
func _on_auto_advance() -> void:
	if dialogue_player.is_playing:
		advance_dialogue()

## 次のセリフへ移動する共通処理（ボタン押下・オートから利用）
func advance_dialogue() -> void:
	dialogue_player.advance()

## 「次へ」ボタンが押されたときの処理
func _on_next_pressed() -> void:
	if dialogue_player.is_playing:
		advance_dialogue()

## オートボタンのON/OFF切り替え
func _on_auto_toggled(button_pressed: bool) -> void:
	auto_skip.enable_auto(button_pressed)
	if button_pressed:
		# オートがONになったらスキップはOFFにする（排他制御）
		$UI/VBoxContainer/SkipButton.button_pressed = false
		auto_skip.enable_skip(false)

## スキップボタンのON/OFF切り替え
func _on_skip_toggled(button_pressed: bool) -> void:
	auto_skip.enable_skip(button_pressed)
	if button_pressed:
		# スキップがONになったらオートはOFFにする
		$UI/VBoxContainer/AutoButton.button_pressed = false
		auto_skip.enable_auto(false)

## ログボタンが押されたときの処理（バックログ表示）
func _on_backlog_pressed() -> void:
	if backlog_viewer.visible:
		backlog_viewer.hide_log()
	else:
		backlog_viewer.show_log()

## 設定ボタンが押されたときの処理
func _on_config_pressed() -> void:
	if config_menu.visible:
		config_menu.visible = false
	else:
		config_menu.show_menu()
