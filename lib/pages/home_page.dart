
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper/helper_function.dart';
import '../service/auth_service.dart';
import '../service/database_service.dart';
import '../theme/theme.dart';
import '../widgets/group_tile.dart';
import '../widgets/widgets.dart';
import 'profile_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  String email = " ";
  String userDp = "";
  AuthService authService = AuthService();
  Stream<QuerySnapshot>? groups;
  bool _isLoading = false;
  String groupName = "";
  DocumentSnapshot? groupData;
  List<String> groupIds = List.empty(growable: true);

  // string manipulation
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  @override
  void initState() {
    // TODo: implement initState
    super.initState();
    gettingUserData();
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });

    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        username = value!;
      });
    });

    await HelperFunctions.getUserProfilePicFromSF().then((value) {
      setState(() {
        if (value != null) {
          userDp = value;
        }
        print(userDp);
      });
    });

    // getting user snapshots

    await DatabaseService(
            uid: "${FirebaseAuth.instance.currentUser!.uid}_$username")
        .getUserGroupsv1()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  // getGroupRecentMessageData(String groupId) async {
  //   await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
  //       .getGroupRecentMessageData(groupId)
  //       .then((value) {
  //     setState(() {
  //       groupData = value;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
appBar: AppBar(
  centerTitle: true,
  elevation: 0.0,
  title: const Text(
    "Groups",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  flexibleSpace: MyTheme.appBarGradient(
    child: Container(), 
  ),
),

     
      body: groupList(),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          shape: CircleBorder(),
          child: Icon(Icons.group_add_outlined),
          onPressed: () {
            popUpDialog(context);
          }),

           bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0, 
        onTap: (index) {
          if (index == 1) {
            nextScreenReplace(context, const SearchPage());
          } else if (index == 2) {
            nextScreen(
              context,
              ProfilePage(
                username: username,
                email: FirebaseAuth.instance.currentUser?.email ?? '',
              ),
            );
          }
        },
      ),
    );
  }

popUpDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text("Create a group", 
        style: TextStyle(
                        fontFamily: 'Times New Roman',
                        color: const Color(0xFF0164B5),
                      ),
                    ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isLoading == true
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  )
                : TextField(
                    onChanged: (value) {
                      setState(() {
                        groupName = value;
                      });
                    }, 
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (groupName != "") {
                setState(() {
                  _isLoading = true;
                });

                DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                    .createGroup(username,
                        FirebaseAuth.instance.currentUser!.uid, groupName)
                    .whenComplete(() => _isLoading = false);
                Navigator.of(context).pop();
                showSnackbar(
                    context, Colors.green, "Group created successfully");
              }
            },
            child: Text("Create"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    },
  );
}


  groupList() {
    return StreamBuilder(
        stream: groups,
        builder: (context, AsyncSnapshot snapshot) {
          //make checks

          if (snapshot.hasData) {
            if (snapshot.data.docs.length != 0) {
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    var reverseIndex = snapshot.data.docs.length - index - 1;

                    return GroupTile(
                      groupId: snapshot.data.docs[reverseIndex]["groupId"],
                      groupName: snapshot.data.docs[reverseIndex]["groupName"],
                      userName: username,
                      groupIcon: snapshot.data.docs[reverseIndex]["groupIcon"],
                      recentMessage: snapshot.data.docs[reverseIndex]
                          ["recentMessage"],
                      recentMessageSender: snapshot.data.docs[reverseIndex]
                          ["recentMessageSender"],
                      recentMessageTime: snapshot.data.docs[reverseIndex]
                          ["recentMessageTime"],
                      isRecentMessageSeen: (snapshot
                              .data.docs[reverseIndex]["recentMessageSeenBy"]
                              .contains(FirebaseAuth.instance.currentUser!.uid))
                          ? true
                          : false, adminName: '',
                    );
                  });
            } else {
              return noGroupWidget();
            }
          } else {
            return Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary),
            );
          }
        });
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.group_add_rounded,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not joined any groups, tap on the add icon to create a group or also search from bottom search button.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
