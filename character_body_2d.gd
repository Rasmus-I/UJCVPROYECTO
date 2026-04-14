extends CharacterBody2D

# NOTA GENERAL: presionar ALT Z o ir a EDIT / Editar y buscar Wrap Line / Ajuste de linea para mejor legibilidad.
var SALUD_MAX = 100
var SALUD = 100

const VELOCIDAD_MAX = 250.0
const ACELERACION = 15.0
const FRICCION = 25.0

# Comentarios son con el #. Asi se evitan problemas.
# Indice 0, osea frame 0, es el idle. Por defecto.
# Indices 1-4 se SUPONE que son los frames de la pierna derecha.
# Indices 5-8 se SUPONE que son los frames de la pierna izquierda.
const SECUENCIA_FRAMES = [0, 1, 2, 3, 4, 3, 2, 1, 0, 5, 6, 7, 8, 7, 6, 5]
# Podria rehacer esta parte.

var ATACANDOESTADO = false 
var DIRECCIONACTUAL = "down"

@onready var anim = $AnimatedSprite2D
@onready var area_ataque = $area_ataque/CollisionShape2D
# Se removio direccion_ataque, aparentemente era mas facil

# Variables.
var timing_animacion = 0.0
var index_secuencia_actual = 0
var velocidad_animacion = 12.0
var velocidad_recuperacion = 18.0

func _physics_process(delta):
	# Aca es: Si no ataca, que se mueva, y si ataca entonces que no se mueva.
	if ATACANDOESTADO:
		return
		
	var input_dir = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	
	# Input de ataque va aca.
	if Input.is_action_just_pressed("attack"):
		atacar()
		return
	
	# Esto es la logica del movimiento :p
	if input_dir != Vector2.ZERO:
		velocity = velocity.lerp(input_dir * VELOCIDAD_MAX, ACELERACION * delta)
		
		# Determina la direccion para que elija el sprite debido.
		if abs(input_dir.x) > abs(input_dir.y):
			DIRECCIONACTUAL = "left" if input_dir.x < 0 else "right"
		else:
			DIRECCIONACTUAL = "up" if input_dir.y < 0 else "down"
		
		anim.animation = "walk_" + DIRECCIONACTUAL
		
		# Manejo manual de los frames de movimiento
		timing_animacion += delta * velocidad_animacion
		if timing_animacion >= 1.0:
			timing_animacion = 0.0
			index_secuencia_actual = (index_secuencia_actual + 1) % SECUENCIA_FRAMES.size()
			anim.frame = SECUENCIA_FRAMES[index_secuencia_actual]
	else: 
		# Friccion. E idle porque si.
		velocity = velocity.lerp(Vector2.ZERO, FRICCION * delta)
		
		if anim.frame != 0:
			timing_animacion += delta * velocidad_recuperacion
			if timing_animacion >= 1.0:
				timing_animacion = 0.0
				wrap_up_animation()
		else:
			index_secuencia_actual = 0
			timing_animacion = 0.0

	move_and_slide()
	
func atacar():
		ATACANDOESTADO = true
		velocity = Vector2.ZERO #Esto detiene al jugador al atacar. 
		anim.animation = "attack_" + DIRECCIONACTUAL
		anim.play()
		
		match DIRECCIONACTUAL:
			"right":
				area_ataque.position = Vector2(15,0)
			"left":
				area_ataque.position = Vector2(-15,0)
			"up":
				area_ataque.position = Vector2(0,-15)
			"down":
				area_ataque.position = Vector2(0,15)
		
		area_ataque.disabled = false

func _on_animated_sprite_2d_animation_finished():
	if anim.animation.begins_with("attack"):
		ATACANDOESTADO = false
		area_ataque.disabled = true
		anim.frame = 0 # Regresa al frame inicial cuando termina :derp:

func recibir_damage(cantidad):
	SALUD -= cantidad
	print("HP: ", SALUD)
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	if SALUD <= 0:
		morir()

func morir():
	Consola.escribir("FIN DEL JUEGO.", "maroon")
	queue_free()

func wrap_up_animation():
	
	var f = anim.frame
	if f >= 1 and f <= 4:
		anim.frame = f - 1
	elif f >= 5 and f <= 8:
		anim.frame = f - 1 if f > 5 else 0
	index_secuencia_actual = SECUENCIA_FRAMES.find(anim.frame)


func _on_area_ataque_body_entered(body: Node2D) -> void:
	if body.has_method("recibir_damage"):
		body.recibir_damage(50)
	#Anotacion, esta funcion se hace cuando le das click a area_ataque, luego al inspector, vas a la seccion de signals y LE DAS CLICK A 'body_entered(area algo algo)', Esto es para que reciba daño.
