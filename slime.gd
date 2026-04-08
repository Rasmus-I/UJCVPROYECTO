extends CharacterBody2D

var SALUD = 250
const VELOCIDAD = 40.0
const DISTANCIADETECCION = 200.0 # Pixeles? no se. Esto es para que TE SIGA cuando estes cerca.
@onready var anim = $AnimatedSprite2D
var player = null

func _ready() -> void:
	# ok, esto basicamente hace que empiece la animacion apenas el slime exista.
	anim.play("Movimiento")

# Eu gente para el que modifique esto, no se PORQUE pero cuando el slime te ataca por detras NO se suelta. A menos que lo mates. Pero de las otras direcciones (Arriba, izquierda, derecha) no ocurre esto.

func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("Jugador")
		return
		
	var distancia = global_position.distance_to(player.global_position)
	
	if distancia < DISTANCIADETECCION and distancia > 30.0:
		var direccion = global_position.direction_to(player.global_position)
		
		# Usamos lerp para que el movimiento sea fluido
		velocity = velocity.lerp(direccion * VELOCIDAD, 0.1)
		
		if not anim.is_playing():
			anim.play("Movimiento")
		anim.flip_h = direccion.x < 0
	else:
		# Fricción para detenerse
		velocity = velocity.move_toward(Vector2.ZERO, 15)
		if velocity.length() < 2.0:
			anim.stop()

	move_and_slide()
	
func recibir_damage(cantidad):
	SALUD -= cantidad
	print("HP enemigo: ", SALUD)
	
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if SALUD <= 0:
		morir()

func morir():
	# Nota: Poner algo aca como placeholder de muerte. No se.
	queue_free()

func _on_area_ataque_body_entered(body: Node2D) -> void:
	if body.has_method("recibir_damage"):
		body.recibir_damage(25)
		


#Estos son DOS NODOS DISTINTOS. El de arriba PROCESA Y LE DA EL VALOR DE DAÑO del jugador POR MEDIO DE RECIBIR DAMAGE, el de abajo CAUSA daño al jugador por medio de recibir damage.

func _on_areadamage_body_entered(body: Node2D) -> void:
	if body.has_method("recibir_damage"):
		body.recibir_damage(10) # El daño que hace el slime
