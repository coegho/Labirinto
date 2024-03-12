extends Button

@export var action: String

func _ready():
	set_process_unhandled_input(false)
	display_key()

func display_key():
	text = "%s" % InputMap.action_get_events(action)[0].as_text()

func _on_toggled(toggle_on):
	set_process_unhandled_input(toggle_on)
	if toggle_on:
		text = "..."
		release_focus()
	else:
		display_key()
		grab_focus()

func _unhandled_input(event):
	if event.is_pressed():
		remap_key(event)
		button_pressed = false

func remap_key(event):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	
	text = "%s" % event.as_text()
