extends Node2D

@onready var generate_button: Button = %GenerateButton
@onready var timer_label: Label = %TimerLabel

@export var num_points: int = 10000
@export var color_unselected: Color = Color.CADET_BLUE
@export var color_selected: Color = Color.FIREBRICK
@export var radius: int = 50

class ColoredPoint:
	var pos: Vector2 = Vector2.ZERO
	var color: Color = Color.BLACK
	
	func _init(new_pos: Vector2, new_color: Color) -> void:
		pos = new_pos
		color = new_color

var _points: Array[ColoredPoint] = []
var _index: SpatialIndex

func _ready():
	generate_button.pressed.connect(_on_generate_btn_pressed)
	
func _process(delta):
	timer_label.text = "%s(%0.2f)" % [Time.get_ticks_msec(), delta]
	
	for point in _points:
		point.color = color_unselected
	var mouse_pos = get_viewport().get_mouse_position()
	if _index != null:
		var t = Time.get_ticks_usec()
		for point in _index.query_point(mouse_pos, radius):
			point.color = color_selected
		print("radius queue time: %s us" % [Time.get_ticks_usec() - t])
	queue_redraw()
	
func _draw() -> void:
	for point in _points:
		draw_rect(Rect2(point.pos, Vector2(2, 2)), point.color)
		#draw_circle(point.pos, 2, point.color)  # drawing a circle is extemely slow :/

func _on_generate_btn_pressed():
	_points.clear()
	for i in range(num_points):
		var max_size = get_viewport().size
		var x = randi_range(0, max_size.x)
		var y = randi_range(0, max_size.y)
		_points.push_back(ColoredPoint.new(Vector2(x, y), color_unselected))
	var point_getter = func(p):
		return p.pos
	_index = KDTree.new(_points, point_getter)
	#_index = BruteForce.new(_points, point_getter)
	queue_redraw()
