extends Node

# ESTO SIRVE PARA DEBUG, PUEDE QUE SE REMUEVA EN LA VERSION FINAL

var etiqueta_consola: RichTextLabel
const Limite_Msg = 15
var historial_msg = []

func registrar_consola(label: RichTextLabel):
	etiqueta_consola = label
	etiqueta_consola.bbcode_enabled = true
	escribir("SISTEMA INICIADO..", "yellow")
	
func escribir(mensaje: String, color: String = "white"):
	if etiqueta_consola:
		var tiempo = Time.get_time_string_from_system()
		var linea_nueva = "[" + tiempo + "] [color=" + color + "]" + mensaje + "[/color]"
		
		historial_msg.append(linea_nueva)
		
		if historial_msg.size() > Limite_Msg:
			historial_msg.remove_at(0)
		
		etiqueta_consola.text = ""
		for linea in historial_msg:
			etiqueta_consola.append_text(linea + "\n")
