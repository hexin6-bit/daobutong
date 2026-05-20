extends Control

const BASE_SIZE: Vector2 = Vector2(750.0, 1334.0)
const SKY_COLOR: Color = Color("#1a1a2e")
const MOUNTAIN_COLOR: Color = Color(0.070588, 0.070588, 0.164706, 0.68)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_sky()
	_build_mountains()
	_build_particles()


func _build_sky() -> void:
	var sky: ColorRect = ColorRect.new()
	sky.color = SKY_COLOR
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sky.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(sky)


func _build_mountains() -> void:
	var mountains: Node2D = Node2D.new()
	mountains.name = "Mountains"
	mountains.z_index = -1
	add_child(mountains)

	_add_mountain(mountains, PackedVector2Array([
		Vector2(-120.0, 1220.0), Vector2(70.0, 1045.0), Vector2(230.0, 1190.0),
		Vector2(390.0, 1030.0), Vector2(620.0, 1220.0), Vector2(900.0, 1110.0),
		Vector2(980.0, BASE_SIZE.y), Vector2(-120.0, BASE_SIZE.y),
	]), 0.56)
	_add_mountain(mountains, PackedVector2Array([
		Vector2(-180.0, 1260.0), Vector2(120.0, 1105.0), Vector2(310.0, 1250.0),
		Vector2(530.0, 1085.0), Vector2(820.0, 1260.0), Vector2(1000.0, 1190.0),
		Vector2(1000.0, BASE_SIZE.y), Vector2(-180.0, BASE_SIZE.y),
	]), 0.42)
	_add_mountain(mountains, PackedVector2Array([
		Vector2(-240.0, 1295.0), Vector2(40.0, 1195.0), Vector2(270.0, 1305.0),
		Vector2(500.0, 1160.0), Vector2(760.0, 1298.0), Vector2(1040.0, 1210.0),
		Vector2(1040.0, BASE_SIZE.y), Vector2(-240.0, BASE_SIZE.y),
	]), 0.32)

	var animation_player: AnimationPlayer = AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	add_child(animation_player)

	var animation: Animation = Animation.new()
	animation.length = 20.0
	animation.loop_mode = Animation.LOOP_LINEAR
	var track_index: int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, NodePath("Mountains:position"))
	animation.track_insert_key(track_index, 0.0, Vector2.ZERO)
	animation.track_insert_key(track_index, 10.0, Vector2(-36.0, 0.0))
	animation.track_insert_key(track_index, 20.0, Vector2.ZERO)

	var library: AnimationLibrary = AnimationLibrary.new()
	library.add_animation("drift", animation)
	animation_player.add_animation_library("", library)
	animation_player.play("drift")


func _add_mountain(parent: Node, points: PackedVector2Array, alpha: float) -> void:
	var mountain: Polygon2D = Polygon2D.new()
	mountain.polygon = points
	mountain.color = Color(MOUNTAIN_COLOR.r, MOUNTAIN_COLOR.g, MOUNTAIN_COLOR.b, alpha)
	parent.add_child(mountain)


func _build_particles() -> void:
	var image: Image = Image.create(2, 2, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 1.0, 1.0, 0.55))
	var particle_texture: ImageTexture = ImageTexture.create_from_image(image)

	var particles: CPUParticles2D = CPUParticles2D.new()
	particles.name = "AuraParticles"
	particles.texture = particle_texture
	particles.amount = 28
	particles.lifetime = 10.0
	particles.preprocess = 10.0
	particles.emitting = true
	particles.position = Vector2(BASE_SIZE.x * 0.5, -12.0)
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(BASE_SIZE.x * 0.55, 8.0)
	particles.direction = Vector2(0.0, 1.0)
	particles.spread = 24.0
	particles.gravity = Vector2(0.0, 16.0)
	particles.initial_velocity_min = 12.0
	particles.initial_velocity_max = 32.0
	particles.angular_velocity_min = -12.0
	particles.angular_velocity_max = 12.0
	particles.scale_amount_min = 0.8
	particles.scale_amount_max = 1.8
	particles.color = Color(1.0, 1.0, 1.0, 0.34)
	add_child(particles)
