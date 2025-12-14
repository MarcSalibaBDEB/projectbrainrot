extends Node2D

@export var player_scene: PackedScene

var race_over := false
var players: Array[CharacterBody2D] = []

# Colors for racers
var player_colors := [
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.YELLOW
]

# Different launch angles
var start_angles := [25.0, 55.0, 125.0, 200.0]

# Spawn positions (adjust to your start area)
var spawn_positions := [
	Vector2(130, 380),
	Vector2(170, 380),
	Vector2(130, 480),
	Vector2(170, 480)
]

func _ready() -> void:
	if player_scene == null:
		push_error("Main: player_scene is NULL. Drag PlayerSquare.tscn into the player_scene export field.")
		return

	spawn_players()


func spawn_players() -> void:
	for i in range(4):
		var p := player_scene.instantiate()
		p.name = "PlayerSquare%d" % (i + 1)

		add_child(p) # ✅ IMPORTANT: _ready runs after this

		p.position = spawn_positions[i]
		p.start_angle_deg = start_angles[i]
		p.can_move = true
		p.speed = 260.0

		p.set_color(player_colors[i]) # ✅ now rect exists
		players.append(p)


func _on_finish_body_entered(body: Node2D) -> void:
	if race_over:
		return

	if body is CharacterBody2D:
		race_over = true
		print(body.name, " WINS!")

		for p in players:
			if is_instance_valid(p):
				p.can_move = false
