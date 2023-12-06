tool
extends EditorPlugin

const SCORM_NAME = "SCORM"

var export_plugin = preload("res://addons/godot-scorm/export_plugin.gd").new()

func _enter_tree() -> void:
	add_autoload_singleton(SCORM_NAME, "res://addons/godot-scorm/scorm.gd")
	add_export_plugin(export_plugin)


func _exit_tree() -> void:
	remove_autoload_singleton(SCORM_NAME)
	remove_export_plugin(export_plugin)
