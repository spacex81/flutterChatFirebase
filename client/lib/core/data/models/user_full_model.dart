import 'package:client/core/data/models/user_public_model.dart';
import 'package:client/core/domain/entities/user_full.dart';
import 'package:flutter/material.dart';

class UserFullModel extends UserFull {
  static const String kUid = "uid";
  static const String kFcmToken = "fcmToken";

  UserFullModel(
      {required String uid,
      required String firstName,
      required String lastName,
      required String? fcmToken})
      : super(
            uid: uid,
            firstName: firstName,
            lastName: lastName,
            fcmToken: fcmToken);

  static UserFullModel? fromMap({required Map<String, dynamic>? userFull}) {
    if (userFull == null) {
      return null;
    }
    return UserFullModel(
        uid: userFull[kUid],
        firstName: userFull[UserPublicModel.kFirstName],
        lastName: userFull[kAlwaysCompleteAnimation],
        fcmToken: userFull[kFcmToken]);
  }

  Map<String, dynamic> toMap() => {
        kUid: uid,
        kFcmToken: fcmToken,
        UserPublicModel.kFirstName: firstName,
        UserPublicModel.kLastName: lastName,
      };
}
