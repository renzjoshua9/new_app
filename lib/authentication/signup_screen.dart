import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:new_app/authentication/login_screen.dart';
import 'package:new_app/methods/common_methods.dart';

import '../pages/dashboard.dart';
import '../pages/home_page.dart';
import '../widgets/loading_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController usernameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneNumberTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable(){
    cMethods.checkConnectivity(context);

    signUpFormValidation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Image.asset("assets/images/logo.png"),
              const Text("Create a User\'s Account",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),

              ),
              //Text fields + Button
              Padding(padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    TextField(
                      controller: usernameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.black
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 15,),

                    TextField(
                      controller: phoneNumberTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.black
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 15,),

                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email Address",
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.black
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 15,),

                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.black
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 15,),

                    ElevatedButton(
                      onPressed: (){
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 1)
                      ),
                      child: const Text(
                          "Sign Up"
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5,),

              //text button
              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                },
                child: const Text(
                  "Already have an account? Login Here",
                  style:  TextStyle(
                    color:Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  void signUpFormValidation() {
    if(usernameTextEditingController.text.trim().length < 3){
      cMethods.displaySnackbar("Your username must be at least 4 or more characters", context);
    }
    else if(phoneNumberTextEditingController.text.trim().length != 11){
      cMethods.displaySnackbar("Your phone number length must be 11 ", context);
    }
    else if(!emailTextEditingController.text.contains("@")){
      cMethods.displaySnackbar("Please write a valid email", context);
    }
    else if(passwordTextEditingController.text.length < 5){
      cMethods.displaySnackbar("Your password must be at least 6 or more characters", context);
    }
    else{
      registerNewUser();
    }
  }

  registerNewUser() async{
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => LoadingDialog(messageText: "Registering your account")
    );
    final User? userFirebase = (
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((errorMessage){
          Navigator.pop(context);
          cMethods.displaySnackbar(errorMessage.toString(), context);
        })
    ).user;
    if(!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("new").child(userFirebase!.uid);
    Map userDataMap = {
      "name" : usernameTextEditingController.text.trim(),
      "email" : emailTextEditingController.text.trim(),
      "phone" : phoneNumberTextEditingController.text.trim(),
      "id" : userFirebase.uid,
      "blockStatus" : "no",
    };

    usersRef.set(userDataMap);
    Navigator.push(context, MaterialPageRoute(builder: (c) => Dashboard()));
  }
}
