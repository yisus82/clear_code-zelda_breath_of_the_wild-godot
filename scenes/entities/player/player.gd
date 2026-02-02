extends CharacterBody3D

# jump
@export var jump_height := 2.25
@export var jump_time_to_peak := 0.4
@export var jump_time_to_descent := 0.3

@onready var jump_velocity := ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity := ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity := ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
# source: https://youtu.be/IOe1aGY6hXA

@export var base_speed := 4.0
@export var run_speed := 6.0
@export var defend_speed := 2.0

@onready var camera := $CameraController/Camera3D
@onready var skin := $GodetteSkin

var movement_input := Vector2.ZERO
var defend := false:
	set(value):
		if defend == value:
			return
		defend = value
		if defend:
			skin.defend()
		else:
			skin.undefend()
var is_weapon_active := true
var speed_multiplier := 1.0
var velocity_delta_multiplier := 4.0
var rotation_delta_multiplier := 6.0

func _physics_process(delta: float) -> void:
	move_logic(delta)
	jump_logic(delta)
	ability_logic()
	if Input.is_action_just_pressed("ui_accept"):
		hit()
	move_and_slide()

func move_logic(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)
	var velocity_2d := Vector2(velocity.x, velocity.z)
	var is_running := Input.is_action_pressed("run")
	var is_defending := Input.is_action_pressed("block")
	if movement_input != Vector2.ZERO:
		var speed := defend_speed if is_defending else (run_speed if is_running else base_speed)
		velocity_2d += movement_input * speed * delta * velocity_delta_multiplier * 2.0
		velocity_2d = velocity_2d.limit_length(speed) * speed_multiplier
		if is_running:
			skin.set_move_state("Run")
		else:
			skin.set_move_state("Walk")
		var target_angle := -movement_input.angle() + PI / 2
		skin.rotation.y = rotate_toward(skin.rotation.y, target_angle, delta * rotation_delta_multiplier)
	else:
		velocity_2d = velocity_2d.move_toward(Vector2.ZERO, base_speed * delta * velocity_delta_multiplier)
		skin.set_move_state("Idle")
	velocity.x = velocity_2d.x
	velocity.z = velocity_2d.y

func jump_logic(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_velocity
			do_squash_and_stretch()
	else:
		var gravity := jump_gravity if velocity.y > 0.0 else fall_gravity
		velocity.y -= gravity * delta
	if velocity.y != 0.0:
		skin.set_move_state("Jump")

func ability_logic() -> void:
	if Input.is_action_just_pressed("ability"):
		if is_weapon_active:
			skin.attack()
		else:
			skin.cast_spell()
			stop_movement()

	defend = Input.is_action_pressed("block")

	if Input.is_action_just_pressed("switch weapon") and not skin.is_attacking:
		is_weapon_active = not is_weapon_active
		skin.toggle_weapon(is_weapon_active)
		do_squash_and_stretch()

func stop_movement(start_duration: float = 0.3, end_duration: float = 0.8) -> void:
	var tween := create_tween()
	tween.tween_property(self, "speed_multiplier", 0.0, start_duration)
	tween.tween_property(self, "speed_multiplier", 1.0, end_duration)

func hit() -> void:
	skin.hit()
	stop_movement(0.3, 0.3)

func do_squash_and_stretch(value: float = 1.2, duration: float = 0.1):
	var tween = create_tween()
	tween.tween_property(skin, "squash_and_stretch_modifier", value, duration)
	tween.tween_property(skin, "squash_and_stretch_modifier", 1.0, duration * 1.8).set_ease(Tween.EASE_OUT)
