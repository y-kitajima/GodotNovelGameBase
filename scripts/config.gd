## ユーザー設定（テキスト速度、オート待ち時間、音量など）を保持するクラス
extends Node
class_name Config

## 1文字あたりの表示間隔（秒）
var text_speed: float = 0.05
## オートモードで次の行に進むまでの待ち時間（秒）
var auto_delay: float = 2.0
## マスターボリューム（0.0～1.0）
var volume_master: float = 1.0
