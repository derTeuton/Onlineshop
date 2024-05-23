extends PanelContainer

@onready var joint_name : LineEdit = $HSplitContainer/Joint/VBoxContainer/joint_name
@onready var joint_neutral : CheckButton = $HSplitContainer/Joint/VBoxContainer/VSplitContainer/HBoxContainer/joint_neutral
@onready var joint_gender : HSlider = $HSplitContainer/Joint/VBoxContainer/VSplitContainer/VSplitContainer/joint_gender
@onready var neutral_title : Label = $HSplitContainer/Joint/VBoxContainer/VSplitContainer/HBoxContainer/neutral_title
@onready var gender_title : HBoxContainer = $HSplitContainer/Joint/VBoxContainer/VSplitContainer/VSplitContainer/gender_title

enum GENDER { neutral, mann, platzhalter1, platzhalter2, futanari, platzhalter3, platzhalter4, weib }

@export var _joint_gender : int
@export var _joint_name : String

func _process(delta): print(GENDER.find_key(0))

func _on_joint_neutral_pressed(): 
	if joint_neutral.button_pressed: 
		joint_gender.editable = false
		_joint_gender = GENDER.neutral
		print("no gender")
	elif not joint_neutral.button_pressed: 
		joint_gender.editable = true
		joint_gender.value = GENDER.futanari
		_joint_gender = GENDER.futanari
		print("gender")


func _on_joint_gender_drag_ended( _value_changed : bool ): if _value_changed:
	_joint_gender = joint_gender.value


func _on_joint_name_text_changed( _new_text : String ): _joint_name = _new_text
