import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:news_api/registration/regis.dart';
import 'package:news_api/view/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          iconTheme: new IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Latest",
                style: TextStyle(
                    color: Colors.purple,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0),
              ),
              Text(
                "News",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    letterSpacing: 2.0),
              )
            ],
          ),
        ),
        body: Container(
            color: Colors.white,
            child: _isloading
                ? Center(
                    child: Container(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: headerSection(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: passwordSection(),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: button()),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: signupbtn(),
                        )
                      ])));
  }

  Center signupbtn() {
    return Center(
        child: RichText(
            text: TextSpan(
      children: <TextSpan>[
        TextSpan(
          text: 'Don\'t have an account?',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        TextSpan(
            text: ' Sign up',
            style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.of(this.context).push(MaterialPageRoute(
                    builder: (BuildContext context) => Registration()));
              }),
      ],
    )));
  }

  signIn(String email, String password) async {
    final baseUrl = "https://reqres.in";
    String emailPrint;
    var responseJson;
    var response = await http.post("$baseUrl/api/login",
        body: {"email": email, "password": password});
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (response.statusCode == 200 || response.statusCode == 201) {
      responseJson = json.decode(response.body);
      if (mounted) {
        setState(() {
          _isloading = false;
          emailPrint = email;
          print(email);
          sharedPreferences.setString("email", emailPrint);
          sharedPreferences.setString("token", responseJson['token']);
          print(responseJson['token']);
          Navigator.of(this.context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => MyApp(
                    value: emailPrint,
                  )));
        });
      }
      return responseJson;
    } else if (response.statusCode == 401) {
      throw Exception("Incorrect Email/Password");
    } else
      throw Exception('Authentication Error');
  }

  Padding button() {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
      // ignore: deprecated_member_use
      child: RaisedButton(
        color: Colors.deepPurpleAccent,
        onPressed: () {
          _isloading = false;
          setState(() {
            signIn(emailcontroller.text, passwordcontroller.text);
          });
        },
        child: Container(
          alignment: Alignment.center,
          height: 35,
          child: Text(
            "Login",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

TextEditingController emailcontroller = new TextEditingController();
TextEditingController passwordcontroller = new TextEditingController();

// @override
// void dispose() {
//   emailcontroller.dispose();
//   passwordcontroller.dispose();
// }

Container passwordSection() {
  return Container(padding: EdgeInsets.fromLTRB(8, 8, 8, 0), child: textPwd());
}

TextField textPwd() {
  return TextField(
    controller: passwordcontroller,
    showCursor: false,
    readOnly: false,
    autocorrect: true,
    obscureText: true,
    decoration: InputDecoration(
      alignLabelWithHint: true,
      hintText: 'Password',
      labelText: 'Password',
      prefixIcon: Icon(
        Icons.security,
        size: 30,
      ),
      hintStyle: TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white70,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.black, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
    ),
  );
}

Container headerSection() {
  return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 0), child: textEmail());
}

TextField textEmail() {
  return TextField(
    controller: emailcontroller,
    showCursor: false,
    readOnly: false,
    autocorrect: true,
    decoration: InputDecoration(
      hintText: 'Email Address',
      labelText: 'Email id',
      prefixIcon: Icon(
        Icons.email,
        size: 30,
      ),
      hintStyle: TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white70,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.black, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
    ),
  );
}
