class_name NetworkConnectionConfigs
extends RefCounted

var host_ip: String = "127.0.0.1"
var host_port: int = 7000
var game_id: String = ""

func _init(p_host_ip: String = "127.0.0.1", p_host_port: int = 7000, p_game_id: String = ""):
	host_ip = p_host_ip
	host_port = p_host_port
	game_id = p_game_id
