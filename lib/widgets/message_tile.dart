import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helper/timestamp_converter.dart';
import '../pages/imageview.dart';

enum MessageStatus { notSent, sent, seen }

class MessageTile extends StatefulWidget {
  const MessageTile({
    super.key,
    required this.isMe,
    required this.message,
    required this.sender,
    required this.messageTimeStamp,
    required this.image,
    required this.messageStatus,
    required this.onDeleteMessage,
    required this.onReplyMessage,
    required this.isLastMessageFromSender,
    this.replyToMessage,
    this.senderAvatar,
    required this.isNotLastInGroup,
    required this.isSelected,
    required this.onSelectMessage,
  });

  final String message;
  final String sender;
  final bool isMe;
  final String image;
  final int messageTimeStamp;
  final MessageStatus messageStatus;
  final Function onDeleteMessage;
  final Function(String, String)? onReplyMessage;
  final bool isLastMessageFromSender;
  final bool isNotLastInGroup;
  final String? replyToMessage;
  final String? senderAvatar;
  final bool isSelected;
  final Function onSelectMessage;

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
 void _showOptionsMenu(BuildContext context, Offset tapPosition) {
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

  showMenu(
    context: context,
    position: RelativeRect.fromRect(
      tapPosition & const Size(40, 40),
      Offset.zero & overlay.size,
    ),
    color: const Color(0xff1d1b25),
    items: [
      PopupMenuItem(
        value: 'copy',
        child: ListTile(
          leading: const Icon(Icons.copy, color: Color(0xFF0869B9)),
          title: const Text("Copy"),
          onTap: () {
            Clipboard.setData(ClipboardData(text: widget.message));
            Navigator.pop(context); // Close the menu
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  "Copied!",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.black.withOpacity(0.8),
                duration: const Duration(milliseconds: 500),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
      PopupMenuItem(
        value: 'reply',
        child: ListTile(
          leading: const Icon(Icons.reply, color: Color(0xFF0869B9)),
          title: const Text("Reply"),
          onTap: () {
            Navigator.pop(context); // Close the menu
            if (widget.onReplyMessage != null) {
              widget.onReplyMessage!(widget.message, widget.sender);
            }
          },
        ),
      ),
      if (widget.isMe)
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete"),
            onTap: () async {
              Navigator.pop(context); // Close the menu
              final bool? confirmDelete = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.red,
                      size: 40,
                    ),
                    content: const Text(
                      "Are you sure delete message?",
                      textAlign: TextAlign.center,
                    ),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        icon: const Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                    ],
                  );
                },
              );
              if (confirmDelete == true) {
                widget.onDeleteMessage();
              }
            },
          ),
        ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = (!widget.isLastMessageFromSender &&
            widget.isNotLastInGroup &&
            !widget.isMe)
        ? 48
        : 5;
    Offset _tapPosition = Offset.zero;
  
  return GestureDetector(
    onTapDown: (details) {
      _tapPosition = details.globalPosition;
    },
    onTap: widget.isSelected
        ? null
        : () => _showOptionsMenu(context, _tapPosition),
    onLongPress: () {
      if (widget.isMe) {
        widget.onSelectMessage();
      }
    },
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (!widget.isMe && widget.isLastMessageFromSender)
        widget.senderAvatar != null && widget.senderAvatar!.isNotEmpty
            ? CircleAvatar(
                backgroundImage: NetworkImage(widget.senderAvatar!),
                radius: 20,
              )
            : CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF0869B9),
                child: Text(
                  widget.sender[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Times New Roman',
                    fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: 2,
                  left: widget.isMe ? 0 : horizontalPadding,
                  right: widget.isMe ? horizontalPadding : 0,
                ),
                alignment:
                    widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: IntrinsicWidth(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: widget.isMe
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            )
                          : const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                      color: widget.isMe
                          ? Theme.of(context).colorScheme.secondary
                          : const Color(0xff383152),
                      border: widget.isSelected
                          ? Border.all(color: Colors.red, width: 2)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!widget.isMe)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              widget.sender,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (widget.replyToMessage != null &&
                            widget.replyToMessage!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xff1d1b25).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.blueAccent, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.replyToMessage!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.image != "")
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageViewPage(
                                        imagePath: widget.image,
                                        message: widget.message,
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    widget.image,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.message,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateTimeConverter.convertTimeStamp(
                                widget.messageTimeStamp,
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                             if (widget.isMe)
                            Icon(
                              widget.messageStatus == MessageStatus.seen
                                  ? Icons.done_all
                                  : Icons.done,
                              color: widget.messageStatus == MessageStatus.seen
                                  ? Color(0xff1d1b25)
                                  : Colors.white70,
                              size: 18,)
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.red,
                size: 17,
          ),
        ],
      )
    );
  }
}
