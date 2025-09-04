extends BaseView

signal change_play_game

func _ready() -> void:
	print("mainmenu ready")

func enter_campaing() -> void:
	base_change_screen_signal.emit(screens.play)

func quit_main_menu() -> void:
	get_tree().quit()

func prepare_to_show() -> void:
	did_prepare_to_show.emit()
	
func go_campaing_menu() -> void:
	print("campaing_menu")
	pass

func go_settings_menu() -> void:
	print("settings_menu")

func go_main_menu() -> void:
	pass
