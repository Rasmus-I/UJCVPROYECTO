extends ColorRect

@onready var anim = $AnimatedSprite2D

func _ready() -> void:
	anim.position = get_viewport_rect().size / 2
	
	anim.play("muerte_anim")

func _process(delta: float) -> void:
	pass

func _on_animated_sprite_2d_animation_finished():
	get_tree().quit()
