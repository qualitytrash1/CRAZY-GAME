extends CharacterBody3D


@onready var camera: Camera3D = $Camera3D

@export var sensitivity : float = 0.002
@export var rotation_speed : float = 2


const SPEED : float = 10.0
const JUMP_VELOCITY : float = 4.5
const FRICTION : float = 0.8
const MAX_COYOTE_TIME : float = 0.1
const MAX_BUFFER_JUMP : float = 0.1
var coyote_time : float = 0.0
var buffer_jump : float = 0.0
var vel : Vector2

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		coyote_time = MAX_COYOTE_TIME
		
	# Handle jump.
	if Input.is_action_pressed("jump"):
		buffer_jump = MAX_BUFFER_JUMP
		
	if coyote_time > 0 and buffer_jump > 0:
		coyote_time = 0
		buffer_jump = 0
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir : Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction_vec3 : Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var direction : Vector2 = Vector2(direction_vec3.x, direction_vec3.z)
	var input_rotation : Vector2 = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	
	rotation.y -= (input_rotation.x * rotation_speed) * delta
	camera.rotation.x -= (input_rotation.y * rotation_speed) * delta
	
	camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	vel = direction * SPEED
	vel *= FRICTION
	
	velocity = Vector3(vel.x, velocity.y, vel.y)

	buffer_jump -= delta
	coyote_time -= delta
	
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= (event.screen_relative.x * sensitivity)
		camera.rotation.x -= (event.screen_relative.y * sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
