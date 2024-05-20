extends CharacterBody2D

const SPEED = 300.0
var canon
var health = 10
var max_health = 10

func _ready():
	canon = $Canon
	z_index = 1

func _physics_process(_delta):
	# Get the input direction and handle the movement/deceleration.
	var direction_x = Input.get_axis("ui_left", "ui_right")
	var direction_y = Input.get_axis("ui_up", "ui_down")
	
	if direction_x or direction_y:
		velocity.x = direction_x * SPEED
		velocity.y = direction_y * SPEED
		rotation = atan2(velocity.y, velocity.x)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()

	# Rotate the canon towards the mouse position
	var mouse_position = get_global_mouse_position()
	canon.look_at(mouse_position)
	canon.rotation -= PI/2


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var projectile_scene = preload("res://scenes/projectile.tscn")
		if projectile_scene:
			var projectile = projectile_scene.instantiate()
			var dir = get_global_mouse_position() - canon.global_position
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
	get_tree().change_scene_to_file("res://scenes/you_lost.tscn")

func update_health(new_health):
	$HealthBarCanvasLayer/HealthBar.value = new_health
	$HealthBarCanvasLayer/HealthBar/Label.text = str(new_health)
