tool
extends EditorExportPlugin


func _export_begin(features: PoolStringArray, is_debug: bool, path: String, flags: int) -> void:
	var scorm_wrapper_fi := File.new()
	scorm_wrapper_fi.open("res://addons/godot-scorm/shell/simple-scorm-wrapper.js", File.READ)
	var scorm_wrapper = scorm_wrapper_fi.get_buffer(scorm_wrapper_fi.get_len())
	add_file("res://simple-scorm-wrapper.js", scorm_wrapper, true)
