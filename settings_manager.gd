extends Node

var _user_preferences: UserPreferences

var user_preferences: UserPreferences:
	get:
		if _user_preferences == null:
			_user_preferences = UserPreferences.load_or_create()
		return _user_preferences

func load_settings() -> void:
	for action in user_preferences.action_events.keys():
		var event = user_preferences.action_events.get(action)
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), lerp(-60, 0, user_preferences.master_audio_level))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), lerp(-60, 0, user_preferences.bgm_audio_level))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), lerp(-60, 0, user_preferences.sfx_audio_level))
