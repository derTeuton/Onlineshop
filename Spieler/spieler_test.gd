extends CharacterBody3D

@onready var cam : SpringArm3D  	= self.get_node("SpringArm3D")
@onready var body : MeshInstance3D  = self.get_node("player")

const SPEED : float = 200
const CAM_SPEED : float = -.05
#const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity_speed = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_dir = ProjectSettings.get_setting("physics/3d/default_gravity_vector")

var inp_dir : Vector2:
	get: return Input.get_vector("SW links", "SW rechts", "VW", "RW")
var cam_angle : float:
	get: return cam.rotation.y
var move_dir : Vector3:
	get: return Vector3( inp_dir.rotated(-cam_angle).x, 0, inp_dir.rotated(-cam_angle).y )

func _process(delta): pass


func _input( _event : InputEvent ):
	var _cam_rot : float = 0
	if _event is InputEventMouseMotion: _cam_rot = _event.relative.x * CAM_SPEED
	if _event is InputEventJoypadMotion: if _event.axis == JOY_AXIS_RIGHT_X: _cam_rot = _event.axis_value * CAM_SPEED
	
	cam.rotate_y(_cam_rot)



func _physics_process( _delta : float ):
	# Add the gravity.
	
	# Handle jump. TODO Hüpfen notwendig?
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor(): velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("SW linls", "SW rechts", "VW", "RW")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if inp_dir:
		body.rotation.y = cam_angle + deg_to_rad(180)
		velocity = move_dir * SPEED * _delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if not self.is_on_floor(): velocity += gravity_dir * gravity_speed * _delta
	
	move_and_slide()
