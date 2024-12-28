import 'package:educhat/helper/helper_function.dart';
import 'package:educhat/pages/home_page.dart';
import 'package:educhat/pages/login_page.dart';
import 'package:educhat/service/auth_service.dart';
import 'package:educhat/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullName = "";
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
                                    color: const Color(0xFF0164B5),
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
                          const SizedBox(height: 7),
                          const Text(
                            "Create your account now to chat & explore ",
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontFamily: 'Times New Roman',
                                fontWeight: FontWeight.w500),
                          ),
                          Image.asset('assets/0.png'),
                          TextFormField(
                            decoration: textInputDecoration.copyWith(
                              labelText: "Full Name",
                              prefixIcon: Icon(
                                Icons.person,
                                color: const Color(0xFF0164B5) ,
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
                                fullName = val;
                              });
                            },
                            style: TextStyle(color: Colors.black),
                            validator: (val) {
                              if (val!.isNotEmpty) {
                                return null;
                              } else {
                                return "Name can't be empty!";
                              }
                            },
                          ),
                          SizedBox(height: 9),
                          TextFormField(
                            decoration: textInputDecoration.copyWith(
                              labelText: "Email",
                              prefixIcon: Icon(
                                Icons.email,
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
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            },
                            //check the validation
                            style: TextStyle(color: Colors.black),
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
                          const SizedBox(height: 9),
                          TextFormField(
                              obscureText: true,
                              decoration: textInputDecoration.copyWith(
                                  labelText: "Password",
                                  prefixIcon: Icon(
                                    Icons.lock,
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
                            style: TextStyle(color: Colors.black),
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
                                        borderRadius:
                                            BorderRadius.circular(30))),
                                child: const Text(
                                  "Register",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Times New Roman',
                                      fontSize: 16),
                                ),
                                onPressed: () {
                                  register();
                                },
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          Text.rich(TextSpan(
                            text: "Already have an account?  ",
                            style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Times New Roman',
                                fontSize: 13),
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Login now",
                                  style: const TextStyle(
                                      fontFamily: 'Times New Roman',
                                      color: Color(0xFF3135B5),
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      nextScreen(context, const LoginScreen());
                                    })
                            ],
                          ))
                        ]),
                  ),
                ),
              ));
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .registerUserWithEmailandPassword(fullName, email, password)
          .then((value) async {
        if (value == true) {
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(fullName);
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
