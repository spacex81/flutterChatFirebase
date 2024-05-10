import 'package:flutter/material.dart';

class MyCustomTextFormField extends StatefulWidget {
  final FormFieldSetter<String>? onSaved;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  late final ValueNotifier<String?>? notifyError;
  String? initialValue;

  MyCustomTextFormField({
    Key? key,
    this.onSaved,
    this.keyboardType,
    this.validator,
    this.initialValue,
    this.notifyError,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.obscureText = false,
  }) : super(key: key);

  @override
  State<MyCustomTextFormField> createState() => _MyCustomTextFormFieldState();
}

class _MyCustomTextFormFieldState extends State<MyCustomTextFormField> {
  ValueNotifier<String?>? internalNotifyError;
  void Function(String?)? onSaved;
  TextEditingController? internalController;
  FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    const inputStyle = TextStyle(color: Colors.indigo, fontSize: 16);
    const borderRadius = BorderRadius.all(Radius.circular(23));
    const border = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    );

    return FormField<String>(
      initialValue: (widget.controller?.text ?? internalController?.text)!,
      onSaved: onSaved,
      validator: validator,
      builder: (fieldState) {
        return ValueListenableBuilder<String?>(
            valueListenable: (widget.notifyError ?? internalNotifyError)!,
            builder: (context, validatorError, _) {
              final hasError =
                  validatorError != null && validatorError.isNotEmpty == true;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration:
                        BoxDecoration(borderRadius: borderRadius, boxShadow: [
                      BoxShadow(
                        color: (hasError ? Colors.red : Colors.indigo)
                            .withOpacity(0.55),
                        spreadRadius: 2,
                        blurRadius: 1,
                        offset: const Offset(0, 0),
                      )
                    ]),
                    child: TextField(
                      textInputAction: TextInputAction.go,
                      controller: (widget.controller ?? internalController)!,
                      keyboardType: widget.keyboardType,
                      obscureText: widget.obscureText,
                      scrollPadding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom +
                              (inputStyle.fontSize ?? 16) * 5),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        prefixText: '  ',
                        isCollapsed: true,
                        hintStyle:
                            TextStyle(color: Colors.indigo.withOpacity(.5)),
                        hintText: widget.hintText,
                        fillColor: Colors.white,
                        focusedBorder: border,
                        enabledBorder: border,
                        errorBorder: border,
                        disabledBorder: border,
                        border: border,
                        contentPadding: const EdgeInsets.symmetric(vertical: 5),
                        focusedErrorBorder: border,
                        prefixIcon: widget.prefixIcon == null
                            ? null
                            : Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: widget.prefixIcon,
                              ),
                        suffixIcon: widget.suffixIcon,
                        filled: true,
                      ),
                      style: inputStyle,
                    ),
                  ),
                  if (hasError)
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 7),
                      child: Text(validatorError,
                          style: const TextStyle(
                              color: Color(0xffff8c8c),
                              fontWeight: FontWeight.w600,
                              letterSpacing: .7)),
                    )
                ],
              );
            });
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.notifyError == null) {
      internalNotifyError = ValueNotifier<String?>(null);
    }
    if (widget.controller == null) {
      internalController =
          TextEditingController(text: widget.initialValue ?? "");
    }

    onSaved = widget.onSaved == null
        ? null
        : (_) {
            return widget
                .onSaved!((widget.controller ?? internalController)!.text);
          };

    String? lastValidateError;
    // handle form field validation based on changes detected via a 'ValueNotifier'
    validator = (_) {
      if (widget.notifyError != null) {
        // if error state has changed, update the error state
        if (widget.notifyError!.value != lastValidateError) {
          return lastValidateError = widget.notifyError!.value;
        }
        // if error state is the same, get the text input value and check if it is valid
        return lastValidateError = widget.notifyError!.value =
            (widget.validator ??
                (_) => null)((widget.controller ?? internalController)!.text);
      }
      return null;
    };
  }

  @override
  void dispose() {
    internalNotifyError?.dispose();
    internalController?.dispose();
    super.dispose();
  }
}
