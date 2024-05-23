extends Node

@export var gender_catalog : PackedScene
@export var ghetto : PackedScene

@export var address : String = "localhost"
@export var port : int = 9999

@onready var menu : PanelContainer = $"Hauptmenü"
@onready var GhettoIP : LineEdit = $"Hauptmenü/HSplitContainer/Joint/VBoxContainer/GhettoIP"
@onready var GhettoInstance : Node = $GhettoInstance
@onready var SpawnPoint : Node3D = $SpawnPunkt
@onready var DisplayPublicIP : Label = $DisplayPublicIP

var multiplayer_peer = ENetMultiplayerPeer.new()

var connected_peer_ids = []
var local_player_character

# Server
func _on_horst_button_pressed():
	multiplayer_peer.create_server(port)
	multiplayer.multiplayer_peer = multiplayer_peer
	DisplayPublicIP.text = "Server: " + str(multiplayer.get_unique_id())
	#multiplayer.peer_disconnected.connect(remove_player)
	
	load_game()
	
	multiplayer_peer.peer_connected.connect(
		func(new_peer_id):
			await get_tree().create_timer(1).timeout
			rpc("add_newly_connected_player_character", new_peer_id)
			rpc_id(new_peer_id, "add_previously_connected_player_characters", connected_peer_ids)
			add_player(new_peer_id)
	)

#  Client - Call this in the `ready()` function and set the public IP address of your server for automatic joining
func _on_joint_button_pressed():
	multiplayer.connected_to_server.connect(load_game)
	multiplayer_peer.create_client(address, port) #GhettoIP.text, port)
	multiplayer.multiplayer_peer = multiplayer_peer
	DisplayPublicIP.text = "Client: " + str(multiplayer.get_unique_id())
	
	 # Loads only if connected to a server
	#multiplayer.server_disconnected.connect(server_offline)

func load_game():
	menu.hide()
	GhettoInstance.add_child(ghetto.instantiate())
	#add_player.rpc(multiplayer.get_unique_id())

func add_player( _id : int ):
	var gender_catalog_instance : Node = gender_catalog.instantiate()
	var player_instance : CharacterBody3D = gender_catalog_instance.find_child(menu.GENDER.find_key(menu._joint_gender))
	gender_catalog_instance.remove_child(player_instance)
	gender_catalog_instance.queue_free()
	player_instance.set_multiplayer_authority(_id)
	#player_instance.name = str(_id) #+ menu._joint_name
	SpawnPoint.add_child(player_instance)
	if _id == multiplayer.get_unique_id():
		local_player_character = player_instance

@rpc
func add_newly_connected_player_character(new_peer_id):
	add_player(new_peer_id)

@rpc
func add_previously_connected_player_characters(peer_ids):
	for peer_id in peer_ids: add_player(peer_id)


#@rpc("any_peer")
#func remove_player( _id : int ):
	#if SpawnPoint.get_node(str(_id) ):#+ menu._joint_name):
		#SpawnPoint.get_node(str(_id)).queue_free()
#
#func server_offline():
	#menu.show()
	#if GhettoInstance.get_child(0):
		#GhettoInstance.get_child(0).queue_free()
#
## Set up port mapping for online multiplayer functionality
#func upnp_setup():
	#var upnp = UPNP.new()
	#print(upnp.discover())
	## upnp.discover()
	#upnp.add_port_mapping(port)
	#DisplayPublicIP.text = "Server IP: " + upnp.query_external_address()
