@tool
class_name MaterialCreator extends EditorScript

# Script for creating materials out of image files by LeV73

var materials_path : String = VMFConfig.config.material.targetFolder

# Add missing extensions
const EXTENSIONS_ARRAY : PackedStringArray = ["png", "jpg", "jpeg", "tga"]

func _run() -> void:
	material_creator(materials_path, EXTENSIONS_ARRAY)

func material_creator(path : String = materials_path, extensions : PackedStringArray = EXTENSIONS_ARRAY):
	for extension in extensions:
		var texture_list : PackedStringArray  = get_all_files(path, extension)
		for texture in texture_list:
			var new_res_path = texture.trim_suffix("." + extension) + ".tres"
			if FileAccess.file_exists(new_res_path):
				continue
			else:
				var material := StandardMaterial3D.new()
				var texture_resource : Texture2D = load(texture)
				material.set_texture(BaseMaterial3D.TEXTURE_ALBEDO, texture_resource)
				if texture_resource.has_alpha():  # does not work for some reason
					material.set_transparency(BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR)
					material.set_cull_mode(BaseMaterial3D.CULL_DISABLED)
				ResourceSaver.save(material, new_res_path)
				print("Texture with path" + texture + " has been converted.")

# source for recursivly finding files: https://gist.github.com/hiulit/772b8784436898fd7f942750ad99e33e?permalink_comment_id=5034395#gistcomment-5034395
func get_all_files(path: String, file_ext := "", files := PackedStringArray()) -> PackedStringArray:
	var dir = DirAccess.open(path)

	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin()

		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files(dir.get_current_dir() +"/"+ file_name, file_ext, files)
			else:
				if file_ext and file_name.get_extension() != file_ext:
					file_name = dir.get_next()
					continue
				
				files.append(dir.get_current_dir() +"/"+ file_name)

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access %s." % path)

	return files
