import 'dart:async';

import 'package:client/features/chat/domain/entities/detailed_conversation.dart';

class DetailedConversationListController {
  // final int? messagesLimitForEachConversation;
  late final StreamController<List<DetailedConversation>> _streamController;
}
