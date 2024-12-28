import 'package:flutter/material.dart';
import '../helper/timestamp_converter.dart';
import '../pages/chat_page.dart';
import '../pages/home_page.dart';
import '../service/database_service.dart';
import 'widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  final String groupIcon;
  final String? recentMessage;
  final String? recentMessageSender;
  final String? recentMessageTime;
  final bool? isRecentMessageSeen;
  final String adminName;

  const GroupTile({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.userName,
    required this.groupIcon,
    required this.adminName,
    this.recentMessage,
    this.recentMessageSender,
    this.recentMessageTime,
    this.isRecentMessageSeen,
  }) : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  String username = "";

  String _truncateMessage(String? message, int maxLength) {
    if (message == null || message.isEmpty) return "No messages yet.";
    if (message.length > maxLength) {
      return message.substring(0, maxLength) + "...";
    } else {
      return message;
    }
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.groupId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: const Color(0xFF2664C6),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.logout, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'Exit Group',
                style: TextStyle(
                  fontFamily: 'Times New Roman',
                  color: const Color(0xFF0164B5),
                ),
              ),
              content: Text(
                widget.userName == getName(widget.adminName)
                    ? '''You are the admin.
If you leave, the group will be deleted. Are you sure?'''
                    : 'Are you sure you want to leave the group?',
                textAlign: TextAlign.center,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.cancel, color: Colors.red),
                ),
                IconButton(
                  onPressed: () {
                    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                        .togglegroupJoin(
                      widget.groupId,
                      widget.userName,
                      widget.groupName,
                    )
                        .whenComplete(() {
                      Navigator.pop(context);
                      nextScreenReplace(context, HomePage());
                    });
                  },
                  icon: Icon(Icons.done, color: Colors.green),
                ),
              ],
            );
          },
        );
        return false;
      },
      child: GestureDetector(
        onTap: () {
          nextScreen(
            context,
            ChatPage(
              groupId: widget.groupId,
              groupName: widget.groupName,
              userName: widget.userName,
              groupIcon: widget.groupIcon,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: ListTile(
            leading: (widget.groupIcon.isEmpty)
                ? CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Text(
                      widget.groupName.substring(0, 1).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                : CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(widget.groupIcon),
                  ),
            title: Text(
              widget.groupName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: widget.recentMessage == null || widget.recentMessage!.isEmpty
                ? const Text(
                    "Join the conversation",
                    style: TextStyle(fontSize: 13),
                  )
                : Text(
                    (widget.recentMessageSender == widget.userName
                        ? _truncateMessage(widget.recentMessage, 12)
                        : "${widget.recentMessageSender}: ${_truncateMessage(widget.recentMessage, 12)}"),
                    style: (widget.isRecentMessageSeen ?? true)
                        ? const TextStyle(fontWeight: FontWeight.normal)
                        : const TextStyle(fontWeight: FontWeight.bold),
                  ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!(widget.isRecentMessageSeen ?? true))
                  Icon(
                    Icons.circle,
                    size: 15,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                const SizedBox(height: 5),
                if (widget.recentMessageTime != null &&
                    widget.recentMessageTime!.isNotEmpty)
                  Text(
                    DateTimeConverter.convertTimeStamp(
                        int.tryParse(widget.recentMessageTime!) ?? 0),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
