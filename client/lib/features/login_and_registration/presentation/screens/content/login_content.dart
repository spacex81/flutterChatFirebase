import 'package:client/core/domain/entities/failures/failure.dart';
import 'package:client/core/domain/services/auth_service.dart';
import 'package:client/core/presentation/widgets/button_widget.dart';
import 'package:client/core/presentation/widgets/my_custom_text_form_field.dart';
import 'package:client/core/utils/validators.dart';
import 'package:client/features/login_and_registration/domain/entities/failures/invalid_email_failure.dart';
import 'package:client/features/login_and_registration/domain/entities/failures/invalid_password_failure.dart';
import 'package:client/features/login_and_registration/presentation/screens/content/register_content.dart';
import 'package:client/features/login_and_registration/presentation/screens/login_and_registration_screen.dart';
import 'package:client/features/login_and_registration/presentation/screens/widgets/animated_icon.dart';
import 'package:client/injection_container.dart';
import 'package:client/screen_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../widgets/separator.dart';

class LoginContent extends StatefulWidget
    implements LoginAndRegistrationContent {
  late final ValueNotifier<String?> notifyError;
  final GoToLoginCallback gotoLogin;
  final String? email;

  LoginContent({
    Key? key,
    ValueNotifier<String?>? notifyError,
    required this.gotoLogin,
    this.email,
  }) : super(key: key) {
    this.notifyError = notifyError ?? ValueNotifier<String?>(null);
  }

  @override
  State<LoginContent> createState() => _LoginContentState();

  @override
  String get title => "Sign in to your account";

  @override
  LoginAndRegistrationContent get nextContent => RegisterContent(
        notifyError: notifyError,
        goToLogin: gotoLogin,
      );
}

class _LoginContentState extends State<LoginContent> {
  final ValueNotifier<bool> notifyIsLoading = ValueNotifier<bool>(false);
  final loginFormKey = GlobalKey<FormState>();

  ValueNotifier<String?> notifyEmailError = ValueNotifier<String?>(null);
  ValueNotifier<String?> notifyPasswordError = ValueNotifier<String?>(null);
  ValueNotifier<bool> notifySuccess = ValueNotifier<bool>(false);

  late final TextEditingController emailController =
      TextEditingController(text: widget.email ?? "");
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    notifyIsLoading.dispose();
    notifyEmailError.dispose();
    notifyPasswordError.dispose();
    notifySuccess.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: loginFormKey,
        child: Column(
          children: [
            MyCustomTextFormField(
              controller: emailController,
              hintText: 'Your email',
              validator: validateEmail,
              keyboardType: TextInputType.emailAddress,
              notifyError: notifyEmailError,
              prefixIcon: MyAnimatedIcon(
                icon: Icons.email_rounded,
                notifySuccess: notifySuccess,
                notifyError: notifyEmailError,
              ),
            ),
            separator,
            MyCustomTextFormField(
              controller: passwordController,
              hintText: 'Your password',
              validator: validateRequired,
              obscureText: true,
              notifyError: notifyPasswordError,
              keyboardType: TextInputType.text,
              prefixIcon: MyAnimatedIcon(
                icon: Icons.key,
                notifySuccess: notifySuccess,
                notifyError: notifyPasswordError,
              ),
            ),
            separator,
            ValueListenableBuilder(
                valueListenable: notifyIsLoading,
                builder: (__, isLoading, _) {
                  return ValueListenableBuilder(
                      valueListenable: notifySuccess,
                      builder: (__, success, _) {
                        return ButtonWidget(
                          text: success ? "SUCCESS" : "LOGIN",
                          icon: success ? Icons.check : null,
                          isLoading: isLoading && !success,
                          onPressed: success
                              ? null
                              : () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  widget.notifyError.value = null;
                                  notifyEmailError.value =
                                      notifyPasswordError.value = null;

                                  if (loginFormKey.currentState!.validate()) {
                                    loginFormKey.currentState!.save();
                                    notifyIsLoading.value = true;
                                    getIt<AuthService>()
                                        .signInWithEmailAndPassword(
                                            email: emailController.text,
                                            password: passwordController.text)
                                        .then((res) {
                                      notifyIsLoading.value = false;
                                      res.fold(loginFailed,
                                          (_) => loginSuccessfully(context));
                                    });
                                  }
                                },
                        );
                      });
                }),
          ],
        ));
  }

  void loginFailed(Failure failure) {
    if (Failure is InvalidEmailFailure) {
      notifyEmailError.value = failure.error;
    } else if (Failure is InvalidPasswordFailure) {
      notifyPasswordError.value = failure.error;
    } else {
      widget.notifyError.value = failure.error;
    }
  }

  Future<void> loginSuccessfully(BuildContext context) async {
    assert(getIt.get<AuthService>().loggedUid != null);
    notifySuccess.value = true;
    Future.delayed(const Duration(milliseconds: 850), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          ScreenRoutes.conversations, (route) => false);
      //getIt.get<NotificationsService>().start();
    });
  }
}
