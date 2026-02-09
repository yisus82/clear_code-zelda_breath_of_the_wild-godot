extends Enemy

@export var melee_distance := 5.0
@export var range_distance := 10.0
@export var spin_speed := 6.0

var is_spinning := false

func _physics_process(delta: float) -> void:
  move_toward_player(delta)
  if position.distance_to(player.position) > notice_radius:
    if is_spinning:
      stop_spinning()

func _on_attack_timer_timeout() -> void:
  if position.distance_to(player.position) > notice_radius:
     return
  $Timers/AttackTimer.wait_time = rng.randf_range(4.0, 5.5)
  if position.distance_to(player.position) <= melee_distance:
    melee_attack()
  elif position.distance_to(player.position) <= range_distance:
    range_attack()
  elif randi() % 2 == 0:
    spin_attack()

func melee_attack() -> void:
  attack_animation.animation = "2H_Melee_Attack_Slice" if rng.randi() % 2 == 0 else "2H_Melee_Attack_Spin"
  $AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func range_attack() -> void:
  stop_movement(1.5, 1.5)
  attack_animation.animation = "1H_Melee_Attack_Stab"
  $AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func spin_attack() -> void:
  var tween = create_tween()
  tween.tween_property(self, "speed", spin_speed, 0.5)
  tween.tween_method(spin_transition, 0.0, 1.0, 0.3)
  $Timers/AttackTimer.stop()
  is_spinning = true

func spin_transition(value: float) -> void:
  $AnimationTree.set("parameters/SpinBlend/blend_amount", value)

func _on_area_3d_body_entered(_body: Node3D) -> void:
  if is_spinning:
    stop_spinning()

func stop_spinning() -> void:
  await get_tree().create_timer(rng.randf_range(1.0, 2.0)).timeout
  var tween = create_tween()
  tween.tween_property(self, "speed", walk_speed, 0.5)
  tween.tween_method(spin_transition, 1.0, 0.0, 0.3)
  is_spinning = false
  $Timers/AttackTimer.start()
