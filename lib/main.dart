import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert' show json, utf8, base64, ascii;

final storage = FlutterSecureStorage();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<String> get appTokenOrEmpty async {
    var token = await storage.read(key: "token");
    if (token == null) return "";
    //print(token);
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'helper',
      theme: ThemeData(primaryColor: Color.fromARGB(255, 156, 54, 198)),
      home: FutureBuilder(
          future: appTokenOrEmpty,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            if (snapshot.data != "") {
              var str = snapshot.data;
              var token = str.split("-");

              if (token.length != 4) {
                return LoginPage();
              } else {
                var payload = json.decode(
                    ascii.decode(base64.decode(base64.normalize(token[1]))));
                if (DateTime.fromMillisecondsSinceEpoch(payload["-"] * 1000)
                    .isAfter(DateTime.now())) {
                  return HomePage(str, payload);
                } else {
                  return LoginPage();
                }
              }
            } else {
              return LoginPage();
            }
          }),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _emailnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(text),
        ),
      );

  Future<String> attemptLogIn(String email, String password) async {
    var res = await http.post(
        "https://api-courier.skipthedishes.com/v1/couriers/login",
        headers: {
          //"Transfer-Encoding": "chunked",
          "app-token": "decff1f4-fd24-4e6b-8edd-4f20df798e9b",
        },
        body: json.encode({"email": email, "password": password}));
    if (res.statusCode == 200) return res.body;
    print(json.decode);

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Log In"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _emailnameController,
                decoration: InputDecoration(labelText: 'email'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: false,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              TextButton(
                  onPressed: () async {
                    var email = _emailnameController.text;
                    var password = _passwordController.text;
                    var token = await attemptLogIn(email, password);
                    if (token != null) {
                      storage.write(key: 'token', value: token);
                      // print(token);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage.fromUtf8(token),
                        ),
                      );
                    } else {
                      displayDialog(context, "An Error Occurred",
                          "No account was found matching that username and password");
                    }
                  },
                  child: Text("Log In")),
            ],
          ),
        ));
  }
}

class HomePage extends StatelessWidget {
  final id = storage.read(key: 'id');
  final name = storage.read(key: 'name');
  HomePage(this.token, this.payload);

  factory HomePage.fromUtf8(String token) => HomePage(
        token,
        json.decode(
          ascii.decode(
            base64.decode(
              base64.normalize(
                token.toString(),
              ),
            ),
          ),
        ),
      );
  final String token;
  final Map<String, dynamic> payload;

  Stream<List<int>> get byteStream => null;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Secret Data Screen")),
        body: Center(
          child: FutureBuilder(
              future: http.read(
                  "https://api-courier.skipthedishes.com/v2/couriers/$id",
                  headers: {
                    "Transfer-Encoding": "chunked",
                    "app-token": "decff1f4-fd24-4e6b-8edd-4f20df798e9b",
                    "token": token
                  }),
              builder: (context, snapshot) => snapshot.hasData
                  ? Column(
                      children: <Widget>[
                        Text("${payload['name']}, here's the data:"),
                        Text(snapshot.data,
                            style: Theme.of(context).textTheme.bodyText1)
                      ],
                    )
                  : snapshot.hasError
                      ? Text("cool")
                      : CircularProgressIndicator()),
        ),
      );
}
