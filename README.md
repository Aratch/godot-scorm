# godot-scorm: Basic SCORM interface for Godot 3.x web exports

!!! This project is not feature-complete and is not in active development. !!!

This addon provides rudimentary SCORM functionality via a thin wrapper around a minimally modified version of [lmihaidaniel's JS simple-scorm-wrapper](https://github.com/lmihaidaniel/simple-scorm-wrapper/).

## What is SCORM
[SCORM](https://en.wikipedia.org/wiki/Sharable_Content_Object_Reference_Model "Wikipedia Article") (short for **S**hareable **C**ontent **O**bject **R**eference **M**odel) is a mostly legacy but unfortunately still widespread standard for digital learning modules (also known as web-based trainings), especially when deployed on an LMS (Learning Management System). The SCORM standard handles how courses or modules communicate states and state changes and how courses are to be packaged.

## What this addon does
`godot-scorm` provides a GDSript interface around a third-party SCORM wrapper. The use of a mature JS wrapper means that `godot-scorm` should be able to communicate with LMS that are not 100% standard compliant, although it should be noted that this hasn't been thoroughly tested. 

`godot-scorm` should enable you to:
- Notify the LMS of success/failure and similar state changes
- Notify the LMS of score changes
- Query app state from and commit it to the LMS

`godot-scorm` is known to work on OpenOLAT 17.x and 18.x and implements common methods for SCORM 1.2.
## What this addon doesn't do
Due to diminishing personal interest and professional relevance, and/or technical constraints, `godot-scorm` does not support the following things out of the box:
- **SCORM 2004**: `godot-scorm` has been tested against SCORM 1.2. The SCORM 2004 interface differs only a bit, so it should not be too much work.
- **Exporting for web as-is**: The supplied `export_plugin.gd` will attempt to ensure that the Javascript wrapper is exported (untested!), but you will still need to provide a [suitable web shell](https://docs.godotengine.org/en/3.5/tutorials/platform/customizing_html5_shell.html) or include header for your web template. Godot 3.x does not provide an interface for addons to modify export templates unfortunately.
- **State management**: You will have to keep track of your internal app or game state yourself.
- **Tools for Activities**: Similarly, `godot-scorm` does not provide any functionality or nodes that would plug into your state management or the SCORM API to be used for learning activities out of the box. You will have to do this yourself.
- **SCORM packaging**: This is a can of worms in and of itself, although the same lmihaidaniel also has a [simple-scorm-packager package](https://github.com/lmihaidaniel/simple-scorm-packager).

## How to use this addon
A `SCORM` singleton is defined in `scorm.gd`. The `SCORM` singleton does two things out of the box:
- When running in a web export, it checks for a variable called `scormWrapper`, checks its compatibility, hooks up the `window.onbeforeunload` Javascript event to a GDScript callback and then emits the `SCORM_ready` signal.
- Due to the connected callback, when the user closes the tab/window or the module is exited some other way, the `NOTIFICATION_WM_QUIT_REQUEST` is send to the `SceneTree`, making sure that all `_exit_tree()` methods are called.

Once the `SCORM` singleton is ready, you should be able to boot up your app, e.g.

```gdscript
# game_state.gd
func _on_SCORM_ready() -> void:
	retrieve_suspend_data()
	emit_signal("game_ready")
	game_ready = true
```

Where `GameState.retrieve_suspend_data()` could look like this

```gdscript
# game_state.gd
var _state : GameStateResource = GameStateResource.new()

func retrieve_suspend_data() -> void:
	var suspend_data = SCORM.get_suspend_data()
	if suspend_data is Dictionary and not suspend_data.empty():	
		for context in suspend_data.keys():
			_state.contexts[context] = {}
			for key in suspend_data[context]:
				_state.contexts[context][key] = suspend_data[context][key]
```

Your app/game logic would then call `SCORM.set_status(SCORM.STATUS.PASSED)` or similar in the appropriate situations. Don't forget to call `SCORM.commit()` to be sure.

## Prior Art
- [simple-scorm-wrapper by lmihaidaniel](https://github.com/lmihaidaniel/simple-scorm-wrapper/)

## License
`godot-scorm` is licensed under the MIT license.
