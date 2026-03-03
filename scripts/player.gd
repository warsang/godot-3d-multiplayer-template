class_name Player extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var _player_input : PlayerInput
@export var _camera_input : Node3D # Generic Node3D to avoid cyclic dependency issues
@export var _player_model : Node3D

var _animation_player: AnimationPlayer

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	if _player_input:
		_player_input.set_multiplayer_authority(str(name).to_int())
	if _camera_input:
		_camera_input.set_multiplayer_authority(str(name).to_int())

func _ready():
	if _player_model:
		_animation_player = _player_model.get_node_or_null("AnimationPlayer")
	
	# Hide loading screen if we are the local player
	if is_multiplayer_authority() and multiplayer.get_unique_id() == str(name).to_int():
		# Assuming NetworkManager exists and has this method
		if NetworkManager.has_method("hide_loading"):
			NetworkManager.hide_loading()
		
		# Setup camera if it's ours
		var cam = _camera_input.get_node_or_null("Camera3D")
		if cam:
			cam.current = true

func _physics_process(delta):
	if not is_multiplayer_authority():
		return

	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump
	if _player_input and _player_input.jump_input and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration
	var input_dir = Vector2.ZERO
	if _player_input:
		input_dir = _player_input.input_dir
	
	var direction = Vector3.ZERO
	if _camera_input:
		# Use camera basis to align movement
		var cam_basis = _camera_input.global_transform.basis
		direction = (cam_basis * Vector3(input_dir.x, 0, input_dir.y))
		direction.y = 0
		direction = direction.normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# Simple visual rotation
		if _player_model:
			var target_look = position + direction
			_player_model.look_at(Vector3(target_look.x, _player_model.global_position.y, target_look.z), Vector3.UP)
			
		if _animation_player:
			if is_on_floor():
				_animation_player.play("male_animation_lib/walk")
			else:
				_animation_player.play("male_animation_lib/jump")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if _animation_player and is_on_floor():
			_animation_player.play("male_animation_lib/idle")

	move_and_slide()
