extends CharacterBody3D

signal stats_changed
signal message_changed(message: String)

const SPEED := 6.0
const SPRINT_SPEED := 9.0
const JUMP_VELOCITY := 4.5
const GRAVITY := 14.0

var health := 100.0
var hunger := 100.0
var thirst := 100.0
var stamina := 100.0
var credits := 500
var ammo := 30
var inventory := {"Scrap": 3, "Wood": 5, "Water": 2, "Food": 2}

var camera: Camera3D
var fire_cooldown := 0.0
var is_sprinting := false

func _ready() -> void:
    name = "Player"
    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.38
    capsule.height = 1.8
    collision.shape = capsule
    collision.position.y = 0.9
    add_child(collision)

    var body_mesh := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.38
    mesh.height = 1.8
    body_mesh.mesh = mesh
    body_mesh.position.y = 0.9
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.19, 0.23, 0.25)
    body_mesh.material_override = mat
    add_child(body_mesh)

    camera = Camera3D.new()
    camera.position = Vector3(0, 1.58, 0)
    camera.current = true
    add_child(camera)

    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * 0.002)
        camera.rotate_x(-event.relative.y * 0.002)
        camera.rotation.x = clamp(camera.rotation.x, -1.45, 1.45)
    elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        fire_weapon()

func _physics_process(delta: float) -> void:
    fire_cooldown = maxf(0.0, fire_cooldown - delta)
    hunger = maxf(0.0, hunger - delta * 0.08)
    thirst = maxf(0.0, thirst - delta * 0.13)

    if not is_on_floor():
        velocity.y -= GRAVITY * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = JUMP_VELOCITY

    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    is_sprinting = Input.is_key_pressed(KEY_SHIFT) and stamina > 1.0 and input_dir.length() > 0.1
    var speed := SPRINT_SPEED if is_sprinting else SPEED

    if is_sprinting:
        stamina = maxf(0.0, stamina - delta * 17.0)
    else:
        stamina = minf(100.0, stamina + delta * 10.0)

    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)

    move_and_slide()
    stats_changed.emit()

func fire_weapon() -> void:
    if fire_cooldown > 0 or ammo <= 0:
        message_changed.emit("Reload or wait before firing.")
        return

    fire_cooldown = 0.18
    ammo -= 1
    var query := PhysicsRayQueryParameters3D.create(
        camera.global_position,
        camera.global_position - camera.global_transform.basis.z * 100.0
    )
    query.exclude = [get_rid()]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)

    if not hit.is_empty():
        var target = hit.collider
        if target.has_method("take_damage"):
            target.take_damage(25.0)
            message_changed.emit("Hit confirmed.")
        else:
            message_changed.emit("Impact.")
    else:
        message_changed.emit("Shot fired.")
    stats_changed.emit()

func take_damage(amount: float) -> void:
    health = maxf(0.0, health - amount)
    if health <= 0:
        message_changed.emit("You were eliminated. Restart to try again.")
        set_physics_process(false)
    stats_changed.emit()

func add_item(item: String, amount: int = 1) -> void:
    inventory[item] = int(inventory.get(item, 0)) + amount
    message_changed.emit("Collected %s x%d" % [item, amount])
    stats_changed.emit()

func use_item(item: String) -> void:
    if int(inventory.get(item, 0)) <= 0:
        message_changed.emit("You don't have any " + item + ".")
        return
    if item == "Water":
        thirst = minf(100, thirst + 35)
    elif item == "Food":
        hunger = minf(100, hunger + 30)
    elif item == "Bandage":
        health = minf(100, health + 25)
    else:
        message_changed.emit("That item cannot be used yet.")
        return
    inventory[item] -= 1
    stats_changed.emit()

func save_game() -> void:
    var data := {
        "position": [position.x, position.y, position.z],
        "health": health,
        "hunger": hunger,
        "thirst": thirst,
        "stamina": stamina,
        "credits": credits,
        "ammo": ammo,
        "inventory": inventory
    }
    var file := FileAccess.open("user://ashfall_save.json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))
        message_changed.emit("Game saved.")

func load_game() -> void:
    if not FileAccess.file_exists("user://ashfall_save.json"):
        message_changed.emit("No save found.")
        return
    var file := FileAccess.open("user://ashfall_save.json", FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        message_changed.emit("Save file is invalid.")
        return
    var p = parsed.get("position", [0, 1, 0])
    position = Vector3(float(p[0]), float(p[1]), float(p[2]))
    health = float(parsed.get("health", 100))
    hunger = float(parsed.get("hunger", 100))
    thirst = float(parsed.get("thirst", 100))
    stamina = float(parsed.get("stamina", 100))
    credits = int(parsed.get("credits", 500))
    ammo = int(parsed.get("ammo", 30))
    inventory = parsed.get("inventory", {})
    stats_changed.emit()
    message_changed.emit("Game loaded.")
