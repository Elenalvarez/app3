extends Sprite2D

var pressing = false

@export var maxLenght = 50
@export var deadzone = 5

@onready var joystick = $".."

func _ready():
	maxLenght *= joystick.scale.x

func _process(delta):
	if pressing:
		if get_global_mouse_position().distance_to(joystick.global_position) <= maxLenght:
			global_position = get_global_mouse_position()
		else:
			var angle = joystick.global_position.angle_to_point(get_global_mouse_position())
			global_position.x = joystick.global_position.x + cos(angle)*maxLenght
			global_position.y = joystick.global_position.y + sin(angle)*maxLenght
		calculateVector()
	else:
		global_position = lerp(global_position, joystick.global_position, delta*10)
		joystick.posVector = Vector2(0,0)

func calculateVector():
	if abs(global_position.x - joystick.global_position.x) >= deadzone:
		joystick.posVector.x = (global_position.x - joystick.global_position.x) / maxLenght
	if abs(global_position.y - joystick.global_position.y) >= deadzone:
		joystick.posVector.y = (global_position.y - joystick.global_position.y) / maxLenght

func _on_button_button_down():
	pressing = true

func _on_button_button_up():
	pressing = false

func _on_stick_input_event(viewport, event, shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		pressing = true
	
	if event is InputEventScreenTouch and not event.pressed:
		pressing = false

func _on_pantalla_input_event(viewport, event, shape_idx):
	if event is InputEventScreenTouch and not event.pressed:
		pressing = false
