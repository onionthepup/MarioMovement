extends CharacterBody2D

@onready var animated_sprite : AnimatedSprite2D = $Sprite

const MINWALKSPEED = 10.0		#walk speed at the start of movement
const MAXWALKSPEED = 90.0		#max speed when walking
const RUNSPEED = 150.0			#max speed when running
const WALKACCEL = 120.0			#acceleration when walking
const RUNACCEL = 240.0			#acceleration when running
const DECCEL = 240.0
const SKIDDECCEL = 180.0
const TURNDECCEL = 360.0

const SMALLJUMP = 240.0			#jump velocity if h. velocity < 120
const BIGJUMP = 300.0			#jump velocity if h. velocity > 120
const JUMPSPEEDTOGGLE = 120		#see above

var speedlock = false #locks you out of sprinting mid-air
var speedlock_sprint = false
var skidding = false
var direction

func _physics_process(delta):
	
	# Add the gravity.
	gravity_handler(delta)

	# Handle Jump.
	jump_handler()

	# Handle movement
	movement_handler(delta)
	
	move_and_slide()
	update_animation()

func gravity_handler(delta):
	if not is_on_floor():
		velocity.y += gravity(Input.is_action_pressed("jump"), abs(velocity.x)) * delta

func jump_handler():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		$Jump.play()
		speedlock = true
		if abs(velocity.x) > JUMPSPEEDTOGGLE:
			velocity.y -= BIGJUMP
			speedlock_sprint = true
		else:
			velocity.y -= SMALLJUMP
			speedlock_sprint = false

func movement_handler(delta):
	#in mid-air, should keep speed static if you don't press a direction
	if is_on_floor():
		speedlock = false
	direction = Input.get_axis("left", "right")
	if direction:
		if direction * velocity.x < 0: #if input is opposite of curr. speed
			velocity.x = move_toward(velocity.x, direction * MINWALKSPEED, TURNDECCEL * delta) #use turndeccel (biggest)
		elif abs(velocity.x) < MINWALKSPEED: #start at minwalkspeed
			velocity.x = direction * MINWALKSPEED
		else:
			if Input.is_action_pressed("run") and not speedlock:
				velocity.x = move_toward(velocity.x, direction * RUNSPEED, RUNACCEL * delta)
			else:
				velocity.x = move_toward(velocity.x, direction * MAXWALKSPEED, WALKACCEL * delta)
	else:
		if speedlock:
			return
		if abs(velocity.x) > MAXWALKSPEED: #if running, use skiddeccel (lower)
			velocity.x = move_toward(velocity.x, 0, SKIDDECCEL * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, DECCEL * delta)

func update_animation():
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
	update_flip()

func update_flip():
	if is_on_floor():
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true

func gravity(holding_jump, _currspeed):
	if holding_jump:
		#return 500.0
		if speedlock_sprint:
			return 625.0
		else:
			return 500.0
	else:
		#return 1200.0
		if speedlock_sprint:
			return 1500.0
		else:
			return 1200.0
