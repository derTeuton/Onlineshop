extends Node

@export var gender_catalog : PackedScene
@export var ghetto : PackedScene
@export var port : int = 9999

@onready var menu : PanelContainer = $"Hauptmenü"
@onready var GhettoIP : LineEdit = $"Hauptmenü/HSplitContainer/Joint/VBoxContainer/GhettoIP"
@onready var GhettoInstance : Node = $GhettoInstance
@onready var SpawnPoint : Node3D = $SpawnPunkt
@onready var DisplayPublicIP : Label = $DisplayPublicIP

# Server
func _on_horst_button_pressed():
	upnp_setup()
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(9999)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_disconnected.connect(remove_player)

	load_game()

#  Client - Call this in the `ready()` function and set the public IP address of your server for automatic joining
func _on_joint_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(GhettoIP.text, port)
	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(load_game) # Loads only if connected to a server
	multiplayer.server_disconnected.connect(server_offline)

func load_game():
	menu.hide()
	GhettoInstance.add_child(ghetto.instantiate())
	add_player.rpc(multiplayer.get_unique_id())

@rpc("any_peer") # Add "call_local" if you also want to spawn a player from the server
func add_player( _id : int ):
	var gender_catalog_instance : Node = gender_catalog.instantiate()
	var player_instance = gender_catalog_instance.find_child(menu.GENDER[menu._joint_gender])
	player_instance.name = str(_id) #+ menu._joint_name
	SpawnPoint.add_child(player_instance)

@rpc("any_peer")
func remove_player( _id : int ):
	if SpawnPoint.get_node(str(_id) ):#+ menu._joint_name):
		SpawnPoint.get_node(str(_id)).queue_free()

func server_offline():
	menu.show()
	if GhettoInstance.get_child(0):
		GhettoInstance.get_child(0).queue_free()

# Set up port mapping for online multiplayer functionality
func upnp_setup():
	var upnp = UPNP.new()
	print(upnp.discover())
	# upnp.discover()
	upnp.add_port_mapping(port)
	DisplayPublicIP.text = "Server IP: " + upnp.query_external_address()
