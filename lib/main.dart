 // ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:corev3/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
       theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      routes: {
        '/home': (context) => HomeScreen(),
      },

    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Canh giữa theo trục chính
        crossAxisAlignment:
            CrossAxisAlignment.center, // Canh giữa theo trục ngang
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 540,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/backround.png.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: <Widget>[
                Text(
                  'Choose your prefered hiking trailer',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center, // Căn giữa văn bản
                ),
                SizedBox(height: 10),
                Text(
                  'Find a hiking trail that fits you the best based on your personal preferences',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                  child: Text('Get Started'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

