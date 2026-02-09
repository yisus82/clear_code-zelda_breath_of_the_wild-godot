extends Enemy

@export var range_distance := 15.0

func _ready() -> void:
  attack_radius = 10
  notice_radius = 15.0

func _physics_process(delta: float) -> void:
  move_toward_player(delta)

func _on_attack_timer_timeout() -> void:
  if position.distance_to(player.position) > notice_radius:
     return
  $Timers/AttackTimer.wait_time = rng.randf_range(2.0, 3.0)
  if position.distance_to(player.position) <= range_distance:
    $AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
