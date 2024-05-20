extends CharacterBody2D

const SPEED = 200.0
var health = 100
var max_health = 100
var canon
var shoot_timer = 0.0
var shoot_interval = 1.0 
var direction_change_timer = 0.0
var direction_change_interval = randf_range(1, 3)

var direction = Vector2.ZERO
var screen_size 
var random_direction = Vector2()
var lerp_speed = 0.05
var player_position = Vector2()

func _process(_delta):
	var new_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	random_direction = random_direction.lerp(new_direction, lerp_speed)

func _ready():
	canon = $Canon
	z_index = 1
	screen_size = get_viewport().size  # Get the screen size
	random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	set_process(true)

func _physics_process(delta):

	# Get the input direction and handle the movement/deceleration.
	direction_change_timer += delta
	if direction_change_timer >= direction_change_interval:
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))  # Change direction
		direction_change_timer = 0.0  # Reset timer
		direction_change_interval = randf_range(1, 3)  # Choose new interval

	velocity = direction * SPEED
	rotation = atan2(velocity.y, velocity.x)

	# Check if the new position would be outside the screen bounds
	var new_position = position + velocity * delta
	if new_position.x < 0 or new_position.x > screen_size.x or new_position.y < 0 or new_position.y > screen_size.y:
		direction = -direction

	move_and_slide()

	# Rotate the canon towards a random direction
	player_position = get_parent().get_node("PlayerTank").global_position
	canon.look_at(player_position)
	canon.rotation -= PI/2 # Adjust the canon rotation

	# Handle shooting
	shoot_timer += delta
	if shoot_timer >= shoot_interval:
		shoot_timer = 0.0
		_input_event(null, null, 0)


func _input_event(_viewport: Viewport, _event: InputEvent, _shape_idx: int):
	var projectile_scene = preload("res://scenes/projectile.tscn")
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		
		var dir = player_position - canon.global_position
		projectile.set_direction(dir)

		var tank_size = $tank.texture.get_size() * $tank.scale
		var start_position = canon.global_position + dir.normalized() * tank_size.length() / 2.2
		projectile.global_position = start_position

		get_parent().add_child(projectile)


func take_damage(amount):
	health -= amount
	update_health(health)
	if health <= 0:
		call_deferred("change_scene")
		
func change_scene():
	get_tree().change_scene_to_file("res://scenes/you_won.tscn")

func update_health(new_health):
	$HealthBarCanvasLayer/HealthBar.value = new_health
	$HealthBarCanvasLayer/HealthBar/Label.text = str(new_health)
