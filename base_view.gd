extends Node

class_name BaseView

enum screens {game_over,menu,intro,play,summary,}

signal did_prepare_to_hide
signal did_hide
signal did_prepare_to_show
signal did_show

signal base_change_screen_signal(index:screens)
signal data_from_stage(data:Dictionary)
signal get_data_from_main()

var duration := 1.0

var stage_game_data : Dictionary

func set_data_from_main(data:Dictionary) -> void:
	stage_game_data = data

func prepare_to_hide() -> void:
	did_prepare_to_hide.emit()

func hide() -> void:
	did_hide.emit()

func prepare_to_show() -> void:
	did_prepare_to_show.emit()

func base_show() -> void:
	did_show.emit()
