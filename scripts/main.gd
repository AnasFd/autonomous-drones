extends Node3D

const DroneScene: Resource = preload("res://scenes/drone.tscn")

@onready var drone_container = $Drones
@onready var camera = $Camera3D
@export var area_size: float = 150.0
@export var sphere_center: Vector3 = Vector3(0, 0, 0)
@export var sphere_radius: float = 40.0 # 40/15 (performance) 40/10 awesome view
@export var base_min_distance: float = 10.0
@export var sphere_volume: float = 4/(3 * PI * pow(sphere_radius, 3))

enum State { MOVE }
var global_state: State = State.MOVE
var all_drones = []
var num_drones: int

func _ready():
	#camera.position = Vector3(3.28, -12.01, 73.22)
	camera.position = Vector3(0, 0, 73.22)
	camera.look_at(sphere_center)
	num_drones = drones_per_radius(sphere_radius, base_min_distance)
	print("Nombre de drones: " + str(num_drones))
	spawn_drones(num_drones)
	for drone in all_drones:
		drone.initialize(sphere_center, sphere_radius, all_drones, base_min_distance, sphere_volume)

func _process(delta):
	update_states(delta)

func spawn_drones(count: int) -> void:
	for i in range(count):
		var new_drone = DroneScene.instantiate()
		drone_container.add_child(new_drone)
		
		var random_position = Vector3(
			randf_range(-area_size, area_size), # different x
			randf_range(-area_size, area_size), # meme y
			randf_range(-area_size, area_size) # meme z
		)
		# 2ème config (au sol)
		#var random_position = Vector3(
			#(i + i * 10),
			#-100,
			#(i + i * 2)
		#)
		new_drone.global_transform.origin = random_position
		all_drones.append(new_drone)

# Centralized state update logic for all drones
func update_states(delta) -> void:
	for drone in all_drones:
		drone.perform_behavior(delta)

func drones_per_radius(radius: float, bmd: float) -> int:
	@warning_ignore("narrowing_conversion")
	return (8 * pow(radius,3) * 0.75) / (pow(bmd,3))
