extends Enemy

@export var melee_distance := 2.0

func _ready() -> void:
  attack_radius = 1.5
  notice_radius = 15.0

func _physics_process(delta: float) -> void:
  move_toward_player(delta)

func _on_attack_timer_timeout() -> void:
  if position.distance_to(player.position) > notice_radius:
     return
  $Timers/AttackTimer.wait_time = rng.randf_range(2.5, 3.5)
  if position.distance_to(player.position) <= melee_distance:
    $AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
