extends Node3D

var speed: float = 2.0
var angle: float = 0.0  # Angle pour le mouvement circulaire
var target_position: Vector3 = Vector3.ZERO
var initial_wait_time: float = 3.0  # Temps d'attente initiale en secondes
var time_in_phase: float = 0.0  # Temps passé dans la phase actuelle
var circle_radius: float = 10.0  # Rayon du cercle pour le mouvement circulaire
var height_offset: float = 10.0  # Hauteur de base pour le cercle vertical
var min_distance: float = 3.0  # Distance minimale entre les drones pour éviter les collisions
var avoidance_strength: float = 5.0  # Force d'évitement pour éviter les collisions

enum MovementPhase { INITIAL, MOVING_TO_CIRCLE, WAITING, IN_CIRCLE }
var current_phase: int = MovementPhase.INITIAL

func _ready():
	# Initialiser la position cible pour le cercle après un délai
	target_position = position  # La position initiale est au sol
	current_phase = MovementPhase.INITIAL

func _process(delta):
	time_in_phase += delta  # Incrémenter le temps passé dans la phase actuelle

	match current_phase:
		MovementPhase.INITIAL:
			# Attendre un temps initial avant de commencer le regroupement
			if time_in_phase >= initial_wait_time:
				set_target_position_for_circle()
				current_phase = MovementPhase.MOVING_TO_CIRCLE
				time_in_phase = 0.0  # Réinitialiser le timer pour la phase suivante

		MovementPhase.MOVING_TO_CIRCLE:
			# Se déplacer vers la position cible dans le cercle vertical
			move_to_target(delta)

			# Vérifier si le drone a atteint la position cible
			var distance_to_target = position.distance_to(target_position)
			if distance_to_target < 1.0:  # Le drone est proche de sa cible
				print("Drone reached target.")
				# Informer le parent que ce drone est prêt
				get_parent().get_parent().notify_drone_ready()
				current_phase = MovementPhase.WAITING  # Passer à la phase d'attente

		MovementPhase.WAITING:
			# Vérifier si tous les drones sont prêts dans le script parent (Main.gd)
			if get_parent().get_parent().are_all_drones_ready():
				start_circle_phase()  # Si tous les drones sont prêts, commencer la phase circulaire

		MovementPhase.IN_CIRCLE:
			# Effectuer le mouvement circulaire vertical
			move_in_circle(delta)
			print("Moving in circle. Current angle: ", angle)  # Debug

# Regroupement pour former un cercle vertical (plan YZ)
func set_target_position_for_circle():
	# Définir l'angle basé sur l'index dans la liste des enfants
	var index = get_index()  # Récupère la position de ce drone parmi les autres
	angle = (2.0 * PI / get_parent().get_child_count()) * index

	# Formation d'un cercle vertical dans le plan YZ
	target_position.x = circle_radius * sin(angle)  # Calculer la position Z (cercle vertical)
	target_position.y = height_offset + circle_radius * cos(angle)  # Calculer la position Y (cercle vertical)
	target_position.z = 0

	print("Target position for drone (vertical circle): ", target_position)  # Debug pour vérifier les positions cibles

func move_to_target(delta):
	# Se déplacer vers la position cible dans le plan vertical YZ
	var direction = (target_position - position).normalized()  # Obtenir la direction

	# Calculer la force d'évitement proactive pour éviter les collisions
	var avoidance_force = calculate_avoidance_force()

	# Ajuster la direction avec la force d'évitement
	direction += avoidance_force

	# Se déplacer vers la cible tout en évitant les collisions
	position += direction.normalized() * speed * delta  # Déplacer vers la position cible

func move_in_circle(delta):
	# Calculer la nouvelle position en fonction de l'angle pour un mouvement circulaire vertical
	angle += speed * delta  # Ajuster l'angle en fonction de la vitesse

	# Mouvement circulaire dans les axes Y et Z (cercle vertical)
	position.x = circle_radius * sin(angle)  # Garder l'axe X fixe pour un cercle vertical
	position.y = height_offset + circle_radius * cos(angle)  # Calculer la position Y (cercle vertical)
	position.z = 0  # Calculer la position Z (cercle vertical)

	print("Moving in vertical circle. Current position: ", position)  # Debug

func start_circle_phase():
	# Commencer le mouvement en cercle
	current_phase = MovementPhase.IN_CIRCLE

# Calculer la force d'évitement pour éviter les collisions
func calculate_avoidance_force() -> Vector3:
	var avoidance_force = Vector3.ZERO

	# Vérifier la distance par rapport aux autres drones
	for drone in get_parent().get_children():
		if drone != self:  # Ne pas se comparer à soi-même
			var distance_to_drone = position.distance_to(drone.position)

			# Si la distance est trop proche, appliquer une force d'évitement
			if distance_to_drone < min_distance:
				# Calculer la direction d'évitement
				var avoidance_direction = (position - drone.position).normalized()
				
				# Détail de l'évitement : déplacer le premier drone vers le haut et le deuxième vers le bas
				if position.y > drone.position.y:
					avoidance_direction.y += 1.0  # Le drone actuel monte
				else:
					avoidance_direction.y -= 1.0  # Le drone actuel descend
				
				# Appliquer une force d'évitement proportionnelle à l'inverse de la distance
				avoidance_force += avoidance_direction * (1.0 / distance_to_drone)  # Force d'évitement

	return avoidance_force * avoidance_strength  # Ajustement de la force d'évitement
