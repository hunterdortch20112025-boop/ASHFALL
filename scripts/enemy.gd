extends CharacterBody3D

var health := 100.0
var target: Node3D
var attack_timer := 0.0
var speed := 2.5

func _ready() -> void:
    var shape := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.42
    capsule.height = 1.8
    shape.shape = capsule
    shape.position.y = 0.9
    add_child(shape)

    var visual := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.42
    mesh.height = 1.8
    visual.mesh = mesh
    visual.position.y = 0.9
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.48, 0.12, 0.10)
    visual.material_override = material
    add_child(visual)

func _physics_process(delta: float) -> void:
    if not is_instance_valid(target):
        return
    attack_timer -= delta
    var offset: Vector3 = target.global_position - global_position
    offset.y = 0
    var distance := offset.length()

    if distance > 2.0:
        velocity.x = offset.normalized().x * speed
        velocity.z = offset.normalized().z * speed
        look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z))
    else:
        velocity.x = 0
        velocity.z = 0
        if attack_timer <= 0:
            if target.has_method("take_damage"):
                target.take_damage(8)
            attack_timer = 1.2

    if not is_on_floor():
        velocity.y -= 14.0 * delta
    move_and_slide()

func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        if is_instance_valid(target) and target.has_method("add_item"):
            target.add_item("Scrap", 2)
        queue_free()
