import 'dart:io';
import 'package:educhat/pages/home_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../helper/helper_function.dart';
import '../service/database_service.dart';
import '../widgets/widgets.dart';

class GroupInfo extends StatefulWidget {
  const GroupInfo({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.adminName,
    required this.groupIcon,
  });

  final String groupId;
  final String groupName;
  final String adminName;
  final String groupIcon;

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  FilePickerResult? result;

  String imagePath = "";
  String username = "";

  // Select an image for the group (Admin Only)
  selectImages() async {
    result = await FilePicker.platform.pickFiles();

    if (result != null) {
      imagePath = result!.files.single.path!;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getMembers();
  }

  // Extract the name from the admin ID
  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  // Get the group members and current username
  getMembers() async {
    String? fetchedUsername = await HelperFunctions.getUserNameFromSF();
    setState(() {
      username = fetchedUsername ?? '';
    });

    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((value) {
      setState(() {
        members = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text("Group Info", style: TextStyle(fontSize: 22)),
        actions: [
         IconButton(
  onPressed: () {
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
              username == getName(widget.adminName)
                  ? '''You are the admin.
If you leave, the group will be deleted. Are you sure?'''
                  : 'Are you sure you want to leave the group?',
                   textAlign: TextAlign.center,),
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
                        widget.groupId, getName(widget.adminName), widget.groupName)
                    .whenComplete(() {
                  nextScreenReplace(context, HomePage());
                });
              },
              icon: Icon(Icons.done, color: Colors.green),
            ),
          ],
        );
      },
    );
  },
  icon: Icon(Icons.logout, size: 30),
)

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
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          children: [
Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  elevation: 5,
  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
  child: Padding(
    padding: EdgeInsets.all(22),
    child: Container(
      width: MediaQuery.of(context).size.width * 1,
      child: Row(
        children: [
          GestureDetector(
            onTap: username == getName(widget.adminName)
                ? selectImages
                : () {
                    showSnackbar(context, Colors.red,
                        "Only the admin can change the group icon");
                  },
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: imagePath.isEmpty
                      ? widget.groupIcon.isEmpty
                          ? null
                          : NetworkImage(widget.groupIcon)
                      : FileImage(File(imagePath)) as ImageProvider,
                  backgroundColor: imagePath.isEmpty && widget.groupIcon.isEmpty
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                  child: imagePath.isEmpty && widget.groupIcon.isEmpty
                      ? Icon(
                          Icons.group,
                          size: 60,
                          color: Colors.grey[300],
                        )
                      : null,
                ),
                if (username == getName(widget.adminName) &&
                    imagePath.isEmpty &&
                    widget.groupIcon.isEmpty)
                  Positioned(
                    bottom: 7,
                    right: 0,
                    left: 70,
                    child: Icon(
                      Icons.add_a_photo,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.groupName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Times New Roman',
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        "${getName(widget.adminName)}",
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.person_pin,
                        color: Colors.green,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),

            SizedBox(height: 10),
            // Image Save Button (Only Admin)
            if (imagePath.isNotEmpty && username == getName(widget.adminName))
              ElevatedButton(
                onPressed: () {
                  uploadGroupDp();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondary,
                ),
                child: Text("Save",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            SizedBox(height: 5),
            Expanded(child: memberList()),
          ],
        ),
      ),
    );
  }

  // Member List
  memberList() {
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['members'].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  String memberName =
                      getName(snapshot.data['members'][index]);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        child: Text(
                          memberName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            memberName,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 5),
                          if (memberName == getName(widget.adminName))
                            Icon(
                              Icons.person_pin,
                              color: Colors.green,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text("No members yet",
                    style: TextStyle(color: Colors.white)),
              );
            }
          } else {
            return const Center(
              child: Text("No members yet",
                  style: TextStyle(color: Colors.white)),
            );
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          ));
        }
      },
    );
  }

  // Upload Group Profile Image (Admin Only)
  uploadGroupDp() async {
    if (username == widget.adminName) {
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .updateGroupDp(imagePath, widget.groupId)
          .then((value) {
        showSnackbar(context, Colors.green, "Successfully updated");
      }, onError: (e) =>
              showSnackbar(context, Colors.red, "Error while updating"));
    } else {
      showSnackbar(context, Colors.red, "You are not allowed to do that");
    }

    setState(() {});
  }
}
