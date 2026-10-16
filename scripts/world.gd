extends Node3D

const EnemyScript = preload("res://scripts/enemy.gd")
const PlayerScript = preload("res://scripts/player.gd")
const HudScript = preload("res://scripts/hud.gd")

var player
var hud
var enemy_container: Node3D

func _ready() -> void:
    randomize()
    create_environment()
    create_player()
    create_world_props()
    create_enemies()
    create_hud()

func create_environment() -> void:
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55, -25, 0)
    sun.light_energy = 1.0
    add_child(sun)

    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.35, 0.39, 0.45)
    env.ambient_light_energy = 0.55
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world_env.environment = env
    add_child(world_env)

    var floor_body := StaticBody3D.new()
    floor_body.name = "Ground"
    var floor_shape := CollisionShape3D.new()
    var box_shape := BoxShape3D.new()
    box_shape.size = Vector3(180, 1, 180)
    floor_shape.shape = box_shape
    floor_shape.position.y = -0.5
    floor_body.add_child(floor_shape)

    var floor_mesh := MeshInstance3D.new()
    var box_mesh := BoxMesh.new()
    box_mesh.size = Vector3(180, 1, 180)
    floor_mesh.mesh = box_mesh
    floor_mesh.position.y = -0.5
    var ground_mat := StandardMaterial3D.new()
    ground_mat.albedo_color = Color(0.16, 0.20, 0.17)
    ground_mat.roughness = 1.0
    floor_mesh.material_override = ground_mat
    floor_body.add_child(floor_mesh)
    add_child(floor_body)

func create_player() -> void:
    player = PlayerScript.new()
    player.position = Vector3(0, 1, 0)
    add_child(player)

func create_world_props() -> void:
    for i in range(34):
        var obstacle := StaticBody3D.new()
        obstacle.name = "Ruin_%02d" % i
        var x := randf_range(-65, 65)
        var z := randf_range(-65, 65)
        if Vector2(x, z).length() < 12:
            x += 18

        var size := Vector3(randf_range(2, 6), randf_range(2, 8), randf_range(2, 6))
        var shape_node := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        shape_node.shape = shape
        shape_node.position.y = size.y / 2
        obstacle.add_child(shape_node)

        var visual := MeshInstance3D.new()
        var mesh := BoxMesh.new()
        mesh.size = size
        visual.mesh = mesh
        visual.position.y = size.y / 2
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.22, 0.24, 0.25)
        visual.material_override = mat
        obstacle.add_child(visual)
        obstacle.position = Vector3(x, 0, z)
        add_child(obstacle)

func create_enemies() -> void:
    enemy_container = Node3D.new()
    enemy_container.name = "Raiders"
    add_child(enemy_container)

    for i in range(7):
        var enemy = EnemyScript.new()
        enemy.name = "Raider_%02d" % i
        enemy.position = Vector3(randf_range(-35, 35), 1, randf_range(-35, 35))
        enemy.target = player
        enemy_container.add_child(enemy)

func create_hud() -> void:
    hud = HudScript.new()
    add_child(hud)
    hud.setup(player)
    player.stats_changed.connect(hud.refresh)
    player.message_changed.connect(hud.set_message)

func _process(_delta: float) -> void:
    if is_instance_valid(hud):
        hud.refresh()
