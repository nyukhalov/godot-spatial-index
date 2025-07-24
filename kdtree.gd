class_name KDTree extends SpatialIndex

class KDNode:
	var point: Variant
	var axis: int
	var left: KDNode
	var right: KDNode
	
	func _init(point: Variant, axis: int, left: KDNode, right: KDNode):
		self.point = point
		self.axis = axis # 0 = x-axis, 1 = y-axis
		self.left = left
		self.right = right

var _getter: Callable
var _root: KDNode

func _init(points: Array[Variant], getter: Callable) -> void:
	_getter = getter
	_root = _build_kd_tree(points, 0)

func _build_kd_tree(points: Array[Variant], depth: int) -> KDNode:
	if points.is_empty():
		return null
	var axis = depth % 2  # alternate between x (0) and y (1)
	var custom_sort = func _sort(a, b):
		var point_a = _getter.call(a)[axis]
		var point_b = _getter.call(b)[axis]
		return point_a < point_b
	points.sort_custom(custom_sort)
	var median = int(points.size() / 2)
	var left_points = points.slice(0, median)
	var right_points = points.slice(median + 1)
	return KDNode.new(
		points[median],
		axis,
		_build_kd_tree(left_points, depth + 1),
		_build_kd_tree(right_points, depth + 1)
	)

func query_point(point: Vector2, radius: int) -> Array[Variant]:
	var result: Array = []
	_radius_search(_root, point, radius, radius * radius, result)
	return result
	
func _radius_search(node: KDNode, target: Vector2, radius: int, radius_squared: int, results: Array[Variant]) -> void:
	if node == null:
		return

	var point = node.point
	var p: Vector2 = _getter.call(point)
	var axis = node.axis

	# Check if the current point is within the radius
	if p.distance_squared_to(target) <= radius_squared:
		results.push_back(point)

	# Decide which side(s) to explore
	var diff = target[axis] - p[axis]

	# Search left
	if diff < 0:
		_radius_search(node.left, target, radius, radius_squared, results)
		if abs(diff) <= radius:
			_radius_search(node.right, target, radius, radius_squared, results)
	else:
		_radius_search(node.right, target, radius, radius_squared, results)
		if abs(diff) <= radius:
			_radius_search(node.left, target, radius, radius_squared, results)
