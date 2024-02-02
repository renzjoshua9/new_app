import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:new_app/authentication/signup_screen.dart';

import '../global/global_var.dart';
import '../methods/common_methods.dart';
import '../pages/dashboard.dart';
import '../pages/home_page.dart';
import '../widgets/loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable(){
    cMethods.checkConnectivity(context);

    signInFormValidation();
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
              const Text("Login as a CSR/Dispatcher",
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

                    const SizedBox(height: 22,),

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

                    const SizedBox(height: 22,),

                    ElevatedButton(
                      onPressed: (){
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20)
                      ),
                      child: const Text(
                          "Login"
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12,),

              //text button
              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => SignUpScreen()));
                },
                child: const Text(
                  "Don\'t have an Account? Sign Up Here",
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

  void signInFormValidation() {
    if(!emailTextEditingController.text.contains("@")){
      cMethods.displaySnackbar("Please write a valid email", context);
    }
    else if(passwordTextEditingController.text.length < 5){
      cMethods.displaySnackbar("Your password must be at least 6 or more characters", context);
    }
    else{
      signInUser();
    }
  }

  signInUser() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => LoadingDialog(messageText: "Logging in your account")
    );

    final User? userFirebase = (
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim()
        ).catchError((errorMessage){
          Navigator.pop(context);
          cMethods.displaySnackbar(errorMessage.toString(), context);
        })
    ).user;

    if(!context.mounted) return;
    Navigator.pop(context);

    if(userFirebase != null){
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("new").child(userFirebase.uid);
      usersRef.once().then((snap){
        if(snap.snapshot.value != null){
          if((snap.snapshot.value as Map)["blockStatus"] == "no"){
            userName = (snap.snapshot.value as Map)["name"];
            Navigator.push(context, MaterialPageRoute(builder: (c) => Dashboard()));
          } else {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackbar("Your account is blocked. Contact admin", context);
          }
        } else{
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackbar("Your account does not exist", context);
        }
      });


    }
  }
}
