extends LockableObject
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _on_lock_opened():
	print("Lock successfully picked! Opening " + object_name)
	is_locked = false
	hide_lock_view()
	audio_stream_player.play()
	_trigger_unlock_behavior()
