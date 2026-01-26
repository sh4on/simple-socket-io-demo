import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat/screens/conversation_list_screen.dart';

void main() {
  runApp(
    const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConversationListScreen(),
    ),
  );
}
