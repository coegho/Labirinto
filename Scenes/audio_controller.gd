extends CanvasLayer

@onready var audio_panel = %AudioPanel
@onready var volume_master_slider = %VolumeMasterSlider
@onready var volume_music_slider = %VolumeMusicSlider
@onready var volume_effects_slider = %VolumeEffectsSlider

func _ready():
	volume_master_slider.value = SettingsManager.user_preferences.master_audio_level
	volume_music_slider.value = SettingsManager.user_preferences.bgm_audio_level
	volume_effects_slider.value = SettingsManager.user_preferences.sfx_audio_level


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_audio_button_toggled(toggled_on):
	audio_panel.visible = toggled_on


func _on_volume_master_slider_drag_ended(value_changed):
	if value_changed:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume_master_slider.value))
		SettingsManager.user_preferences.master_audio_level = volume_master_slider.value
		SettingsManager.user_preferences.save()


func _on_volume_music_slider_drag_ended(value_changed):
	if value_changed:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(volume_music_slider.value))
		SettingsManager.user_preferences.bgm_audio_level = volume_music_slider.value
		SettingsManager.user_preferences.save()


func _on_volume_effects_slider_drag_ended(value_changed):
	if value_changed:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(volume_effects_slider.value))
		SettingsManager.user_preferences.sfx_audio_level = volume_effects_slider.value
		SettingsManager.user_preferences.save()
