extends CanvasLayer

var player
var stats_label: Label
var message_label: Label
var inventory_label: Label

func setup(p) -> void:
    player = p
    var panel := PanelContainer.new()
    panel.position = Vector2(16, 16)
    panel.custom_minimum_size = Vector2(300, 150)
    add_child(panel)

    var layout := VBoxContainer.new()
    panel.add_child(layout)

    var title := Label.new()
    title.text = "ASHFALL  //  SURVIVAL"
    title.add_theme_font_size_override("font_size", 20)
    layout.add_child(title)

    stats_label = Label.new()
    layout.add_child(stats_label)

    inventory_label = Label.new()
    layout.add_child(inventory_label)

    message_label = Label.new()
    message_label.position = Vector2(16, 178)
    message_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1))
    add_child(message_label)

    var buttons := HBoxContainer.new()
    buttons.position = Vector2(16, 225)
    add_child(buttons)
    add_button(buttons, "Drink", func(): player.use_item("Water"))
    add_button(buttons, "Eat", func(): player.use_item("Food"))
    add_button(buttons, "Save", func(): player.save_game())
    add_button(buttons, "Load", func(): player.load_game())

    var fire := Button.new()
    fire.text = "FIRE"
    fire.custom_minimum_size = Vector2(110, 70)
    fire.anchor_left = 1.0
    fire.anchor_right = 1.0
    fire.anchor_top = 1.0
    fire.anchor_bottom = 1.0
    fire.position = Vector2(-135, -100)
    fire.pressed.connect(func(): player.fire_weapon())
    add_child(fire)

    var reload := Button.new()
    reload.text = "RELOAD"
    reload.anchor_left = 1.0
    reload.anchor_right = 1.0
    reload.anchor_top = 1.0
    reload.anchor_bottom = 1.0
    reload.position = Vector2(-145, -180)
    reload.pressed.connect(func():
        player.ammo = 30
        player.message_changed.emit("Magazine refilled (prototype).")
        refresh()
    )
    add_child(reload)

    refresh()

func add_button(parent: Control, caption: String, action: Callable) -> void:
    var b := Button.new()
    b.text = caption
    b.pressed.connect(action)
    parent.add_child(b)

func refresh() -> void:
    if not is_instance_valid(player):
        return
    stats_label.text = "HP %.0f | Hunger %.0f | Thirst %.0f\nStamina %.0f | Ammo %d | Credits %d" % [
        player.health, player.hunger, player.thirst,
        player.stamina, player.ammo, player.credits
    ]
    inventory_label.text = "Inventory: " + str(player.inventory)

func set_message(message: String) -> void:
    message_label.text = message
