extends Node

var _api
var _object

var lms_available := false
var scorm_version

# SCORM 1.2 values
enum STATUS {
	NOT_ATTEMPTED,
	COMPLETED,
	INCOMPLETE,
	PASSED,
	FAILED,
	BROWSED
}

var status_dict : Dictionary = {
	STATUS.NOT_ATTEMPTED : "not attempted",
	STATUS.COMPLETED : "completed",
	STATUS.INCOMPLETE : "incomplete",
	STATUS.PASSED : "passed",
	STATUS.FAILED : "failed",
	STATUS.BROWSED : "browsed"
}

var SCORM_ready := false

signal SCORM_ready

# see: https://godotengine.org/article/godot-web-progress-report-9/
var _before_unload_callback := JavaScript.create_callback(self, "_on_js_beforeunload")

func _on_js_beforeunload(args): 
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func _ready() -> void:
	if OS.has_feature("JavaScript"):
		print("SCORM.gd init")
		
		# Seems to be pretty useless
#		_object = JavaScript.get_interface("Object")
		if var_exists("scormWrapper"):
			_api = JavaScript.get_interface("scormWrapper")
		else:
			print("scormWrapper doesn't exist. Wrapper isn't imported?")
		if _api:
			print("SCORM wrapper found")
			if method_exists("scormWrapper", "getApi"):
				print("getApi exists")
				if _api.getApi():
					lms_available = true
					scorm_version = _api.version
					print("SCORM ", _api.version, " successfully initialised")
					call_deferred("emit_signal", "SCORM_ready")
					SCORM_ready = true
					
					var window = JavaScript.get_interface("window")
					
					window.onbeforeunload = _before_unload_callback
					
				else:
					print("No SCORM API or LMS found")
	
	# Editor runs only:
	elif not OS.has_feature("JavaScript") and not SCORM_ready and OS.is_debug_build():
		call_deferred("emit_signal", "SCORM_ready")
		SCORM_ready = true
	
	else:
		print("JavaScript module not found; not running as web export?")

func property_exists(obj_name: String, property_name: String, global_context : bool = true) -> bool:
	return JavaScript.eval("""
		Object.hasOwn({obj_name}, '{property_name}')
	""".format({"obj_name":obj_name, "property_name":property_name}), global_context)

func method_exists(obj_name: String, method_name: String, global_context : bool = true) -> bool:
	return JavaScript.eval("""
		typeof {obj_name}.{method_name} === "function"
	""".format({"obj_name":obj_name, "method_name":method_name}), global_context)

func var_exists(obj_name: String, global_context : bool = true) -> bool:
	return JavaScript.eval("""
		typeof {obj_name} !== "undefined"
	""".format({"obj_name":obj_name}), global_context)

func commit() -> void:
	if lms_available and method_exists("scormWrapper", "commit"):
		print("Calling SCORM commit")
		print("SCORM Commit: ", _api.commit())

# TODO: Implement different options and/or branches for "logout" or "" values
# See https://scorm.com/scorm-explained/technical-scorm/run-time/
func terminate() -> void:
	if lms_available and method_exists("scormWrapper", "terminate"):
		print("SCORM Terminate: ", _api.terminate("suspend"))

func get_status() -> String:
	if lms_available and method_exists("scormWrapper", "status"):
		return _api.status()
	else:
		return ""

func set_status(s : int) -> void:
	if lms_available and method_exists("scormWrapper", "status"):
		print("Setting status to ", status_dict[s])
		_api.status(status_dict[s])

# TODO: Should the argument even be in dictionary form?
# TODO: Replace var2str and str2var with Marshalls.variant_to_base64() and the like
# for compression reasons (SCORM 1.2 only allows up to 4'096 chars?!)

func _encode_variants(dict : Dictionary) -> void:
	pass

func set_suspend_data(state : Dictionary) -> void:
	if lms_available and method_exists("scormWrapper", "suspend_data"):
		print("Committing suspend data: ", var2str(state))
		_api.suspend_data(var2str(state))
	
func get_suspend_data() -> Dictionary:
	if lms_available and method_exists("scormWrapper", "suspend_data"):
		if _api.suspend_data() and _api.suspend_data() != null:
			var suspend_data = destructure_suspend_data(_api.suspend_data())
			print("Retrieving suspend data: ", suspend_data)
			return str2var(suspend_data)
	return {}

## This assumes _api.suspend_data() returns a Javascript Object that for some reason
## has numbered attributes for every single character that has previously been passed into suspend_data
func destructure_suspend_data(js_object: JavaScriptObject) -> String:
	var object_interface := JavaScript.get_interface("Object")
	var joined_string = object_interface.values(js_object).join("")
	if joined_string:
		return joined_string
	else:
		return "{}"

func set_score(v: int) -> void:
	if lms_available and method_exists("scormWrapper", "score"):
		_api.score(v)

func get_score() -> int:
	if lms_available and method_exists("scormWrapper", "score"):
		return _api.score()
	else:
		return -1

# TODO: Implement Scorm.prototype.success = function success (v) {...}
func success(v : int) -> void:
	pass

func _exit_tree() -> void:
	commit()
