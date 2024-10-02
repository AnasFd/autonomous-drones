extends Node3D

@export var circle_center: Vector3  # Centre du cercle
@export var circle_radius: float = 10.0  # Rayon du cercle
var target_position: Vector3
var speed: float = 5.0  # Vitesse de déplacement
var is_at_target: bool = false  # Indique si le drone a atteint sa cible

func _ready():
	calculate_target_position()  # Calculer la position cible initiale sur la circonférence

func _process(delta):
	if not is_at_target:
		move_towards_target(delta)
	else:
		# Recalcule la position cible si le drone est déjà à sa cible
		calculate_target_position()

# Calculer une position sur la circonférence
func calculate_target_position():
	var position_found = false
	while not position_found:
		var angle = randf() * PI * 2  # Angle aléatoire entre 0 et 2π
		target_position = circle_center + Vector3(cos(angle), 0, sin(angle)) * circle_radius
		
		# Vérifier si la position cible est occupée
		if not is_position_occupied(target_position):
			position_found = true  # Position valide trouvée

# Vérifier si la position est occupée par un autre drone
func is_position_occupied(position: Vector3) -> bool:
	var drones = get_parent().get_children()  # Récupérer tous les drones
	for drone in drones:
		if drone != self and drone.global_transform.origin.distance_to(position) < 1.0:  # Vérifier une distance d'1 unité
			return true  # La position est occupée
	return false  # La position est libre

# Déplacement vers la position cible
func move_towards_target(delta):
	var direction = (target_position - global_transform.origin).normalized()
	var distance = speed * delta
	
	# Vérifier si le drone peut atteindre la cible sans dépasser
	if global_transform.origin.distance_to(target_position) > distance:
		var next_position = global_transform.origin + direction * distance

		# Vérifier si la prochaine position est occupée
		if not is_position_occupied(next_position):
			global_transform.origin = next_position  # Déplacer le drone vers la prochaine position
		else:
			# Si la position suivante est occupée, recalculer la cible
			calculate_target_position()
	else:
		global_transform.origin = target_position
		is_at_target = true  # Indiquer que le drone a atteint sa cible
