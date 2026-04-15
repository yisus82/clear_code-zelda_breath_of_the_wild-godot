class_name Enemy
extends CharacterBody3D

@onready var player := get_tree().get_first_node_in_group("Player") as CharacterBody3D
@onready var skin := get_node("Skin") as Node3D
@onready var move_state_machine := $AnimationTree.get("parameters/MoveStateMachine/playback") as AnimationNodeStateMachinePlayback
@onready var attack_animation := $AnimationTree.get_tree_root().get_node('AttackAnimation') as AnimationNodeAnimation

@export var walk_speed := 2.0
@export var rotation_speed := 6.0
@export var notice_radius := 20.0
@export var attack_radius := 3.0

var rng = RandomNumberGenerator.new()
var speed_multiplier := 1.0
var speed := walk_speed
var squash_and_stretch_modifier := 1.0:
  set(value):
    squash_and_stretch_modifier = value
    var negative := 1.0 + (1.0 - squash_and_stretch_modifier)
    skin.scale = Vector3(negative, squash_and_stretch_modifier, negative)

func move_toward_player(delta: float) -> void:
  if position.distance_to(player.position) > notice_radius:
    velocity = Vector3.ZERO
    move_state_machine.travel("Idle")
    return
  var target_direction := (player.position - position).normalized()
  var target_vector2d := Vector2(target_direction.x, target_direction.z)
  var target_angle := -target_vector2d.angle() + PI / 2
  rotation.y = rotate_toward(rotation.y, target_angle, delta * rotation_speed)
  if position.distance_to(player.position) > attack_radius:
    velocity = Vector3(target_vector2d.x, velocity.y, target_vector2d.y) * speed * speed_multiplier
    move_state_machine.travel("Walk")
  else:
    velocity = Vector3.ZERO
    move_state_machine.travel("Idle")
  move_and_slide()

func stop_movement(start_duration: float, end_duration: float) -> void:
  var tween := create_tween()
  tween.tween_property(self, "speed_multiplier", 0.0, start_duration)
  tween.tween_property(self, "speed_multiplier", 1.0, end_duration)

func hit() -> void:
  if not $Timers/InvulnerabilityTimer.time_left:
    do_squash_and_stretch()
    $Timers/InvulnerabilityTimer.start()

func do_squash_and_stretch(value: float = 1.2, duration: float = 0.15):
  var tween = create_tween()
  tween.tween_property(self, "squash_and_stretch_modifier", value, duration)
  tween.tween_property(self, "squash_and_stretch_modifier", 1.0, duration * 1.8).set_ease(Tween.EASE_OUT)
