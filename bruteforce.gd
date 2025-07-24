class_name BruteForce extends SpatialIndex

var _points: Array[Variant]
var _getter: Callable

func _init(points: Array[Variant], getter: Callable) -> void:
	_points = points
	_getter = getter

func query_point(target: Vector2, radius: int) -> Array[Variant]:
	var r2 = radius * radius
	var res: Array[Variant] = []
	for point in _points:
		var p: Vector2 = _getter.call(point)
		if p.distance_squared_to(target) <= r2:
			res.push_back(point)
	return res
