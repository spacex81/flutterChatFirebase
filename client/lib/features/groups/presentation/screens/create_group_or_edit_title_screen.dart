import 'package:client/core/presentation/widgets/button_widget.dart';
import 'package:client/core/presentation/widgets/my_appbar_widget.dart';
import 'package:client/core/presentation/widgets/my_custom_text_form_field.dart';
import 'package:client/core/presentation/widgets/my_scaffold.dart';
import 'package:client/core/presentation/widgets/waves_background/waves_background.dart';
import 'package:client/core/utils/validators.dart';
import 'package:client/features/chat/presentation/controllers/users_to_talk_to_controller.dart';
import 'package:client/features/groups/presentation/controllers/create_group_or_edit_title_controller.dart';
import 'package:client/features/login_and_registration/presentation/screens/widgets/animated_icon.dart';
import 'package:client/features/login_and_registration/presentation/widgets/separator.dart';
import 'package:flutter/material.dart';

class CreateGroupOrEditTitleArgs {
  // this 'conversation id' will be used to get the original 'conversation' info
  // that I am going to edit
  final String? editExistingConversationId;
  CreateGroupOrEditTitleArgs({this.editExistingConversationId});
}

class CreateGroupOrEditTitleScreen extends StatefulWidget {
  static const String route = '/create-group-or-edit-title-screen';

  const CreateGroupOrEditTitleScreen({super.key});

  @override
  State<CreateGroupOrEditTitleScreen> createState() =>
      _CreateGroupOrEditTitleScreenState();
}

class _CreateGroupOrEditTitleScreenState
    extends State<CreateGroupOrEditTitleScreen> {
  final formKey = GlobalKey<FormState>();
  late CreateGroupOrEditTitleController controller;
  final groupsNameController = TextEditingController();

  final usersToTalkToController = UsersToTalkToController();
  CreateGroupOrEditTitleArgs? args;

  @override
  void initState() {
    super.initState();
    controller = CreateGroupOrEditTitleController(
        formKey: formKey, groupsNameController: groupsNameController);
  }

  @override
  void dispose() {
    controller.dispose();
    formKey.currentState?.dispose();
    groupsNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (controller.initialized) {
      print("args already initialized");
      return;
    }
    args = ModalRoute.of(context)!.settings.arguments
        as CreateGroupOrEditTitleArgs;
    controller.initialize(
      editExistingConversationId: args?.editExistingConversationId,
    );

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // if there is no conversation id given in the front,
    // we regard this as a group creation instead of group edit
    final isGroupCreation = args?.editExistingConversationId == null;

    return MyScaffold(
        appBar: MyAppBarWidget(
          context: context,
          withBackground: true,
          child: ValueListenableBuilder(
            valueListenable: controller.notifyIsLoading,
            builder: (context, snapshot, _) {
              return Text(
                controller.title,
                style: const TextStyle(
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
              );
            },
          ),
        ),
        background: WavesBackground(),
        body: SingleChildScrollView(
          child: Column(children: [
            SizedBox(height: MediaQuery.of(context).size.height * .1),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.indigo[700],
                  border: Border.all(color: Colors.indigo[900]!, width: 4)),
              padding: const EdgeInsets.all(30),
              child: const Icon(Icons.group, size: 72, color: Colors.white),
            ),
            const SizedBox(height: 45),
            Form(
              key: formKey,
              child: MyCustomTextFormField(
                  hintText: 'Group\'s title',
                  controller: controller.groupsNameController,
                  validator: validateRequired,
                  notifyError: controller.notifyGroupsNameError,
                  prefixIcon: MyAnimatedIcon(
                    icon: Icons.edit_note_sharp,
                  )),
            ),
            separator,
            // if (!isGroupCreation)
            if (isGroupCreation)
              ValueListenableBuilder(
                  valueListenable: controller.notifyIsLoading,
                  builder: (__, isLoading, _) {
                    return ValueListenableBuilder(
                        valueListenable: controller.notifySuccess,
                        builder: (__, success, _) {
                          return Column(
                            children: [
                              ButtonWidget(
                                  text: success ? "SUCCESS" : "CREATE GROUP",
                                  isLoading: isLoading && !success,
                                  backgroundColor: Colors.blue[300],
                                  icon: success ? Icons.check : null,
                                  onPressed:
                                      controller.onPressedCreateNewGroup),
                            ],
                          );
                        });
                  })
          ]),
        ));
  }
}
