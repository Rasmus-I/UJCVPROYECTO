extends CharacterBody2D

# NOTA GENERAL: presionar ALT Z o ir a EDIT / Editar y buscar Wrap Line / Ajuste de linea para mejor legibilidad.

# Terminos: Dmg / Damage = Daño, No uso Ñ porque capaz y hay error.
var SALUD = 250
const VELOCIDAD = 40.0
const DISTANCIADETECCION = 200.0 # Pixeles? no se. Esto es para que TE SIGA cuando estes cerca.
var DETECCION = false
@onready var anim = $AnimatedSprite2D
@onready var TemporizadorDmg = $TemporizadorDmg
var dmg_al_objetivo: Node2D = null
var player = null

func _ready() -> void:
	# ok, esto basicamente hace que empiece la animacion apenas el slime exista.
	anim.play("Movimiento")

# Eu, necesito ayuda sabiendo COMO es que el slime por alguna razon gana mas fuerza si lo atacas por abajo. Es decir, TE EMPUJA HACIA ABAJO Y NO TE DEJA IR HASTA QUE LO MATAS.
# Ah si y tambien ver porque el slime solo ataca una vez.
# Probablemente lo habre resuelto apenas publique esta actualizacion.
# Si algo sale mal, utilizar backup que hice y que no olvidare apenas continue.

func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("Jugador")
		return
		
	var distancia = global_position.distance_to(player.global_position)
	
	# Ok, que hace esto:
	# Deteccion. Si el jugador esta en el area de DISTANCIADETECCION entonces el slime va a IR por el jugador.
	# Y si sale del rango? Pues se detiene y no hace nada.
	# Huh, deberia de hacer un modo idle donde camine aleatoriamente.
	# Nota de hacerlo luego para futuros enemigos.
	if distancia < DISTANCIADETECCION and distancia > 30.0:
		if not DETECCION:
			Consola.escribir("EL ENEMIGO TE HA LOCALIZADO!", "red")
			DETECCION = true
		var direccion = global_position.direction_to(player.global_position)
		
		# Usamos lerp para que el movimiento sea fluido
		velocity = velocity.lerp(direccion * VELOCIDAD, 0.1)
		
		if not anim.is_playing():
			anim.play("Movimiento")
		anim.flip_h = direccion.x < 0
	else:
		# Fricción para detenerse
		if DETECCION:
			Consola.escribir("El slime perdió tu rastro...", "gray")
			DETECCION = false
			
		velocity = velocity.move_toward(Vector2.ZERO, 15)
		if velocity.length() < 2.0:
			anim.stop()

	move_and_slide()
	
func recibir_damage(cantidad):
	SALUD -= cantidad
	print("HP enemigo: ", SALUD)
	Consola.escribir("Daño al slime: -" + str(cantidad), "red")
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if SALUD <= 0:
		morir()

func morir():
	Consola.escribir("¡ENEMIGO ELIMINADO!", "green")
	queue_free()

# Se hizo que el daño ahora fuera una funcion repetitiva, depende del timer ahora. Se ha arreglado un problema.

func aplicar_dmg_slime():
	if dmg_al_objetivo and dmg_al_objetivo.has_method("recibir_damage"):
		dmg_al_objetivo.recibir_damage(10)
		Consola.escribir("-10 HP por daño de slime", "red")

func _on_area_ataque_body_entered(body: Node2D) -> void:
	if body.has_method("recibir_damage"):
		body.recibir_damage(25)
		

func _on_areadamage_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		dmg_al_objetivo = body
		aplicar_dmg_slime()
		TemporizadorDmg.start()


func _on_areadamage_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == dmg_al_objetivo:
		dmg_al_objetivo = null
		TemporizadorDmg.stop()


func _on_temporizador_dmg_timeout() -> void:
	aplicar_dmg_slime()
