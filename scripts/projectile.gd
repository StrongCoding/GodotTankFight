extends Area2D

var speed = 500
var direction = Vector2()

func _ready():
	z_index = 0

func _physics_process(delta):
	position += direction * speed * delta

func set_direction(dir):
	direction = dir.normalized()
	rotation = atan2(direction.y, direction.x)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_Projectile_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(1)
	queue_free()
