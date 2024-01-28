import 'package:flutter/material.dart';
import 'GrahamScan.dart';
import 'QuickHull.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Convex Hull Algorithms'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return ConvexHullApp();
                    }),
                  );
                },
                child: const Text('Graham Scan'),
              ),
              const SizedBox(height: 20), // Adding some space between buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return QuickHullScreen();
                    }),
                  );
                },
                child: const Text('Quick Hull'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
