import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart';

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
        if (controller.statusForConversation.value.isLoading) {
          return Center(child: Text('Getting conversation list..'));
        } else if (controller.statusForConversation.value.isError) {
          return Center(
            child: Text(controller.statusForConversation.value.errorMessage!),
          );
        } else {
          return RefreshIndicator(
            onRefresh: () async => controller.refreshConversationList(),
            child: ListView.separated(
              itemCount: controller.conversationList.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = controller.conversationList[index];
                final chat = item['chat'];

                final String receiverName = item['receiverName'];
                final String? receiverImage = item['receiverImage'];
                final String? receiverId = chat['receiverId'] != controller.myId
                    ? chat['receiverId']
                    : chat['senderId'];

                return ListTile(
                  // receiver image
                  leading: CircleAvatar(
                    backgroundImage: receiverImage != null
                        ? NetworkImage(receiverImage)
                        : null,
                    child: receiverImage == null
                        ? const Icon(Icons.person)
                        : null,
                  ),

                  // receiver name
                  title: Text(
                    receiverName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // receiver last message
                  subtitle: Text(
                    chat['message'] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: item['unReadMessagesCount'] > 0
                          ? FontWeight.w900
                          : null,
                    ),
                  ),

                  // unread message count
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
                  onTap: () {
                    controller.openChat(
                      receiverId: receiverId!,
                      receiverName: receiverName,
                    );
                  },
                );
              },
            ),
          );
        }
      }),
    );
  }
}
