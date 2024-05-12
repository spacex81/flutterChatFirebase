import 'dart:async';

import 'package:client/core/domain/entities/user_public.dart';
import 'package:client/core/domain/services/users_service.dart';
import 'package:client/features/chat/domain/entities/conversation.dart';
import 'package:client/features/chat/domain/services/messages_service.dart';
import 'package:client/features/groups/domain/services/groups_service.dart';
import 'package:client/injection_container.dart';
import 'package:flutter/foundation.dart';

class AddParticipantsController {
  final String? conversationId;
  Conversation? conversation;

  bool _initialized = false;

  final ValueNotifier<bool> notifyIsLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> notifySuccess = ValueNotifier<bool>(false);

  final ValueNotifier<Map<String, (UserPublic, bool)>> notifySelectedUsers =
      ValueNotifier<Map<String, (UserPublic, bool)>>({});

  StreamSubscription<List<UserPublic>>? listeningToAllUsersExceptLogged;
  StreamSubscription<Conversation>? listeningToConversation;

  List<UserPublic>? _users;
  // this holds a list of users who needs to be added to the conversation group
  // what is confusing about this data structure is that
  // it holds every users that is clicked more than once, instead of storing only users that needs to be added
  // which means, if you click one user twice(which means check and un-check) it still remains in this data struct
  // so we use 'bool' to filter out the multiple clicked but don't supposed to be added users
  final Map<String, bool> selectedUsers = {};

  AddParticipantsController({this.conversationId});

  bool get initialized => _initialized;

  String get title {
    if (notifyIsLoading.value) {
      return "loading...";
    }
    if (conversation != null) {
      return 'Editing ${conversation!.group!.title}';
    }
    return 'Creating a New Group';
  }

  void initialize() {
    _initialized = true;
    notifyIsLoading.value = true;

    // we receive live 'Conversation' info and 'List<UserPublic>' info from firestore
    // whenver we receive live information about 'Conversation' or 'List<UserPublic>' from the firestore
    // we run '_setUsers'
    startListeningToConversation(conversationId!);
    listeningToAllUsersExceptLogged = getIt
        .get<UsersService>()
        .streamAllUsersExceptLogged()
        .listen((List<UserPublic> users) async {
      _users = users;
      _setUsers();
    });
  }

  void dispose() {
    notifyIsLoading.dispose();
    notifySuccess.dispose();

    listeningToAllUsersExceptLogged?.cancel();
    listeningToConversation?.cancel();
  }

  selectUserChanged(String uid, bool selected) {
    // update 'selectedUsers'
    selectedUsers[uid] = selected;
    // re-render ui
    _notifySelectedUsers();
  }

  void _setUsers() {
    if (conversation != null && _users != null) {
      notifyIsLoading.value = true;
      for (final user in outsideGroupUsers!) {
        // 'selectedUsers' stores all of the users who are currently not part of this group
        // and set picked value to 'false'
        selectedUsers[user.uid] = selectedUsers[user.uid] ?? false;
      }
      List<String> deleteUids = [];
      // if 'selectedUids' contains users who are not included in 'outsideGroupUsers' than remove it
      for (final uid in selectedUsers.keys) {
        if (!outsideGroupUsers!.any((element) => element.uid == uid)) {
          deleteUids.add(uid);
        }
      }
      for (final uid in deleteUids) {
        selectedUsers.remove(uid);
      }

      // after changing the 'selectedUsers', notify it
      _notifySelectedUsers();

      notifyIsLoading.value = false;
    }
  }

  void startListeningToConversation(String conversationId) {
    // stream subscription for conversation
    // 'listeningToConversation' is used to unsubscribe
    // actual logic happens in the listener
    listeningToConversation = getIt
        .get<MessagesService>()
        .conversationStream(conversationId: conversationId)
        .listen((conversation) {
      this.conversation = conversation;
      // whenever we receive fresh conversation, run '_setUsers'
      _setUsers();
    });
  }

  void _notifySelectedUsers() {
    notifySelectedUsers.value = selectedUsers.map((uid, selected) => MapEntry(
        uid,
        ((_users!.firstWhere((element) => element.uid == uid)), selected)));
  }

  Future<int> addParticipants() {
    final Completer<int> completer = Completer();
    final entries =
        selectedUsers.entries.where((element) => element.value).toList();
    int pending = entries.length;
    for (final entry in entries) {
      getIt
          .get<GroupsService>()
          .addParticipant(
              conversationId: conversation!.conversationId, uid: entry.key)
          .then((_) {
        pending--;
        if (pending == 0) {
          completer.complete(entries.length);
        }
      });
    }
    selectedUsers.clear();
    return completer.future;
  }

  // only show the users that is not already included to the group
  List<UserPublic>? get outsideGroupUsers => _users
      ?.where((user) => !conversation!.participants.contains(user.uid))
      .toList();
}
