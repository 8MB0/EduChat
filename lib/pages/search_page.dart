import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educhat/pages/chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper/helper_function.dart';
import '../service/database_service.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'home_page.dart';
import 'profile_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String username = "";
  User? user;
  bool _isJoined = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdAndName();
  }

  getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  getCurrentUserIdAndName() async {
    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        username = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
  centerTitle: true,
  elevation: 0.0,
  title: const Text(
    "Search",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  flexibleSpace: MyTheme.appBarGradient(child: Container()),
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(60.0),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                  border: InputBorder.none,
                  hintText: "Search Groups...",
                  hintStyle: const TextStyle(color: Color(0x7FFFFFFF)),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      initiateSearchMethod();
                    },
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),

      body: Column(
        children: [
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor))
              : groupList()
        ],
      ),
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
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            nextScreenReplace(context, const HomePage());
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

  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .searchByName(searchController.text)
          .then((value) {
        setState(() {
          searchSnapshot = value;
          _isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                username,
                searchSnapshot!.docs[index]["groupId"],
                searchSnapshot!.docs[index]["groupName"],
                searchSnapshot!.docs[index]['admin'],
                searchSnapshot!.docs[index]['groupIcon'],
              );
            })
        : Container();
  }

  joinedOrNot(
      String userName, String groupId, String groupname, String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupname, groupId, userName)
        .then((value) {
      setState(() {
        _isJoined = value;
      });
    });
  }

  Widget groupTile(
      String username, String groupId, String groupName, String admin, String groupIcon) {
    joinedOrNot(username, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          textAlign: TextAlign.center,
                    style: const TextStyle(
                     fontFamily: 'Times New Roman',
                     fontSize: 25,
                    color: Colors.white, fontWeight: FontWeight.w500),
                          ),
      ),
      title: Text(
        groupName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid)
              .toggleJoin(groupId, groupName, username);

          if (_isJoined) {
            setState(() {
              _isJoined = !_isJoined;
            });
            showSnackbar(context, Colors.green,
                "Successfully joined group $groupName");

            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      userName: username,
                      groupIcon: groupIcon,
                  ));
            });
          } else {
            setState(() {
              _isJoined = !_isJoined;
              showSnackbar(context, Colors.red, "Left the group $groupName");
            });
          }
        },
        child: _isJoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Joined",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text("Join Now", style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }
}
