extends CharacterBody2D

@export var speed: float = 200.0
@export var start_angle_deg: float = 45.0
@export var can_move: bool = true
@export var square_size: Vector2 = Vector2(24, 24)
@export var color_rect_path: NodePath

@onready var audio = $AudioStreamPlayer2D

var vel: Vector2
var rect: ColorRect

func _ready() -> void:
	# Find the ColorRect
	if color_rect_path != NodePath():
		rect = get_node_or_null(color_rect_path) as ColorRect
	else:
		rect = _find_first_color_rect(self)

	if rect == null:
		push_error("%s: No ColorRect found. Add one as a child." % name)
		return

	# Movement
	vel = Vector2.RIGHT.rotated(deg_to_rad(start_angle_deg)).normalized() * speed


func set_color(c: Color) -> void:
	if rect != null:
		rect.color = c
		rect.visible = true


func _physics_process(delta: float) -> void:
	if not can_move:
		return

	var collision := move_and_collide(vel * delta)
	if collision:
		vel = vel.bounce(collision.get_normal())
		position += collision.get_normal() * 0.05
		audio.play()


func _find_first_color_rect(n: Node) -> ColorRect:
	for child in n.get_children():
		if child is ColorRect:
			return child
		var found := _find_first_color_rect(child)
		if found != null:
			return found
	return null
