extends Node3D

@onready var move_state_machine := $AnimationTree.get("parameters/MoveStateMachine/playback") as AnimationNodeStateMachinePlayback
@onready var attack_state_machine := $AnimationTree.get("parameters/AttackStateMachine/playback") as AnimationNodeStateMachinePlayback
@onready var extra_animation := $AnimationTree.get_tree_root().get_node("ExtraAnimation") as AnimationNodeAnimation
@onready var face_material := $Rig/Skeleton3D/Godette_Head.get_surface_override_material(0) as StandardMaterial3D

const faces := {
  "default": Vector3.ZERO,
  "blink": Vector3(0, 0.5, 0),
}

var is_attacking := false
var squash_and_stretch_modifier := 1.0:
  set(value):
    squash_and_stretch_modifier = value
    var negative := 1.0 + (1.0 - squash_and_stretch_modifier)
    scale = Vector3(negative, squash_and_stretch_modifier, negative)
var rng := RandomNumberGenerator.new()

func set_move_state(state: String) -> void:
  move_state_machine.travel(state)

func attack() -> void:
  if is_attacking:
    return
  attack_state_machine.travel("Slice" if $SecondAttackTimer.time_left > 0.0 else "Chop")
  $AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func toggle_attack(value: bool) -> void:
  is_attacking = value

func defend() -> void:
  var tween := create_tween()
  tween.tween_method(defend_change, 0.0, 1.0, 0.25)

func undefend() -> void:
  var tween := create_tween()
  tween.tween_method(defend_change, 1.0, 0.0, 0.25)

func defend_change(value: float) -> void:
  $AnimationTree.set("parameters/ShieldBlend/blend_amount", value)

func toggle_weapon(weapon_active: bool) -> void:
  if weapon_active:
    $Rig/Skeleton3D/RightHandSlot/Sword.show()
    $Rig/Skeleton3D/RightHandSlot/Wand.hide()
  else:
    $Rig/Skeleton3D/RightHandSlot/Sword.hide()
    $Rig/Skeleton3D/RightHandSlot/Wand.show()

func cast_spell() -> void:
  if is_attacking:
    return
  extra_animation.animation = "Spellcast_Shoot"
  $AnimationTree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func hit() -> void:
  extra_animation.animation = "Hit_A"
  $AnimationTree.set("parameters/ExtraOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
  $AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
  is_attacking = false

func change_face(expression: String) -> void:
  face_material.uv1_offset = faces[expression]


func _on_blink_timer_timeout() -> void:
  change_face("blink")
  await get_tree().create_timer(0.2).timeout
  change_face("default")
  $BlinkTimer.wait_time = rng.randf_range(1.5, 3.0)
