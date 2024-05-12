import 'package:client/features/chat/domain/entities/conversation.dart';
import 'package:client/features/chat/domain/services/messages_service.dart';
import 'package:client/features/groups/domain/services/groups_service.dart';
import 'package:client/features/groups/presentation/screens/add_participants_screen.dart';
import 'package:client/injection_container.dart';
import 'package:client/main.dart';
import 'package:client/screen_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CreateGroupOrEditTitleController {
  String? editExistingConversationId;
  bool _initialized = false;

  final GlobalKey<FormState> formKey;
  final ValueNotifier<bool> notifyIsLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> notifySuccess = ValueNotifier<bool>(false);
  ValueNotifier<String?> notifyGroupsNameError = ValueNotifier<String?>(null);

  Conversation? conversation;

  final TextEditingController groupsNameController;

  CreateGroupOrEditTitleController(
      {required this.formKey, required this.groupsNameController});

  bool get initialized => _initialized;

  String get title {
    if (notifyIsLoading.value) {
      return "loading...";
    }
    if (conversation != null) {
      return conversation!.group!.title;
    }
    return 'Creating a New Group';
  }

  void Function()? get onPressedCreateNewGroup {
    return notifySuccess.value || notifyIsLoading.value
        ? null
        : () async {
            notifyIsLoading.value = notifySuccess.value = false;

            FocusManager.instance.primaryFocus?.unfocus();

            if (formKey.currentState!.validate()) {
              // if the group title input is valid, display loading ui and
              // start creating new group in firestore
              notifyGroupsNameError.value = null;
              formKey.currentState!.save();
              notifyIsLoading.value = true;

              conversation = await getIt
                  .get<GroupsService>()
                  .createGroup(groupTitle: groupsNameController.text);
              groupsNameController.text = conversation!.group!.title;

              // now the group conversation creation is complete,
              // change the loading and success state variables
              notifyIsLoading.value = false;
              notifySuccess.value = true;

              // after 1.5 seconds, reset the state variable and move to group participants selection page
              Future.delayed(const Duration(milliseconds: 1500), () {
                notifySuccess.value = false;

                print(
                    'conversation!.conversationId: ${conversation!.conversationId}');

                // ERROR
                Navigator.of(navigatorKey.currentContext!)
                    .pushNamedAndRemoveUntil(ScreenRoutes.addGroupParticipants,
                        (route) => route.isFirst,
                        arguments: AddGroupParticipantsScreenArgs(
                            conversationId: conversation!.conversationId));
              });
            }
          };
  }

  void initialize({String? editExistingConversationId}) {
    assert(!_initialized);
    _initialized = true;
    this.editExistingConversationId = editExistingConversationId;
    // while we fetch the conversation information, we are going to display the loading ui
    notifyIsLoading.value = editExistingConversationId != null;
    if (editExistingConversationId != null) {
      getIt
          .get<MessagesService>()
          .getConversationById(conversationId: editExistingConversationId)
          .then((conversation) {
        this.conversation = conversation;
        groupsNameController.text = conversation!.group!.title;
        // set loading to false after loading the remove conversation information
        notifyIsLoading.value = false;
      });
    }
  }

  void dispose() {
    notifyIsLoading.dispose();
    notifySuccess.dispose();
    notifyGroupsNameError.dispose();
  }
}
