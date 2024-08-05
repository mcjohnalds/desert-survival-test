extends Node
class_name Loader

@onready var _container: Node = $Container
@onready var _progress_label: Label = %ProgressLabel
@onready var _file_label: Label = %FileLabel
@onready var _camera: Camera3D = %Camera


@warning_ignore("unsafe_property_access")
func compile_shaders() -> void:
	var file_paths := Util.get_files_recursive("res://")

	var scene_file_paths: Array[String] = []
	for file_path in file_paths:
		# In the web build, files in the exported package have a .remap suffix
		file_path = file_path.rstrip(".remap")
		if file_path.ends_with(".tscn"):
			scene_file_paths.append(file_path)

	var initial_graphics_preset := global.get_graphics_preset()
	var highest_graphics_preset := (
		Global.GraphicsPreset.HIGH if OS.get_name() == "Web"
		else Global.GraphicsPreset.INSANE
	)
	global.set_graphics_preset(highest_graphics_preset)
	var step := 0
	_camera.environment = global.environments[0]
	for file_path in scene_file_paths:
		var steps := scene_file_paths.size()
		var percent := floori(float(step) / float(steps) * 100.0)
		_progress_label.text = "Loading assets (%s%%)" % percent
		_file_label.text = file_path.lstrip("res://")
		await get_tree().process_frame

		var packed_scene: PackedScene = load(file_path)
		var scene: Node = packed_scene.instantiate()

		var nodes := Util.get_children_recursive(scene, true)
		nodes.append(scene)

		for node: Node in nodes:
			node.set_script(null)
			# Don't want autoplaying sounds or anything else causing
			# problems
			node.process_mode = Node.PROCESS_MODE_DISABLED
			if "visible" in node:
				node.visible = true
			if (
				node is GPUParticles2D
				or node is GPUParticles3D
				or node is CPUParticles2D
				or node is CPUParticles3D
			):
				node.one_shot = true
				node.emitting = true
				node.process_mode = Node.PROCESS_MODE_ALWAYS
			if node is CanvasItem:
				var canvas_item: CanvasItem = node
				canvas_item.z_index = 0
			if node is ScrollContainer:
				# The ScrollContainer associated with OptionButtons draw on
				# top of everything else and I don't know why so I just
				# hide them
				node.visible = false
			if node is CanvasLayer:
				var canvas_layer: CanvasLayer = node
				# Don't want the scene's layer to clash with our layer
				canvas_layer.layer = 1
			if node is Camera3D:
				var camera: Camera3D = node
				camera.current = false
			if node is DirectionalLight3D and OS.get_name() == "macOS":
				# Prevents a crash. Some sort of bug in the Godot engine.
				var light: DirectionalLight3D = node
				light.shadow_enabled = false
		_container.add_child(scene)
		await get_tree().process_frame
		step += 1
	global.set_graphics_preset(initial_graphics_preset)
