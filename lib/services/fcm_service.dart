import 'package:firebase_messaging/firebase_messaging.dart';


import 'package:flutter/foundation.dart';

class FcmService {


    final FirebaseMessaging _messeging = FirebaseMessaging.instance ; 


    Future<NotificationSettings> requestPermission() {
        return _messeging.requestPermission(alert: true , sound: true , badge: true);
    }


    Future<String?> getTOken () {
        return _messeging.getToken(); 
    }


    Future<void> SetUpaAfterLogin ()async {

        final Setting  = await requestPermission (); 


        final getToken = await getTOken() ; 
        debugPrint("FCM {getToken}");
    }

    
    
}