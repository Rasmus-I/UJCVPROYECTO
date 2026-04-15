extends CharacterBody2D

enum State { IDLE, CHASE, ATTACK}
var current_state = State.IDLE

var SALUD = 100
const VELOCIDAD = 30.0
const RANGO_ATAQUE = 50.0
const DISTANCIADETECCION = 300.0

var DIRECCIONACTUAL = "down"
var ATACANDOESTADO= false

@onready var anim = $AnimatedSprite2D
@onready var espada_area_colision = $AtaqueArea/CollisionShape2D

func _ready():
	espada_area_colision.disabled = true

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("Jugador")
	if !player or ATACANDOESTADO:
		return
	
	var rayodetector = $RayCast2D
	rayodetector.target_position = to_local(player.global_position)
	
	var distancia = global_position.distance_to(player.global_position)
	var direccion_v = global_position.direction_to(player.global_position)
	
	var enemigo_vision_directa = false
	if rayodetector.is_colliding():
		var colision = rayodetector.get_collider()
		if colision.is_in_group("Jugador"):
			enemigo_vision_directa = true
	
	match current_state:
		State.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 10)
			anim.play("walk_" + DIRECCIONACTUAL)
			anim.stop()
			
			if distancia < DISTANCIADETECCION and enemigo_vision_directa:
				current_state = State.CHASE
		
		State.CHASE:
			if distancia <= RANGO_ATAQUE:
				current_state = State.ATTACK
			elif distancia > DISTANCIADETECCION or !enemigo_vision_directa:
				current_state = State.IDLE
			else:
				velocity = direccion_v * VELOCIDAD
				actualizar_direccion_v_animacion(direccion_v)
		
		State.ATTACK:
			iniciar_ataque()
	
	move_and_slide()
	
func actualizar_direccion_v_animacion(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		DIRECCIONACTUAL = "right" if dir.x > 0 else "left"
	else:
		DIRECCIONACTUAL = "up" if dir.y < 0 else "down"
	anim.play("walk_" + DIRECCIONACTUAL)

func iniciar_ataque():
	ATACANDOESTADO = true
	velocity = Vector2.ZERO
	anim.play("attack_" + DIRECCIONACTUAL)
	
	match DIRECCIONACTUAL:
		"right": espada_area_colision.position = Vector2(15,0)
		"left": espada_area_colision.position = Vector2(-15,0)
		"up": espada_area_colision.position = Vector2(0,-15)
		"down": espada_area_colision.position = Vector2(0,15)
	
	espada_area_colision.set_deferred("disabled", false)

func _on_animated_sprite_2d_animation_finished():
	if anim.animation.begins_with("attack"):
		ATACANDOESTADO = false
		espada_area_colision.disabled = true
		current_state = State.CHASE

func recibir_damage(cantidad):
	SALUD -= cantidad
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	if SALUD <= 0:
		morir()
		
func morir():
	set_physics_process(false)
	
	anim.play("Muerte")
	
	await anim.animation_finished
	
	queue_free()
	

func _on_ataque_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador") and body.has_method("recibir_damage"):
		body.recibir_damage(15)
