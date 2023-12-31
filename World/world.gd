class_name World extends Node2D

static var instance: World

@export var pause_menu: CanvasItem

@export var shop_button_parent: Node
@export var balance_label: Label
@export var lose_screen: PackedScene

@export var gold_scene: PackedScene

@export var balance := 1: 
	set(value):
		balance_label.text = str(value)

		balance = value

@onready var enemy_count_label := %EnemyCount
var enemy_count := 0:
	set(value):
		enemy_count_label.text = "Enemy Count: " + str(value)
		enemy_count = value

var shop_buttons: Array[ShopButton] = []
var stick_button: ShopButton

func _input(event: InputEvent):
	if event.is_action_pressed("pause"):
		pause_menu.visible = true
		get_tree().paused = true

func _on_selected(button: ShopButton):
	var cost = button.price

	if cost <= balance:
		shuffle_shop()

		balance -= cost

		var weapon := button.weapon_scene.instantiate() as Weapon
		weapon.global_position = MousePos.mouse_pos

		add_child(weapon)
		weapon.set_moving(true)


func shuffle_shop():
	for btn in shop_buttons:
		btn.visible = false
	stick_button.visible = false

	var btns := shop_buttons.duplicate()

	stick_button.reset()
	stick_button.visible = true
	stick_button.get_parent().move_child(stick_button, 0)
	for i in range(2):
		btns.shuffle()
		var btn := btns.pop_back() as ShopButton
		btn.reset()
		btn.visible = true
		btn.get_parent().move_child(btn, i + 1)


func _init():
	instance = self

func _ready():
	HighscoreManager.reset()

	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)

	balance = balance

	for node in shop_button_parent.get_children():
		if node.stick:
			stick_button = node
		else:
			shop_buttons.append(node)

		node.selected.connect(_on_selected)

	shuffle_shop()

func _on_collected():
	HighscoreManager.score += 1
	balance += 1

@onready var gold_parent := %Gold
func _on_create_gold(amount: int, pos: Vector2):
	for i in range(amount):
		var gold = gold_scene.instantiate()
		gold.global_position = pos
		gold.global_rotation = randf() * PI * 2
		gold_parent.add_child.call_deferred(gold)

func _on_node_added(node:Node):
	if node is Gold:
		node.collected.connect(_on_collected)

	if node is Enemy:
		enemy_count += 1
		node.create_gold.connect(_on_create_gold)

func _on_node_removed(node:Node):
	if node is Enemy:
		enemy_count -= 1
		

func _on_cake_dead():
	HighscoreManager.commit()
	get_tree().change_scene_to_packed(lose_screen)

