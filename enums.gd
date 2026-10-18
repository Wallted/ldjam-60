class_name Enums

enum Direction {
	UP,
	DOWN,
	RIGHT,
	LEFT,
}

static func get_direction(_dir: Direction) -> Vector2:
	match _dir:
		Direction.UP:
			return Vector2.UP
		Direction.DOWN:
			return Vector2.DOWN
		Direction.RIGHT:
			return Vector2.RIGHT
		Direction.LEFT:
			return Vector2.LEFT
	return Vector2.ZERO


enum PersonType {
	ARCHAEOLOGIST,
	CELT,
	ELON,
	GOLIATH,
	ICARUS,
	MICHELANGELO,
	MONKEY,
	NEANDERTHAL,
	SISYPHUS,
	TOURIST,
}
