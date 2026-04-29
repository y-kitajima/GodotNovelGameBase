## テキスト速度や音量などを変更する設定パネルクラス
extends Control
class_name ConfigMenu

## テキスト速度スライダー
@onready var text_speed_slider: HSlider = $VBoxContainer/TextSpeedSlider
## オートディレイスライダー
@onready var auto_delay_slider: HSlider = $VBoxContainer/AutoDelaySlider
## 音量スライダー
@onready var volume_slider: HSlider = $VBoxContainer/VolumeSlider
## 適用ボタン
@onready var apply_btn: Button = $VBoxContainer/ApplyButton
## 閉じるボタン
@onready var close_btn: Button = $CloseButton

## 設定値を保持するConfigノード
var config: Config

## 外部からConfigを設定します。
func set_config(cfg: Config) -> void:
	config = cfg

## パネルを表示し、スライダーを現在の設定に合わせます。
func show_menu() -> void:
	if config:
		text_speed_slider.value = config.text_speed * 100.0
		auto_delay_slider.value = config.auto_delay
		volume_slider.value = config.volume_master * 100.0
	visible = true

func _ready() -> void:
	apply_btn.pressed.connect(_on_apply)
	close_btn.pressed.connect(_on_close)

## 適用ボタン押下でConfigに値を書き込み、パネルを閉じます。
func _on_apply() -> void:
	if not config:
		return
	config.text_speed = text_speed_slider.value / 100.0
	config.auto_delay = auto_delay_slider.value
	config.volume_master = volume_slider.value / 100.0
	visible = false

## 閉じるボタン押下でパネルを閉じます（変更は破棄されます）。
func _on_close() -> void:
	visible = false
