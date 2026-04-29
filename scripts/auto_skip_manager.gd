## オート進行とスキップの状態、およびそれに伴うタイマーを管理するクラス
extends Node
class_name AutoSkipManager

## オートモードのON/OFFが切り替わった時に通知するシグナル
signal auto_mode_changed(auto: bool)
## スキップモードのON/OFFが切り替わった時に通知するシグナル
signal skip_mode_changed(skip: bool)
## オートタイマーが切れたことを知らせるシグナル（メイン側で次へ進める）
signal auto_advance_triggered

## 現在オートモードかどうか
var is_auto: bool = false
## 現在スキップモードかどうか
var is_skip: bool = false
## オート用のタイマー
var auto_timer: Timer = Timer.new()
## デフォルトのオート進み間隔（秒）
var default_auto_delay: float = 2.0

## 起動時にタイマーを子ノードとして追加し、シグナルを接続します。
func _ready() -> void:
	add_child(auto_timer)
	auto_timer.one_shot = true
	auto_timer.timeout.connect(_on_auto_timeout)

## オートモードを有効/無効にする。有効時にはタイマーを開始します。
func enable_auto(enable: bool, delay: float = -1.0) -> void:
	is_auto = enable
	if enable:
		start_auto(delay)
	else:
		auto_timer.stop()
	auto_mode_changed.emit(enable)

## スキップモードのON/OFFを設定します。
func enable_skip(enable: bool) -> void:
	is_skip = enable
	skip_mode_changed.emit(enable)

## オートタイマーを開始します（現在オートが有効なら）。
func start_auto(delay: float = -1.0) -> void:
	if not is_auto:
		return
	var d = delay if delay > 0 else default_auto_delay
	auto_timer.stop()
	auto_timer.start(d)

## タイマーが満了した際の処理。シグナルを送出し、再度タイマーをスタートします。
func _on_auto_timeout() -> void:
	if is_auto:
		auto_advance_triggered.emit()
		if is_auto:
			start_auto()
