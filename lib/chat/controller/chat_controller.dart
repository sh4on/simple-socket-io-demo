import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../screens/chat_screen.dart';

class ChatController extends GetxController {
  late IO.Socket socket;
  final TextEditingController msgController = TextEditingController();

  late final String socketUrl;

  Rx<RxStatus> statusForConversation = Rx<RxStatus>(RxStatus.loading());
  Rx<RxStatus> statusForSingleConversation = Rx<RxStatus>(RxStatus.loading());

  var messages = <dynamic>[].obs;
  var conversationList = <dynamic>[].obs;

  RxString receiverId = "".obs;
  RxString receiverName = "".obs;

  late final String myId;
  late final String authToken;

  @override
  void onInit() {
    super.onInit();

    socketUrl = "socket_url";
    myId = 'my_user_id';
    authToken = "auth_token";

    initSocket();
  }

  void initSocket() {
    socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': authToken})
          .build(),
    );

    socket.onConnect((_) {
      debugPrint('\n Socket connected successfully\n');
      refreshConversationList();
    });

    socket.onDisconnect((_) {
      debugPrint('\n Socket disconnected successfully\n');
    });

    socket.on('message', (data) {
      if (data['senderId'] == receiverId.value ||
          data['receiverId'] == receiverId.value) {
        messages.insert(0, data);
      }
      refreshConversationList();
    });

    socket.on('chats', (data) {
      List history = data['chats'] ?? [];
      messages.assignAll(history.reversed.toList());

      statusForSingleConversation.value = RxStatus.success();
    });

    socket.on('messageList', (data) {
      conversationList.assignAll(data);
      statusForConversation.value = RxStatus.success();

      var encoder = const JsonEncoder.withIndent('  ');
      String prettyString = encoder.convert(data);

      debugPrint('xxx messageList event');
      debugPrint(prettyString);
    });

    socket.on('error', (data) {
      Get.snackbar(
        "Error",
        data['message'] ?? "Unknown error",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );

      statusForConversation.value = RxStatus.error(
        data['message'] ?? "Unknown error",
      );
    });
  }

  void refreshConversationList() {
    statusForConversation.value = RxStatus.loading();

    socket.emit('messageList');
  }

  void openChat({required String receiverId, required String receiverName}) {
    statusForSingleConversation.value = RxStatus.loading();

    this.receiverId.value = receiverId;
    this.receiverName.value = receiverName;

    messages.clear();
    socket.emit('fetchChats', {'receiverId': receiverId});
    Get.to(() => const ChatScreen());
  }

  void sendMessage() {
    if (msgController.text.trim().isNotEmpty) {
      socket.emit('message', {
        'receiverId': receiverId.value,
        'message': msgController.text.trim(),
      });
      msgController.clear();
    }
  }

  @override
  void onClose() {
    socket.dispose();
    msgController.dispose();
    super.onClose();
  }
}
