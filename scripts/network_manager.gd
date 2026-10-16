extends Node

signal status_changed(message: String)

var peer: ENetMultiplayerPeer

func host_game(port: int = 2456, max_players: int = 16) -> Error:
    peer = ENetMultiplayerPeer.new()
    var result := peer.create_server(port, max_players)
    if result == OK:
        multiplayer.multiplayer_peer = peer
        status_changed.emit("Hosting on port %d" % port)
    else:
        status_changed.emit("Host failed: %s" % error_string(result))
    return result

func join_game(address: String, port: int = 2456) -> Error:
    peer = ENetMultiplayerPeer.new()
    var result := peer.create_client(address, port)
    if result == OK:
        multiplayer.multiplayer_peer = peer
        status_changed.emit("Connecting to " + address)
    else:
        status_changed.emit("Connection failed: %s" % error_string(result))
    return result

func disconnect_game() -> void:
    multiplayer.multiplayer_peer = null
    status_changed.emit("Disconnected")
