extends StaticBody2D

@export var extra_width: float = 300.0
@export var grow_speed: float = 200.0
@export var auto_start: bool = true
@export var start_delay: float = 1.5

@export var direction: int = 1

@onready var col: CollisionShape2D = $CollisionShape2D
@onready var rect: RectangleShape2D = col.shape as RectangleShape2D
@onready var visual: ColorRect = $ColorRect
@onready var delay_timer: Timer = $Timer


var base_width: float
var target_width: float
var base_col_x: float
var growing: bool = false

func _ready() -> void:
	if rect == null:
		push_error("CollisionShape2D must use a RectangleShape2D.")
		set_physics_process(false)
		return

	direction = 1 if direction >= 0 else -1

	base_width = rect.size.x
	target_width = base_width + max(extra_width, 0.0)
	base_col_x = col.position.x

	_sync_visual(rect.size.x)

	if auto_start:
		delay_timer.start(start_delay)

func start_growing() -> void:
	growing = true

func stop_growing() -> void:
	growing = false

func reset_size() -> void:
	rect.size.x = base_width
	col.position.x = base_col_x
	_sync_visual(base_width)

func _physics_process(delta: float) -> void:
	if not growing:
		return

	var new_w : float = min(rect.size.x + grow_speed * delta, target_width)
	if is_equal_approx(new_w, rect.size.x):
		return

	rect.size.x = new_w

	col.position.x = base_col_x + direction * (new_w - base_width) / 2.0

	_sync_visual(new_w)

func _sync_visual(current_width: float) -> void:
	visual.size.x = current_width
	visual.position.x = -current_width / 2.0 + (col.position.x - base_col_x)


func _on_start_delay_timer_timeout() -> void:
	growing = true
