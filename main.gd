extends Node
#const menu_scene = preload("res://main_menu/main_menu/main_menu.tscn") as PackedScene
#const play_scene = preload("res://core_campaing/main_campaing/campaign.tscn") as PackedScene
#const battle_scene = preload("res://core_battle/battle_escenario/fight_scene.tscn") as PackedScene

const true_scenario = preload("res://play_scenarios/intro/intro_scenario.tscn")
const intro_scenario = preload("res://play_scenarios/intro/intro_scenario.tscn")
const menu_scene = preload("res://main_menu/main_menu.tscn")

@export var play_scene :  PackedScene
@export var battle_scene :  PackedScene

var root = null
var current_screen 
var current_screen_node
var is_changing_screen := false
var game_over_scene : PackedScene
var summary_scene : PackedScene

##Data structure
@onready var campaign_data : String = "Somedata"

var mission_data : Dictionary = {
		"Avaible Missions": ["1a ,1b ,2a"],
		"Currency": 2300,
		"current_mission": "1a",
		}
var game_data :Dictionary

@onready var screen_scenes : Dictionary= {
	BaseView.screens.menu: menu_scene,
	BaseView.screens.intro: intro_scenario,
	}

func _ready():
	root = self
	var new_screen_node  = screen_scenes[BaseView.screens.menu].instantiate()
	await add_new_screen(new_screen_node, BaseView.screens.menu)
	is_changing_screen = false

	game_data = {
		"campaign_data": campaign_data,
		"battle_data": "2",
		"mission_data": "3",
		}

	TranslationServer.set_locale("en")

func change_screen(new_screen: BaseView.screens) -> void:
	if is_changing_screen:
		return
	is_changing_screen = true
	var new_screen_node  = screen_scenes[new_screen].instantiate()
	await load_new_screen(new_screen_node, new_screen)
	is_changing_screen = false


func hide_old_screen(new_screen_node, new_screen: BaseView.screens) -> void:
	current_screen_node.call_deferred("prepare_to_hide")
	await current_screen_node.did_prepare_to_hide
	
	current_screen_node.call_deferred("hide")
	await current_screen_node.did_hide

	current_screen_node.queue_free()

func add_new_screen(new_screen_node, new_screen: BaseView.screens) -> void:
	root.add_child(new_screen_node)
	
	new_screen_node.base_change_screen_signal.connect(change_screen)
	
	new_screen_node.call_deferred("prepare_to_show")
	await new_screen_node.did_prepare_to_show
	
	new_screen_node.call_deferred("base_show")
	await new_screen_node.did_show
	
	current_screen = new_screen
	current_screen_node = new_screen_node
	current_screen_node.data_from_stage.connect(save_data_from_stage)
	current_screen_node.get_data_from_main.connect(set_data_to_stage)
	set_data_to_stage()

func load_new_screen(new_screen_node, new_screen: BaseView.screens) -> void:
	hide_old_screen(new_screen_node,new_screen)
	add_new_screen(new_screen_node,new_screen)

func set_data_to_stage() -> void:
	current_screen_node.set_data_from_main(game_data) 

func save_data_from_stage(data: Dictionary) -> void:
	print("got some data", data)
	game_data = data
