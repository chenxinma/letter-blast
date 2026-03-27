extends Panel

enum BadgeType {
	BEGINNER,      # 初学者 - 学习10个单词
	INTERMEDIATE,  # 进阶者 - 学习50个单词
	EXPERT,        # 高手 - 学习100个单词
	MASTER,        # 大师 - 学习200个单词
	PERFECTIONIST, # 完美主义者 - 完美通关1次
	FULL_SCORE,    # 满分王 - 完美通关5次
	ACCURACY_90,   # 准确率90%
	SCORE_1000,    # 千分达人
	PLAY_TIME_1H   # 游戏时长1小时
}

const BADGE_DATA = {
	BadgeType.BEGINNER: {"name": "初学者", "icon": "🌱"},
	BadgeType.INTERMEDIATE: {"name": "进阶者", "icon": "🌿"},
	BadgeType.EXPERT: {"name": "高手", "icon": "🌳"},
	BadgeType.MASTER: {"name": "大师", "icon": "👑"},
	BadgeType.PERFECTIONIST: {"name": "完美主义者", "icon": "⭐"},
	BadgeType.FULL_SCORE: {"name": "满分王", "icon": "🌟"},
	BadgeType.ACCURACY_90: {"name": "准确率90%", "icon": "🎯"},
	BadgeType.SCORE_1000: {"name": "千分达人", "icon": "🏆"},
	BadgeType.PLAY_TIME_1H: {"name": "游戏时长1h", "icon": "⏰"},
}

@export var badge_type: BadgeType = BadgeType.BEGINNER:
	set(value):
		badge_type = value
		_update_badge()

@export var is_active: bool = true:
	set(value):
		is_active = value
		_update_badge()

@onready var icon_label: Label = $VBoxContainer/IconLabel
@onready var name_label: Label = $VBoxContainer/NameLabel


func _ready() -> void:
	_update_badge()


func _update_badge() -> void:
	if not is_node_ready():
		return
	
	var data = BADGE_DATA.get(badge_type, {"name": "未知", "icon": "?"})
	
	if icon_label:
		icon_label.text = data["icon"]
		icon_label.modulate = Color(1, 1, 1) if is_active else Color(0.5, 0.5, 0.5, 0.5)
	
	if name_label:
		name_label.text = data["name"]
		name_label.modulate = Color(1, 1, 1) if is_active else Color(0.5, 0.5, 0.5, 0.5)


func set_badge(type: BadgeType, active: bool) -> void:
	badge_type = type
	is_active = active