extends Control

@onready var maskguy_row = $VBoxContainer/MaskGuy
@onready var ninjafrog_row = $VBoxContainer/NinjaFrog
@onready var pinkman_row = $VBoxContainer/PinkMan
@onready var virtualgirl_row = $VBoxContainer/VirtualGirl
@onready var maskguy_text = $VBoxContainer/MaskGuy/Label
@onready var ninjafrog_text = $VBoxContainer/NinjaFrog/Label
@onready var pinkman_text = $VBoxContainer/PinkMan/Label
@onready var virtualgirl_text = $VBoxContainer/VirtualGirl/Label

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(get_parent().get_parent().name).to_int())
	
	for i in GameManager.Players:
		match GameManager.Players[i].character:
			"MaskGuy":
				maskguy_row.visible = true
			"NinjaFrog":
				ninjafrog_row.visible = true
			"PinkMan":
				pinkman_row.visible = true
			"VirtualGirl":
				virtualgirl_row.visible = true

func _process(_delta):
	for i in GameManager.Players:
		match GameManager.Players[i].character:
			"MaskGuy":
				maskguy_text.text = str(GameManager.Players[i].score)
			"NinjaFrog":
				ninjafrog_text.text = str(GameManager.Players[i].score)
			"PinkMan":
				pinkman_text.text = str(GameManager.Players[i].score)
			"VirtualGirl":
				virtualgirl_text.text = str(GameManager.Players[i].score)
