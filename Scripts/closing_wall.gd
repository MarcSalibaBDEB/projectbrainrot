extends AnimatableBody2D

@export var extra_width: float = 300.0
@export var grow_speed: float = 200.0
@export var auto_start: bool = true
@export var start_delay: float = 1.5
@export var direction: int = 1

@onready var col: CollisionShape2D = $CollisionShape2D
@onready var visual: ColorRect = $ColorRect
@onready var delay_timer: Timer = $Timer

# IMPORTANT: ne pas faire @onready var rect := col.shape...
# On le crée dans _ready() après duplication pour éviter la shape partagée.
var rect: RectangleShape2D

var base_width: float
var target_width: float
var base_col_x: float
var growing: bool = false

# Cache pour le visuel (mis à jour en physics, appliqué en render)
var _vis_w: float = 0.0
var _vis_offset_x: float = 0.0
var _vis_dirty: bool = false

func _ready() -> void:
	# 1) Récupère la shape
	rect = col.shape as RectangleShape2D
	if rect == null:
		push_error("CollisionShape2D must use a RectangleShape2D.")
		set_physics_process(false)
		return

	# 2) FORCE une shape unique par instance (corrige le bug des 2 murs qui se sync)
	var unique_shape := rect.duplicate(true) as RectangleShape2D
	col.shape = unique_shape
	rect = unique_shape

	# (Debug optionnel)
	# print(name, " shape_id=", rect.get_instance_id())

	# Direction clean (-1 ou 1)
	direction = 1 if direction >= 0 else -1

	base_width = rect.size.x
	target_width = base_width + (extra_width if extra_width > 0.0 else 0.0)
	base_col_x = col.position.x

	# init cache visuel
	_vis_w = rect.size.x
	_vis_offset_x = col.position.x - base_col_x
	_vis_dirty = true

	# Connect timer safely (no editor dependency)
	delay_timer.one_shot = true
	if not delay_timer.timeout.is_connected(_on_delay_timeout):
		delay_timer.timeout.connect(_on_delay_timeout)

	if auto_start:
		delay_timer.start(start_delay)

func _physics_process(delta: float) -> void:
	if not growing:
		return

	var new_w: float = min(rect.size.x + grow_speed * delta, target_width)
	if is_equal_approx(new_w, rect.size.x):
		return

	# Physics: update collision
	rect.size.x = new_w
	col.position.x = base_col_x + direction * (new_w - base_width) / 2.0

	# Cache values for UI update in _process (ColorRect = UI)
	_vis_w = new_w
	_vis_offset_x = (col.position.x - base_col_x)
	_vis_dirty = true

func _process(_delta: float) -> void:
	if not _vis_dirty:
		return
	_vis_dirty = false

	# Render/UI: update ColorRect here to avoid “lag”
	visual.size.x = _vis_w
	visual.position.x = -_vis_w / 2.0 + _vis_offset_x
	visual.queue_redraw()

func _on_delay_timeout() -> void:
	growing = true
