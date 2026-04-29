## BGMと効果音の再生を管理する簡易クラス
extends Node
class_name SoundManager

## BGM用のストリームプレイヤー
var bgm_player: AudioStreamPlayer

func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)

## 指定されたAudioStreamでBGMを再生します。
func play_bgm(stream: AudioStream) -> void:
	bgm_player.stream = stream
	bgm_player.play()

## BGMを停止します。
func stop_bgm() -> void:
	bgm_player.stop()

## 指定されたAudioStreamで効果音を再生します（一度きり）。
func play_se(stream: AudioStream) -> void:
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.finished.connect(player.queue_free)
	player.play()
