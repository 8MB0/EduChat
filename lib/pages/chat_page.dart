import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../service/database_service.dart';
import '../widgets/message_tile.dart';
import '../widgets/widgets.dart';
import 'group_info.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  final String groupIcon;

  const ChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.userName,
    required this.groupIcon,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String admin = "";
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  ScrollController listScrollController = ScrollController();

  FilePickerResult? result;

  String? replyToMessage;
  Set<String> selectedMessages = {};  // لتخزين الرسائل المحددة

  @override
  void initState() {
    getChatAndAdmin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.groupName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(
                context,
                GroupInfo(
                  groupId: widget.groupId,
                  groupName: widget.groupName,
                  adminName: admin,
                  groupIcon: widget.groupIcon,
                ),
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
          if (selectedMessages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, size: 35,color: Colors.red),
              onPressed:_deleteSelectedMessages,
            ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          chatMessages(),
          if (replyToMessage != null) _buildReplyPreview(),
          const SizedBox(height: 10),
          _buildMessageComposer(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(62, 47, 0, 255),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$replyToMessage",
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                replyToMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  getChatAndAdmin() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getChats(widget.groupId)
        .then((val) {
      setState(() {
        chats = val;
      });
    });

    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupAdmins(widget.groupId)
        .then((value) {
      setState(() {
        admin = value;
      });
    });

    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .toggleRecentMessageSeen(widget.groupId);
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Expanded(
              child: Center(child: CircularProgressIndicator()));
        }

        List<QueryDocumentSnapshot> messages = snapshot.data.docs;

        Future.delayed(Duration.zero, () {
          _updateMessagesAsSeen(messages);
        });

        return Expanded(
          child: ListView.builder(
            controller: listScrollController,
            itemCount: messages.length,
            reverse: true,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var messageData = messages[index];
              var nextMessage =
                  index > 0 ? messages[index - 1] : null;

              bool isLastMessageFromSender = nextMessage == null ||
                  nextMessage['sender'] != messageData['sender'];

              bool isSelected = selectedMessages.contains(messageData.id); // تحقق مما إذا كانت الرسالة محددة

              return MessageTile(
                message: messageData["message"],
                sender: messageData['sender'],
                isMe: widget.userName == messageData['sender'],
                image: messageData['imgUrl'],
                messageTimeStamp: messageData['time'],
                messageStatus: _getMessageStatus(messageData),
                replyToMessage: messageData['replyTo'],
                isLastMessageFromSender: isLastMessageFromSender,
                onDeleteMessage: () => _deleteMessage(messageData.id),
                onReplyMessage: (message, sender) {
                  setState(() {
                    replyToMessage = "$sender: $message";
                  });
                },
                isNotLastInGroup: true,
                isSelected: isSelected, // تمرير حالة التحديد
                onSelectMessage: () => _toggleMessageSelection(messageData.id), // التعامل مع التحديد
              );
            },
          ),
        );
      },
    );
  }

  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (selectedMessages.contains(messageId)) {
        selectedMessages.remove(messageId);
      } else {
        selectedMessages.add(messageId);
      }
    });
  }

  void _deleteSelectedMessages() async {
    try {
      for (String messageId in selectedMessages) {
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .doc(messageId)
            .delete();
      }

      setState(() {
        selectedMessages.clear(); // مسح التحديد بعد الحذف
      });

      showSnackbar(context, Colors.green, "Messages deleted successfully");
    } catch (e) {
      showSnackbar(context, Colors.red, "Failed to delete messages: $e");
    }
  }

  void _deleteMessage(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .doc(messageId)
          .delete();

      showSnackbar(context, Colors.green, "Message deleted successfully");
    } catch (e) {
      showSnackbar(context, Colors.red, "Failed to delete message: $e");
    }
  }

  void _updateMessagesAsSeen(List<QueryDocumentSnapshot> messages) {
    for (var message in messages) {
      if (message['sender'] != widget.userName && message['seen'] == false) {
        FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .doc(message.id)
            .update({'seen': true});
      }
    }
  }

  MessageStatus _getMessageStatus(QueryDocumentSnapshot messageData) {
    if (messageData['seen'] == true) {
      return MessageStatus.seen;
    } else if (messageData['sent'] == true) {
      return MessageStatus.sent;
    } else {
      return MessageStatus.notSent;
    }
  }

  Widget _buildMessageComposer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: const Color(0xffb312b46),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 150,
                  ),
                  child: Scrollbar(
                    thumbVisibility: true, 
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      reverse: true, 
                      child: TextField(
                        controller: messageController,
                        style: const TextStyle(color: Colors.white),
                        minLines: 1,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration.collapsed(
                          hintText: "Enter your message...",
                          hintStyle:
                              TextStyle(fontSize: 14, color: Color(0x4BFFFFFF)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            OverflowBar(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Color(0xFF0869B9)),
                  onPressed: _pickAndUploadFile,
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF0869B9)),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "imgUrl": "",
        "sender": widget.userName,
        "time": DateTime.now().toUtc().microsecondsSinceEpoch,
        "sent": true,
        "seen": false,
        "replyTo": replyToMessage ?? "",
      };

      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .sendMessage(widget.groupId, chatMessageMap);

      setState(() {
        messageController.clear();
        replyToMessage = null;
      });
    }
  }


  void _pickAndUploadFile() async {
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'doc'],
    );

    if (result != null) {
      final file = result!.files.single;
      String? filePath = file.path;

      if (filePath != null) {
        try {
          final fileName = DateTime.now().toUtc().microsecondsSinceEpoch;
          final storageRef =
              FirebaseStorage.instance.ref().child('uploads/$fileName');
          final uploadTask = storageRef.putFile(File(filePath));

          final snapshot = await uploadTask.whenComplete(() => {});
          final downloadUrl = await snapshot.ref.getDownloadURL();

          Map<String, dynamic> chatMessageMap = {
            "message": "",
            "imgUrl": downloadUrl,
            "sender": widget.userName,
            "time": DateTime.now().toUtc().microsecondsSinceEpoch,
            "sent": true,
            "seen": false,
            "replyTo": replyToMessage ?? "",
          };

          DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
              .sendMessage(widget.groupId, chatMessageMap);

          setState(() {
            replyToMessage = null;
          });
        } catch (e) {
          showSnackbar(context, Colors.red, "Failed to upload file: $e");
        }
      }
    }
  }
}
