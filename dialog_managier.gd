extends Node

signal message_sent(author: String, message: String)

func send_message(author: String = '1', msg = '') -> void:
	message_sent.emit(author, msg)
