import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.receiverName.value)),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.statusForSingleConversation.value.isLoading) {
                return Center(child: Text('Loading old chats..'));
              } else {
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(10),
                  itemCount: controller.messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = controller.messages[i];
                    final isSender = msg['senderId'] == controller.myId;

                    // message
                    return Align(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSender ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg['message'] ?? ""),
                      ),
                    );
                  },
                );
              }
            }),
          ),

          // send message box
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
