import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educhat/helper/helper_function.dart';
import 'package:educhat/pages/home_page.dart';
import 'package:educhat/pages/register_page.dart';
import 'package:educhat/service/auth_service.dart';
import 'package:educhat/service/database_service.dart';
import 'package:educhat/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String username = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor))
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Form(
                  key: formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Edu',
                                style: TextStyle(
                                  fontSize: 50,
                                  fontFamily: 'Times New Roman',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0164B5),
                                ),
                              ),
                              TextSpan(
                                text: 'Chat',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontFamily: 'Times New Roman',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, //
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 9),
                        const Text(
                          "Login now to see what they are talking",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontFamily: 'Times New Roman',
                              fontWeight: FontWeight.w500),
                        ),
                        Image.asset('assets/1.jpg'),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                            labelText: "Email",
                            prefixIcon: Icon(
                              Icons.email,
                              color:  const Color(0xFF0164B5),
                            ),
                            enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
       borderSide: BorderSide(
        color: Color(0xFF0164B5),  
        width: 2.0,)),
         focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),  
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor, 
        width: 2.0, 
      ),
    ),
                          ),
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                              style: TextStyle(
                              color: Colors.black,),
                          // check the validation
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Email can't be empty!";
                            }
                            return RegExp(
                                        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$")
                                    .hasMatch(val)
                                ? null
                                : "Please enter a valid email!";
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                            obscureText: true,
                            decoration: textInputDecoration.copyWith(
                                labelText: "Password",
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: const Color(0xFF0164B5),
                                ),
                                
                                enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
       borderSide: BorderSide(
        color: Color(0xFF0164B5),  
        width: 2.0,)),

         focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),  
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor, 
        width: 2.0, 
      ),
    ),
                                
                                ),  
                              style: TextStyle(
                              color: Colors.black,),
                            validator: (val) {
                              if (val!.length < 6) {
                                return "Password must be at least 6 characters";
                              } else {
                                return null;
                              }
                            },
                            onChanged: (val) {
                              setState(() {
                                password = val;
                              });
                            }),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                       const Color(0xFF0164B5),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                              child: const Text(
                                "Sing In",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Times New Roman',
                                    fontSize: 16),
                              ),
                              onPressed: () {
                                login();
                              },
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        Text.rich(TextSpan(
                          text: "Don't have an account?  ",
                          style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'Times New Roman',
                              fontSize: 13),
                          children: <TextSpan>[
                            TextSpan(
                                text: "Register here",
                                style: const TextStyle(
                                    fontFamily: 'Times New Roman',
                                    color: Color(0xFF3135B5),
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, const RegisterPage());
                                  })
                          ],
                        ))
                      ]),
                ),
              ),
            ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .loginUserWithUserNameandPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .gettingUserData(email);
          //saving the values to our shared preferences
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(
            snapshot.docs[0]['fullName']);
          nextScreen(context, const HomePage());
        } else {
          showSnackbar(context, value, Colors.blue);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
