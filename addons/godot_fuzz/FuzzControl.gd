extends CanvasLayer

var fuzz_peer: FuzzMultiplayerPeer = null
var is_active = false

@onready var status_label = $Panel/VBoxContainer/StatusLabel
@onready var prob_label = $Panel/VBoxContainer/ProbabilityLabel

func _ready():
	# Attempt to hook into existing multiplayer peer
	call_deferred("_hook_multiplayer")

func _hook_multiplayer():
	var current_peer = multiplayer.multiplayer_peer
	
	if current_peer and current_peer is FuzzMultiplayerPeer:
		fuzz_peer = current_peer
		status_label.text = "Status: Fuzzer Active"
		is_active = true
		return

	if current_peer and not (current_peer is OfflineMultiplayerPeer):
		print("Found existing peer: ", current_peer)
		# Create Fuzz Wrapper
		fuzz_peer = FuzzMultiplayerPeer.new()
		fuzz_peer.set_base_peer(current_peer)
		
		# Replace the peer on the multiplayer API
		multiplayer.multiplayer_peer = fuzz_peer
		
		status_label.text = "Status: Hooked & Ready"
		is_active = true
		print("FuzzMultiplayerPeer successfully hooked!")
	else:
		status_label.text = "Status: No Peer Found"
		# Retry in a bit if networking starts later
		get_tree().create_timer(1.0).timeout.connect(_hook_multiplayer)

func _on_enable_fuzzing_toggled(toggled_on):
	if is_active and fuzz_peer:
		fuzz_peer.set_fuzzing_enabled(toggled_on)
		if toggled_on:
			status_label.text = "Status: FUZZING..."
		else:
			status_label.text = "Status: Idle"

func _on_probability_slider_value_changed(value):
	prob_label.text = "Fuzz Probability: " + str(value)
	# Assuming we exposed this property in C++, currently hardcoded in C++
	# We might need to add set_fuzz_probability in C++ to make this work dynamically
	# For now, it's just visual unless we update the C++ class.
	# TODO: Add set_fuzz_probability to FuzzMultiplayerPeer class
	pass

func _on_enable_buffering_toggled(toggled_on):
	if is_active and fuzz_peer:
		fuzz_peer.set_buffering_enabled(toggled_on)

func _on_flush_buffer_pressed():
	if is_active and fuzz_peer:
		fuzz_peer.flush_buffer()
