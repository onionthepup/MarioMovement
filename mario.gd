extends CharacterBody2D

@onready var animated_sprite : AnimatedSprite2D = $Sprite

const MINWALKSPEED = 10.0		#walk speed at the start of movement
const MAXWALKSPEED = 90.0		#max speed when walking
const RUNSPEED = 150.0			#max speed when running
const WALKACCEL = 2				#acceleration when walking
const RUNACCEL = 4				#acceleration when running
const DECCEL = 4
const SKIDDECCEL = 3
const TURNDECCEL = 6

const SMALLJUMP = 240.0			#jump velocity if h. velocity < 120
const BIGJUMP = 300.0			#jump velocity if h. velocity > 120
const JUMPSPEEDTOGGLE = 120		#see above

var speedlock = false
var skidding = false

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity(Input.is_action_pressed("jump"), abs(velocity.x)) * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		$Jump.play()
		speedlock = true
		if abs(velocity.x) > JUMPSPEEDTOGGLE:
			velocity.y -= BIGJUMP
		else:
			velocity.y -= SMALLJUMP

	# Handle movement
	var direction = Input.get_axis("left", "right")
	if direction:
		if direction * velocity.x < 0:
			velocity.x = move_toward(velocity.x, direction * MINWALKSPEED, TURNDECCEL)
		elif abs(velocity.x) < MINWALKSPEED:
			velocity.x = direction * MINWALKSPEED
		else:
			if Input.is_action_pressed("run") and not speedlock:
				velocity.x = move_toward(velocity.x, direction * RUNSPEED, RUNACCEL)
			else:
				velocity.x = move_toward(velocity.x, direction * MAXWALKSPEED, WALKACCEL)
	else:
		if abs(velocity.x) > MAXWALKSPEED:
			velocity.x = move_toward(velocity.x, 0, SKIDDECCEL)
		else:
			velocity.x = move_toward(velocity.x, 0, DECCEL)
	
	move_and_slide()
	update_animation(direction)

func update_animation(direction):
	if not is_on_floor():
		animated_sprite.play("jump")
	elif direction * velocity.x < 0:		#input is in opposite direction of movement
		animated_sprite.play("skid")
	elif direction:
		animated_sprite.play("walk")
		skidding = false
	elif abs(velocity.x) > MAXWALKSPEED or (abs(velocity.x) > 0 and skidding):	#not inputting direction, but still moving
		animated_sprite.play("skid")
		skidding = true
	elif abs(velocity.x) > 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")
		skidding = false
	update_flip(direction)

func update_flip(direction):
	if is_on_floor():
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true

func gravity(A, currspeed):
	if A:
		return 500.0
	else:
		return 1200.0
