extends CharacterBody2D

@onready var animated_sprite : AnimatedSprite2D = $Sprite

const MINWALKSPEED = 4.453125	#walk speed at the start of movement
const MAXWALKSPEED = 93.75		#max speed when walking
const RUNSPEED = 153.75			#max speed when running
const WALKACCEL = 2.2265625		#acceleration when walking
const RUNACCEL = 3.33984375		#acceleration when running
const RELEASEDECCEL = 3.046875
const SKIDDECCEL = 6.09375
const TURNDECCEL = 33.75

const SMALLJUMP = 240.0			#jump velocity if h. velocity < 138.75
const BIGJUMP = 300.0			#jump velocity if h. velocity > 138.75
const JUMPSPEEDTOGGLE = 138.75	#see above

var speedlock = false

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity(Input.is_action_pressed("jump"), abs(velocity.x)) * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if velocity.x > JUMPSPEEDTOGGLE:
			velocity.y -= BIGJUMP
		else:
			velocity.y -= SMALLJUMP

	# Handle movement
	var direction = Input.get_axis("left", "right")
	if direction:
		if abs(velocity.x) < MINWALKSPEED:
			velocity.x = direction * MINWALKSPEED
		else:
			if Input.is_action_pressed("run"):
				velocity.x = move_toward(velocity.x, direction * RUNSPEED, RUNACCEL)
			else:
				velocity.x = move_toward(velocity.x, direction * MAXWALKSPEED, WALKACCEL)
	else:
		velocity.x = move_toward(velocity.x, 0, RELEASEDECCEL)

	move_and_slide()
	update_animation(direction)

func update_animation(direction):
	if not is_on_floor():
		animated_sprite.play("jump")
	elif direction * velocity.x < 0:		#????
		animated_sprite.play("skid")
	elif direction:
		animated_sprite.play("walk")
	elif velocity.x != 0:
		animated_sprite.play("skid")
	elif velocity.x * direction < 0:
		animated_sprite.play("skid")
	else:
		animated_sprite.play("idle")
	update_flip(direction)

func update_flip(direction):
	if is_on_floor():
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true

func gravity(A, currspeed):
	if A:
		if currspeed < 60:
			return 7.5 *60
		elif currspeed > 138.75:
			return 9.375 *60
		else:
			return 7.03125 *60
	else:
		if currspeed < 60:
			return 26.25 *60
		elif currspeed > 138.75:
			return 22.5 *60
		else:
			return 33.75 *60
