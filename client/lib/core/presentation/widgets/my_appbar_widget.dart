import 'package:client/core/presentation/widgets/center_content_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const double _height = 50;
const double _leftIconSize = 28;
const double _leftIconPaddingSize = 2;

class MyAppbarWidget extends PreferredSize {
  MyAppbarWidget(
      {super.key,
      required BuildContext context,
      Widget? child,
      bool withBackground = true})
      : super(
          preferredSize: const Size(double.infinity, _height),
          child: Container(
            color: Colors.blue[800]!,
            child: SafeArea(
              child: Container(
                decoration: !withBackground
                    ? null
                    : BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue[900]!,
                            Colors.blue[800]!,
                            Colors.blue[900]!,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.blue[900]!,
                              offset: const Offset(0, 0),
                              spreadRadius: 2,
                              blurRadius: 1)
                        ],
                      ),
                child: CenterContentWidget(
                  decoration: BoxDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      children: [
                        FutureBuilder(
                          future:
                              Future.delayed(const Duration(milliseconds: 250)),
                          builder: (context, _) {
                            if (Navigator.of(context).canPop()) {
                              return InkWell(
                                child: Ink(
                                  child: const Icon(
                                      Icons.keyboard_arrow_left_rounded,
                                      color: Colors.white,
                                      size: _leftIconSize),
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                        Expanded(
                            child: SizedBox(
                          height: _height,
                          child: Center(
                            child: child,
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
}
