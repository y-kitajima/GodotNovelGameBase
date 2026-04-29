## 演出・エフェクトと画面アニメーションを管理するクラス
## 背景変更、キャラクター表示、フェード、シェイクなどを処理します。
extends Node
class_name EffectManager

## 背景スプライト
@onready var bg_sprite: Sprite2D = get_node("../BackgroundLayer/BackgroundSprite")
## キャラクター立ち絵スプライト
@onready var char_sprite: Sprite2D = get_node("../BackgroundLayer/CharacterSprite")
## フェード用オーバーレイ
@onready var fade_overlay: ColorRect = get_node("../UI/FadeOverlay")
## 現在の演出用ツイーン
var tween: Tween

## 行に付随するエフェクト辞書を適用します。
func apply_effects(effects: Dictionary) -> void:
	if effects.is_empty():
		return
	# 背景変更
	if effects.has("bg"):
		var texture = load(effects["bg"])
		if texture is Texture2D:
			bg_sprite.texture = texture
			if effects.get("bg_fade", 0.5) > 0:
				fade_in_bg(effects["bg_fade"])
	# キャラクター変更
	if effects.has("char"):
		var texture = load(effects["char"])
		if texture:
			char_sprite.texture = texture
	if effects.has("char_position"):
		var pos = effects["char_position"]
		if pos is Dictionary and pos.has("x") and pos.has("y"):
			char_sprite.position = Vector2(pos["x"], pos["y"])
		elif pos is Array and pos.size() == 2 and typeof(pos[0]) in [TYPE_FLOAT, TYPE_INT] and typeof(pos[1]) in [TYPE_FLOAT, TYPE_INT]:
			char_sprite.position = Vector2(pos[0], pos[1])
		else:
			char_sprite.position = Vector2.ZERO
	# トランジション演出
	if effects.has("transition"):
		play_transition(effects["transition"])
	# シェイク演出
	if effects.has("shake"):
		shake_camera(effects["shake"])

## 背景をフェードインさせます。
func fade_in_bg(duration: float) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	bg_sprite.modulate.a = 0.0
	tween.tween_property(bg_sprite, "modulate:a", 1.0, duration)

## 画面トランジション（フェードなど）を再生します。
func play_transition(type: String) -> void:
	if type == "fade":
		fade_overlay.visible = true
		if tween:
			tween.kill()
		var tw = create_tween()
		tw.tween_property(fade_overlay, "modulate:a", 1.0, 0.3)
		tw.tween_callback(func():
			fade_overlay.modulate.a = 0.0
			fade_overlay.visible = false)

## カメラを揺らす演出を行います。
func shake_camera(intensity: float = 5.0) -> void:
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	var orig_offset = camera.offset
	if tween:
		tween.kill()
	tween = create_tween()
	var shake_count: int = 10
	for i in range(shake_count):
		var t = float(i) / float(shake_count)
		tween.tween_callback(func():
			camera.offset.x = sin(t * 20) * intensity * randf()
			camera.offset.y = cos(t * 20) * intensity * randf()
		)
		tween.tween_interval(0.05)
	tween.tween_callback(func():
		camera.offset = orig_offset
	)
