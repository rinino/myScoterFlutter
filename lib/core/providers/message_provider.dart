import 'package:flutter_riverpod/legacy.dart';

// Definizione del tipo di messaggio
enum MessageType { error, success, info }

class UiMessage {
  final String message;
  final MessageType type;

  UiMessage({required this.message, this.type = MessageType.info});
}

// Il Notifier che gestisce il messaggio attuale
class MessageNotifier extends StateNotifier<UiMessage?> {
  MessageNotifier() : super(null);

  // Metodo per "sparare" un messaggio da ovunque
  void show(String message, {MessageType type = MessageType.info}) {
    state = UiMessage(message: message, type: type);
  }

  // Metodo per pulire lo stato dopo la visualizzazione
  void clear() {
    state = null;
  }
}

// Il provider globale
final messageProvider = StateNotifierProvider<MessageNotifier, UiMessage?>((ref) {
  return MessageNotifier();
});