extends Node

#region Daten

@export var gender_catalog : PackedScene
@export var ghetto : PackedScene

#endregion
#region Server Test

@export var LocalHorst : bool = true

var test_ip : String = "localhost"
var test_port : int = 8188

#endregion 
#region Hauptmenü-Quellen

@onready var menu : PanelContainer = $"Hauptmenü"
@onready var GhettoIP : LineEdit = $"Hauptmenü/HSplitContainer/Joint/VBoxContainer/HSplitContainer/GhettoIP"
@onready var GhettoPort : LineEdit = $"Hauptmenü/HSplitContainer/Joint/VBoxContainer/HSplitContainer/GhettoPort"
@onready var GhettoInstance : Node = $GhettoInstance
@onready var SpawnPoint : Node3D = $SpawnPunkt
@onready var DisplayPublicIP : Label = $DisplayPublicIP

#endregion
#region Netzwerk-Daten

var multiplayer_peer = ENetMultiplayerPeer.new()

var server_ip : String:
	get: if LocalHorst: return test_ip
	else: return GhettoIP.text
var server_port : int:
	get: if LocalHorst: return test_port
	else: return int(GhettoPort.text)

var connected_cutomer_ids = []
var local_player_character

#endregion
#region Kunden-Verwalter

## TODO server braucht keinen Spieler
func _on_horst_button_pressed():
	multiplayer.peer_disconnected.connect(remove_customer) # TODO falsifizieren
	multiplayer_peer.create_server(server_port)
	multiplayer.multiplayer_peer = multiplayer_peer
	DisplayPublicIP.text = "Verwalter: " + str(multiplayer.get_unique_id())
	
	load_ghetto()
	
	multiplayer_peer.peer_connected.connect( func(new_customer_id):
			await get_tree().create_timer(1).timeout
			rpc("add_newly_connected_customer_character", new_customer_id)
			rpc_id(new_customer_id, "add_previously_connected_customer_characters", connected_cutomer_ids)
			add_customer(new_customer_id) )
 # Loads only if connected to a server

func verwalter_offline():
	menu.show()
	if GhettoInstance.get_child(0):
		GhettoInstance.get_child(0).queue_free()

#endregion
#region Kunden kontrollieren

#  Client - Call this in the `ready()` function and set the public IP address of your server for automatic joining
func _on_joint_button_pressed():
	multiplayer.connected_to_server.connect(load_ghetto)
	multiplayer.server_disconnected.connect(verwalter_offline)
	multiplayer_peer.create_client(server_ip, server_port) #GhettoIP.text, port)
	multiplayer.multiplayer_peer = multiplayer_peer
	DisplayPublicIP.text = "Kunde: " + str(multiplayer.get_unique_id())
	
	
@rpc
func add_newly_connected_customer_character(new_customer_id):
	add_customer(new_customer_id)

@rpc
func add_previously_connected_customer_characters(customer_ids):
	for customer_id in customer_ids: add_customer(customer_id)

func add_customer( _id : int ):
	var gender_catalog_instance : Node = gender_catalog.instantiate()
	var player_instance : CharacterBody3D = gender_catalog_instance.find_child(menu.GENDER.find_key(menu._joint_gender))
	gender_catalog_instance.remove_child(player_instance)
	gender_catalog_instance.queue_free()
	player_instance.set_multiplayer_authority(_id)
	SpawnPoint.add_child(player_instance)
	if _id == multiplayer.get_unique_id():
		local_player_character = player_instance

func remove_customer( _id : int ):
	var customers : Array[Node] = SpawnPoint.get_children()
	var customer_count : int = customers.size()
	var connected_count : int = connected_cutomer_ids.size()
	if not connected_count == customer_count: for customer : Node in customers:
		if customer.get_multiplayer_authority() == _id: customer.queue_free()

#endregion

## TODO Ladebildschirm einbauen
func load_ghetto(): menu.hide(); GhettoInstance.add_child(ghetto.instantiate())

