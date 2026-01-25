import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(
    const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConversationListScreen(),
    ),
  );
}

class ChatController extends GetxController {
  late IO.Socket socket;
  final TextEditingController msgController = TextEditingController();

  final String serverUrl = "https://backend.barberstime.com/messages";

  // Efaz khondhoker
  // final String myId = '6893255594bdae61a31ff643';
  // final String authToken =
  //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OTMyNTU1OTRiZGFlNjFhMzFmZjY0MyIsImVtYWlsIjoiZWZhemtoQGdtYWlsLmNvbSIsInJvbGUiOiJDVVNUT01FUiIsInB1cnBvc2UiOiJhY2Nlc3MiLCJmdW5jdGlvbnMiOltdLCJzdWJzY3JpcHRpb25QbGFuIjoiRlJFRSIsImlhdCI6MTc2OTMzOTgzNywiZXhwIjoxNzY5NDI2MjM3fQ.3clOIW49gMxA94XjXS6tfjL-O7wzO1qxHagsjqSSrw0";

  // Alex Jordhan
  final String myId = '689424ee19c117b142c8bf50';
  final String authToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OTQyNGVlMTljMTE3YjE0MmM4YmY1MCIsImVtYWlsIjoicjN0b3Y0dWV6NkB6dWRwY2suY29tIiwicm9sZSI6IlNBTE9PTl9PV05FUiIsInB1cnBvc2UiOiJhY2Nlc3MiLCJmdW5jdGlvbnMiOltdLCJzdWJzY3JpcHRpb25QbGFuIjoiUFJPX1BSRU1JVU0iLCJpYXQiOjE3NjkzMzk4OTMsImV4cCI6MTc2OTQyNjI5M30.CHUAhu3SsNmz2vUN7GQ7ARnYP4lwUrNiCNm46sl4cbM";

  // Reactive variables
  var isConnected = false.obs;
  var messages = <dynamic>[].obs;
  var conversationList = <dynamic>[].obs;
  var currentReceiverId = "".obs;
  var currentReceiverName = "".obs;

  @override
  void onInit() {
    super.onInit();
    initSocket();
  }

  void initSocket() {
    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': authToken})
          .build(),
    );

    socket.onConnect((_) {
      debugPrint('\n✅ Connected\n');
      isConnected.value = true;
      refreshConversationList();
    });

    socket.onDisconnect((_) {
      isConnected.value = false;
    });

    socket.on('message', (data) {
      if (data['senderId'] == currentReceiverId.value ||
          data['receiverId'] == currentReceiverId.value) {
        messages.insert(0, data);
      }
      refreshConversationList();
    });

    socket.on('chats', (data) {
      List history = data['chats'] ?? [];
      messages.assignAll(history.reversed.toList());
    });

    socket.on('messageList', (data) {
      conversationList.assignAll(data);

      var encoder = const JsonEncoder.withIndent('  ');
      String prettyString = encoder.convert(data);

      debugPrint('xxx message list received:');
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
    });
  }

  void refreshConversationList() => socket.emit('messageList');

  void openChat(dynamic item) {
    final chat = item['chat'];

    // Simplest logic: If I am the sender in the record, the other person is the receiver.
    // Otherwise, the other person is the sender.
    bool amISender = chat['senderId'] == myId;

    currentReceiverId.value = amISender ? chat['receiverId'] : chat['senderId'];
    currentReceiverName.value = amISender
        ? item['receiverName']
        : item['senderName'];

    messages.clear();
    socket.emit('fetchChats', {'receiverId': currentReceiverId.value});
    Get.to(() => const BarberChatApp());
  }

  void sendMessage() {
    if (msgController.text.trim().isNotEmpty) {
      socket.emit('message', {
        'receiverId': currentReceiverId.value,
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

class ConversationListScreen extends StatelessWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Messages'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () async => controller.refreshConversationList(),
          child: ListView.separated(
            itemCount: controller.conversationList.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = controller.conversationList[index];
              final chat = item['chat'];

              // Simplest logic: compare myId with chat senderId
              bool amISender = chat['senderId'] == controller.myId;
              final String displayName = amISender
                  ? item['receiverName']
                  : item['senderName'];
              final String? displayImage = amISender
                  ? item['receiverImage']
                  : item['senderImage'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: displayImage != null
                      ? NetworkImage(displayImage)
                      : null,
                  child: displayImage == null ? const Icon(Icons.person) : null,
                ),
                title: Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  chat['message'] ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: item['unReadMessagesCount'] > 0
                    ? CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          "${item['unReadMessagesCount']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      )
                    : const Icon(Icons.chevron_right, size: 16),
                onTap: () => controller.openChat(item),
              );
            },
          ),
        );
      }),
    );
  }
}

class BarberChatApp extends StatelessWidget {
  const BarberChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.currentReceiverName.value)),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(10),
                itemCount: controller.messages.length,
                itemBuilder: (ctx, i) {
                  final msg = controller.messages[i];
                  return Align(
                    alignment: msg['senderId'] == controller.myId
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: msg['senderId'] == controller.myId
                            ? Colors.blue[100]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg['message'] ?? ""),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.msgController,
                    decoration: const InputDecoration(
                      hintText: 'Type...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: controller.sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
