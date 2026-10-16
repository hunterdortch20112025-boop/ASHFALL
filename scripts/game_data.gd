extends Node

const WEAPONS := {
    "Starter Rifle": {"damage": 25, "magazine": 30, "range": 100.0},
    "Heavy Rifle": {"damage": 40, "magazine": 20, "range": 140.0},
    "Sidearm": {"damage": 15, "magazine": 12, "range": 45.0}
}

const ITEMS := {
    "Water": {"price": 20, "type": "survival"},
    "Food": {"price": 15, "type": "survival"},
    "Bandage": {"price": 35, "type": "medical"},
    "Scrap": {"price": 5, "type": "resource"},
    "Wood": {"price": 3, "type": "resource"}
}

const CRAFTING := {
    "Bandage": {"Scrap": 1},
    "Barricade Kit": {"Wood": 5, "Scrap": 2},
    "Medkit": {"Scrap": 4}
}
