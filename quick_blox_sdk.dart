import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:quickblox_sdk/auth/module.dart';
import 'package:quickblox_sdk/chat/constants.dart';
import 'package:quickblox_sdk/conference/constants.dart';
import 'package:quickblox_sdk/models/qb_conference_rtc_session.dart';
import 'package:quickblox_sdk/models/qb_event.dart';
import 'package:quickblox_sdk/models/qb_rtc_session.dart';
import 'package:quickblox_sdk/models/qb_session.dart';
import 'package:quickblox_sdk/models/qb_user.dart';
import 'package:quickblox_sdk/notifications/constants.dart';
import 'package:quickblox_sdk/push/constants.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'package:quickblox_sdk/webrtc/constants.dart';


// String appId = "";
// String authKey = "";
// String authSecret = "";
// String accountKey = "";

class QuickBloxSDK {
  
  static String password = "Password@1";
  static Map<String, Object> userInfo = {};

  static Future<void> initSDK() async {
    //Initialize SDK
    try {
      await QB.settings.init(
          appId,
          authKey,
          authSecret,
          accountKey);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Init SDK Exception ===> ${e.toString()}');
      }
    }
  }

  static Future<void> createUser(String? username, String? fullName) async {
    //Sign up user
    try {
      QBUser? user = await QB.users
          .createUser(username.toString(), password, fullName: fullName);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Create User Exception ===> ${e.toString()}');
      }
    }
  }

  static Future<QBUser?> loginUser(
      String? username, BuildContext context) async {
    //Log in user
    try {
      QBLoginResult result = await QB.auth.login(username!, password);
      QBUser qbUser = result.qbUser!;
      QBSession? qbSession = result.qbSession;
      return qbUser;
    } on PlatformException catch (e) {
      AppToast.showMessage(context, e.toString());
      if (kDebugMode) {
        print('Login User Exception ===> ${e.toString()}');
      }
      return null;
    }
  }

  static Future<void> connectToChat(int? id) async {
    //Connect to Chat server
    try {
      await QB.chat.connect(id!, password);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Connect Chat Exception ===> ${e.toString()}');
      }
    }
  }

  static Future<void> initWebRTC() async {
    //Initialize WebRTC
    try {
      await QB.webrtc.init();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Init WebRTC Exception ===> ${e.toString()}');
      }
    }
  }

  static Future<QBRTCSession?> initCall(
      int id,
      BuildContext context,
      String callType,
      int sessionType,
      String userId,
      String? fullName,
      bool? favorite) async {
    // Session types
    // QBRTCSessionTypes.VIDEO
    // QBRTCSessionTypes.AUDIO

    List<int> opponentIds = [id, 23521];
    userInfo['callType'] = callType;
    userInfo['userId'] = userId;
    userInfo['name'] = fullName.toString();
    userInfo['favorite'] = favorite.toString();
    //Initiate a call
    try {
      QBRTCSession? session =
          await QB.webrtc.call(opponentIds, sessionType, userInfo: userInfo);
      return session;
    } on PlatformException catch (e) {
      AppToast.showMessage(context, e.toString());
      if (kDebugMode) {
        print('Init Call Exception ===> ${e.toString()}');
      }
      return null;
    }
  }

  static Future<void> acceptCall(String sessionId) async {
    //Accept a call
    try {
      QBRTCSession? session =
          await QB.webrtc.accept(sessionId, userInfo: userInfo);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Accept Call Exception ===> ${e.toString()}');
      }
    }
  }

  static Future<void> rejectCall(String sessionId) async {
    //Reject a call
    try {
      QBRTCSession? session =
          await QB.webrtc.reject(sessionId, userInfo: userInfo);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Reject Call Exception ===> ${e.toString()}');
      }
    }
  }

  static Future<void> endCall(String sessionId) async {
    //End a call
    try {
      QBRTCSession? session =
          await QB.webrtc.hangUp(sessionId, userInfo: userInfo);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('End Call Exception ===> ${e.toString()}');
      }
    }
  }

  static Future<void> logout() async {
    //Log out user
    try {
      await QB.auth.logout();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Logout Exception ===> ${e.toString()}');
      }
    }
  }

  static Future<void> switchAudio(int output) async {
    // Audio output
    // EARSPEAKER = 0
    // LOUDSPEAKER = 1
    // HEADPHONES = 2
    // BLUETOOTH = 3

    try {
      await QB.webrtc.switchAudioOutput(output);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Switch Audio Exception ===> ${e.toString()}');
      }
    }
  }

  static Future<void> enableAudio(bool value, String? sessionId) async {
    try {
      await QB.webrtc.enableAudio(sessionId!, enable: value);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Mute Audio Exception ===> ${e.toString()}');
      }
    }
  }

  static Future<void> answerTime() async {
    //Interval in seconds
    int interval = 30;
    try {
      await QB.rtcConfig.setAnswerTimeInterval(interval);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Mute Audio Exception ===> ${e.toString()}');
      }
    }
  }

  static Future<void> dialingTime() async {
    //Interval in seconds
    int interval = 30;

    try {
      await QB.rtcConfig.setDialingTimeInterval(interval);
    } on PlatformException catch (e) {
      // Some error occurred, look at the exception message for more details
    }
  }

  static Future<void> subscribePushNotifications() async {
    
    //Push Channels
    //QBPushChannelNames.GCM;
    //QBPushChannelNames.APNS;
    //QBPushChannelNames.APNS_VOIP;
    //QBPushChannelNames.EMAIL;

    String channelName = "";
    String? token = "";
    try {
      if (Platform.isAndroid) {
        token = await FirebaseMessaging.instance.getToken();
        channelName = QBPushChannelNames.GCM;
      } else if (Platform.isIOS) {
        token = await FirebaseMessaging.instance.getAPNSToken();
        channelName = QBPushChannelNames.APNS;
      }
      await QB.subscriptions.create(token!, channelName);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Subscribe Notification Exception ===> ${e.toString()}');
      }
    }
  }

  static Future<void> sendPushNotifications(
      String opponentId,
      String sessionId,
      String callType,
      int sessionType,
      String userId,
      String? fullName,
      bool? favorite) async {

    //Event Types
    //QBNotificationEventTypes.FIXED_DATE;
    //QBNotificationEventTypes.PERIOD_DATE;
    //QBNotificationEventTypes.ONE_SHOT;

    //Notification Event Types
    //QBNotificationTypes.PUSH;
    //QBNotificationTypes.EMAIL;

    //Notification Push Types
    //QBNotificationPushTypes.APNS
    //QBNotificationPushTypes.APNS_VOIP
    //QBNotificationPushTypes.GCM
    //QBNotificationPushTypes.MPNS

    String eventType = QBNotificationEventTypes.ONE_SHOT;
    String notificationEventType = QBNotificationTypes.PUSH;
    int? pushType;
    int senderId = int.parse(
        AppPreference.getString(AppStrings.quickBloxUserId).toString());

    if (Platform.isAndroid) {
      pushType = QBNotificationPushTypes.GCM;
    } else if (Platform.isIOS) {
      pushType = QBNotificationPushTypes.APNS;
    }

    Map<String, Object> payload = Map();
    payload["message"] = "test";
    payload["type"] = "call";
    try {
      List<QBEvent?> events = await QB.events.create(
          recipientsIds: [opponentId.toString()],
          eventType,
          notificationEventType,
          senderId,
          payload,
          pushType: pushType);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Push Notification Exception ===> ${e.toString()}');
      }
    }
  }

  static Future<void> receivePushNotifications(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((message) {
      LocalNotificationService.display(message);
    });
  }

  static Future<void> unsubscribePushNotifications() async {
    try {
      await QB.subscriptions.remove(int.parse(
          AppPreference.getString(AppStrings.quickBloxUserId).toString()));
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Unsubscribe Push Notification Exception ===> ${e.toString()}");
      }
    }
  }

  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    LocalNotificationService.display(message);
  }

  static Future<QBSession?> checkSession() async {
    //Get session
    try {
      QBSession? session = await QB.auth.getSession();
      return session;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Session Exception ===> ${e.toString()}");
      }
    }
    return null;
  }

  static Future<QBSession?> disconnectChat() async {
    //Disconnect from Chat server
    try {
      await QB.chat.disconnect();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Disconnect Chat Exception ===> ${e.toString()}");
      }
    }
  }

  static Future<QBSession?> release() async {
    //Release Webrtc
    try {
      await QB.webrtc.release();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Release Webrtc Exception ===> ${e.toString()}");
      }
    }
  }

  static Future<void> switchCamera(String sessionId) async {
    //switch camera
    try {
      await QB.webrtc.switchCamera(sessionId);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Switch Camera Exception ===> ${e.toString()}");
      }
    }
  }

  static Future<void> switchVideo(bool enable, String sessionId) async {
    //switch video
    try {
      await QB.webrtc.enableVideo(sessionId, enable: enable);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Switch Video Exception ===> ${e.toString()}");
      }
    }
  }

  static Future<void> initConference() async {
    //init conference call
    try {
      String conferenceServer = "your_conference_server";
      await QB.conference.init(conferenceServer);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Init Conference Exception ===> ${e.toString()}");
      }
    }
  }

  static Future<QBConferenceRTCSession?> createConferenceSession(
      String? dialogId) async {
    //create conference session

    // Session Types
    // QBConferenceSessionTypes.VIDEO
    // QBConferenceSessionTypes.AUDIO

    QBConferenceRTCSession? session;

    int sessionType = QBConferenceSessionTypes.VIDEO;

    try {
      session = await QB.conference.create(dialogId!, sessionType);
      return session!;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Create Conference Session Exception ===> ${e.toString()}");
      }
    }
    return null;
  }

  static Future<void> joinConferenceSession(String sessionId) async {
    //join conference session

    try {
      List<int?> participants = await QB.conference.joinAsPublisher(sessionId);
      for (int i = 0; i < participants.length; i++) {
        int userId = participants[i]!;
        subscribeToParticipant(sessionId, userId);
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Join Conference Session Exception ===> ${e.toString()}");
      }
    }
  }

  static Future<void> subscribeToParticipant(
      String sessionId, int userId) async {
    //subscribe participant

    try {
      await QB.conference.subscribeToParticipant(sessionId, userId);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Subscribe Participant Exception ===> ${e.toString()}");
      }
    }
  }

  static Future<void> unSubscribeToParticipant(
      String sessionId, int userId) async {
    //unsubscribe participant

    String sessionId = "114846dfsJKJDdls8dsfj2029";
    int userid = 567527986;

    try {
      await QB.conference.unsubscribeFromParticipant(sessionId, userId);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Unsubscribe Participant Exception ===> ${e.toString()}");
      }
    }
  }

  static Future<void> leaveVideoRoom(String sessionId) async {
    //leave video conference

    try {
      await QB.conference.leave(sessionId);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Leave Room Exception ===> ${e.toString()}");
      }
    }
  }
}
