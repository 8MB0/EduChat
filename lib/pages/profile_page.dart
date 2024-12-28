import 'dart:io';

import 'package:educhat/helper/helper_function.dart';
import 'package:educhat/pages/login_page.dart';
import 'package:educhat/service/auth_service.dart';
import 'package:educhat/service/database_service.dart';
import 'package:educhat/widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:educhat/pages/home_page.dart';
import 'package:educhat/pages/search_page.dart';

import '../theme/theme.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final String email;
  const ProfilePage({
    super.key,
    required this.username,
    required this.email,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  FilePickerResult? result;
  String imagePath = "";
  String userDp = "";

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
    getUserData();
  }

  getUserData() async {
    await HelperFunctions.getUserProfilePicFromSF().then((value) {
      if (value != null) {
        setState(() {
          userDp = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: MyTheme.appBarGradient(
          child: Container(),
        ),
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 20),
              _buildInfoCard("Full Name", widget.username),
              const SizedBox(height: 5),
              _buildInfoCard("Email", widget.email),
              const SizedBox(height: 10),
              if (imagePath.isNotEmpty) _buildSaveButton(),
              const SizedBox(height: 170), 
              _buildDeveloperInfo(), 
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 80,
          backgroundColor: Colors.grey[700],
          backgroundImage: (imagePath.isEmpty)
              ? (userDp.isEmpty
                  ? const AssetImage('assets/3.jpg')
                  : NetworkImage(userDp)) as ImageProvider
              : FileImage(File(imagePath)),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: selectImages,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child:
                  const Icon(Icons.add_a_photo_outlined, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      child: ListTile(
        leading: Icon(
          title == "Full Name" ? Icons.person : Icons.email,
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: updateDp,
      icon: const Icon(Icons.save, color: Colors.white),
      label: const Text(
        "Save Changes",
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
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
      currentIndex: 2,
      selectedItemColor: Theme.of(context).colorScheme.secondary,
      unselectedItemColor: Colors.white,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onTap: (index) {
        if (index == 0) {
          nextScreenReplace(context, const HomePage());
        } else if (index == 1) {
          nextScreenReplace(context, const SearchPage());
        }
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                (userDp == "")
                    ? Icon(Icons.account_circle,
                        size: 180, color: Colors.grey[200])
                    : CircleAvatar(
                        radius: 75,
                        backgroundImage: NetworkImage(userDp),
                      ),
                const SizedBox(height: 10),
                Text(
                  widget.username,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Times New Roman',
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.email_outlined,
                color: Theme.of(context).colorScheme.secondary),
            title: const Text(
              "Email us",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),
          ListTile(
            onTap: () {},
            leading: Icon(Icons.share_outlined,
                color: Theme.of(context).colorScheme.secondary),
            title: const Text(
              "Share with friends",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            onTap: () async {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        title: Text(
                          'About',
                          style: TextStyle(
                            fontFamily: 'Times New Roman',
                            color: Colors.white,
                          ),
                        ),
                        content: Text(
                          '''هذا التطبيق مصمم لطلبة الجامعات, حيث يتيح لهم التواصل في بيئة تفاعلية تجمع بين الجانب الأكاديمي والأنشطة الإجتماعية ,يوفر التطبيق إمكانية إنشاء غرف جماعية مخصصة لمناقشة مواضيع دراسية أو اجتماعية, مع إمكانية إرسال الصور لتعزيز المشاركة والتفاعل بين الأعضاء. يهدف التطبيق إلى تسهيل تبادل الأفكار والمعلومات وبناء مجتمع طلابي متعاون

رقم الإصدار:  1.0.0
                          ''',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.cancel, color: Colors.white),
                          ),
                        ]);
                  });
            },
            selectedColor: Theme.of(context).primaryColor,
            selected: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: Icon(Icons.info_outlined,
                color: Theme.of(context).colorScheme.secondary),
            title: Text(
              "About",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: ((context) {
                    return AlertDialog(
                      title: Text(
                        "Logout",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      content: Text("Are you sure you want to logout?"),
                      actions: [
                        IconButton(
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            await authService.signOut();
                            nextScreenReplace(context, const LoginScreen());
                          },
                        ),
                      ],
                    );
                  }));
            },
            leading: Icon(
              Icons.exit_to_app_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "CopyRight ® 2024 BY Mabruka Abunieza", 
            style: TextStyle(
             fontFamily: 'Times New Roman',
              color: Colors.grey[600],
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),

    );
  }

  updateDp() async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .updateUserDp(imagePath)
        .then((value) {
      if (kDebugMode) {
        print(value);
      }
      showSnackbar(context, Colors.green, "Successfully updated!");
    });
  }
}
