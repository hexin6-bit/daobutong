extends Node

signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)
signal message_received(msg_type: String, data: Dictionary)
signal connection_success()
signal connection_failed()

var peer: ENetMultiplayerPeer = null
var is_host: bool = false
var connected: bool = false
var local_ip: String = ""


func _ready() -> void:
	for address in IP.get_local_addresses():
		if not address.begins_with("127.") and address != "::1":
			local_ip = address
			break


func start_host(port: int = 4242) -> void:
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_server(port, 1)
	if error != OK:
		connection_failed.emit()
		return

	is_host = true
	connected = true
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	connection_success.emit()


func join_host(ip: String, port: int = 4242) -> void:
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_client(ip, port)
	if error != OK:
		connection_failed.emit()
		return

	is_host = false
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)


func send_message(msg_type: String, data: Dictionary = {}) -> void:
	var packet := {"msg_type": msg_type, "data": data}
	_receive_message.rpc(JSON.stringify(packet))


@rpc("any_peer", "reliable")
func _receive_message(msg: String) -> void:
	var json := JSON.new()
	var error := json.parse(msg)
	if error != OK:
		return

	var packet = json.data
	if packet is Dictionary:
		var msg_type := str(packet.get("msg_type", ""))
		var data: Dictionary = packet.get("data", {}) as Dictionary
		if msg_type == "stat_allocation":
			GameManager.on_stat_allocation_received(multiplayer.get_remote_sender_id(), data)
		elif msg_type == "lottery_generated":
			GameManager.on_lottery_generated(data)
		elif msg_type == "lottery_energy":
			GameManager.on_lottery_energy_injected(multiplayer.get_remote_sender_id())
		elif msg_type == "lottery_energy_updated":
			GameManager.lottery_energy_updated.emit(int(data.get("count", 0)), int(data.get("total", 1)))
		elif msg_type == "lottery_energy_ready":
			GameManager.on_lottery_energy_ready()
		elif msg_type == "lottery_card_revealed":
			GameManager.on_lottery_card_revealed(data)
		elif msg_type == "lottery_ready":
			GameManager.on_lottery_ready(data)
		elif msg_type == "lottery_begin":
			GameManager.begin_lottery_reveal()
		elif msg_type == "bargain_choice":
			GameManager.on_bargain_choice_received(multiplayer.get_remote_sender_id(), data)
		elif msg_type == "bargain_continue":
			GameManager.on_bargain_continue_received(multiplayer.get_remote_sender_id(), data)
		elif msg_type == "bargain_settled":
			GameManager.on_bargain_settled(data)
		elif msg_type == "backpack_action":
			GameManager.on_backpack_action_received(multiplayer.get_remote_sender_id(), data)
		elif msg_type == "backpack_updated":
			GameManager.on_backpack_updated(data)
		elif msg_type == "market_action":
			GameManager.on_market_action_received(multiplayer.get_remote_sender_id(), data)
		elif msg_type == "market_updated":
			GameManager.on_market_updated(data)
		elif msg_type == "auction_started":
			GameManager.on_auction_started(data)
		elif msg_type == "auction_action":
			GameManager.on_auction_action_received(multiplayer.get_remote_sender_id(), data)
		elif msg_type == "auction_ended":
			GameManager.on_auction_ended(data)
		elif msg_type == "breakthrough_request":
			GameManager.request_breakthrough(multiplayer.get_remote_sender_id())
		elif msg_type == "breakthrough_feedback":
			GameManager.on_breakthrough_feedback(data)
		elif msg_type == "tribulation_choice":
			GameManager.settle_tribulation(multiplayer.get_remote_sender_id(), str(data.get("choice", "")))
		elif msg_type == "tribulation_result":
			GameManager.on_tribulation_result(data)
		elif msg_type == "battle_action":
			GameManager.settle_battle_action(multiplayer.get_remote_sender_id(), str(data.get("action", "")))
		elif msg_type == "battle_update":
			GameManager.on_battle_update(data)
		elif msg_type == "battle_end":
			GameManager.on_battle_end(data)
		elif msg_type == "duel_action":
			GameManager.settle_duel_action()
		elif msg_type == "duel_data":
			GameManager.on_duel_data(data)
		elif msg_type == "duel_update":
			GameManager.on_duel_update(data)
		elif msg_type == "duel_finished":
			GameManager.on_duel_finished(data)
		elif msg_type == "duel_final_choice":
			GameManager.on_duel_final_choice_received(multiplayer.get_remote_sender_id(), data)
		elif msg_type == "duel_final_choice_result":
			GameManager.on_duel_final_choice_result(data)
		message_received.emit(msg_type, data)


func _on_connected_to_server() -> void:
	connected = true
	connection_success.emit()


func _on_connection_failed() -> void:
	connected = false
	connection_failed.emit()


func _on_peer_connected(id: int) -> void:
	connected = true
	player_connected.emit(id)
	if not is_host:
		connection_success.emit()


func _on_peer_disconnected(id: int) -> void:
	connected = false
	player_disconnected.emit(id)

	var current_scene := get_tree().current_scene
	if current_scene != null:
		var dialog := AcceptDialog.new()
		dialog.title = "连接断开"
		dialog.dialog_text = "对方已断开连接"
		current_scene.add_child(dialog)
		dialog.popup_centered()
		await dialog.confirmed
		dialog.queue_free()

	GameManager.transition_to_scene("res://scenes/main_menu.tscn")
