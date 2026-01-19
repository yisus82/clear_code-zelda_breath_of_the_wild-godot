extends Node3D

@export var min_limit_x := -0.8
@export var max_limit_x := -0.2
@export var horizontal_acceleration := 2.0
@export var vertical_acceleration := 1.0
@export var mouse_acceleration := 0.005

func _process(delta: float) -> void:
  var joystick_input := Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
  rotate_from_vector(joystick_input * Vector2(horizontal_acceleration, vertical_acceleration) * delta)

func _input(event: InputEvent) -> void:
  if event is InputEventMouseMotion:
    rotate_from_vector(event.relative * mouse_acceleration)

func rotate_from_vector(v: Vector2) -> void:
  if v.length() == 0:
    return
  rotation.y -= v.x
  rotation.x = rotation.x - v.y
  rotation.x = clamp(rotation.x, min_limit_x, max_limit_x)
