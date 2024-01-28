import 'dart:math';
import 'package:flutter/material.dart';

class Point {
  double x, y;

  Point(this.x, this.y);
}

class ConvexHullApp extends StatefulWidget {
  @override
  _ConvexHullAppState createState() => _ConvexHullAppState();
}

class _ConvexHullAppState extends State<ConvexHullApp> {
  List<Point> points = [];
  List<Point> convexHull = [];
  int lengthFound = 0;
  int timeTaken = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 64, 140, 255),
          title: const Text(
            'Graham Scan Convex Hull Solution',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ), // Set to 0 to remove the shadow
          ),
          centerTitle: true,
          elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Column(
              children: [
                Text(
                  'Total Points = 20',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Blue Dots = Random Points',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 2,
                ),
                Text(
                  'Red Lines = Convex Hull Lines',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Expanded(
              child: Card(
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(
                          255, 113, 96, 96), // Specify the border color
                      width: 2.0, // Specify the border width
                    ),
                  ),
                  child: CustomPaint(
                    painter: ConvexHullPainter(points, convexHull),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: generateRandomPoints,
              child: const Text('Generate Random Points'),
            ),
            ElevatedButton(
              onPressed: () {
                final stopwatch = Stopwatch()..start();

                runGrahamScan();

                stopwatch.stop();
                setState(() {
                  timeTaken = stopwatch.elapsedMilliseconds;
                  timeTaken++;
                });
              },
              child: const Text('Run Graham Scan'),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              color: Colors.blueGrey,
              width: 200,
              height: 30,
              child: Center(
                child: Text(
                  '$lengthFound Points Found on Convex Hull',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Execution Time'),
                      content: Text('Time Complexity: $timeTaken milliseconds'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Show Execution time'),
            ),
          ],
        ),
      ),
    );
  }

  void generateRandomPoints() {
    setState(() {
      points = List.generate(
        10,
        (index) => Point(
          Random().nextDouble() * 300 + 50,
          Random().nextDouble() * 300 + 50,
        ),
      );
      convexHull = [];
    });
  }

  void runGrahamScan() {
    setState(() {
      convexHull = grahamScan(points);
    });
  }

  List<Point> grahamScan(List<Point> points) {
    int orientation(Point p, Point q, Point r) {
      double val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);
      if (val == 0) return 0; // Collinear
      return val > 0 ? 1 : 2; // Clockwise or Counterclockwise
    }

    List<Point> convexHull = [];

    int n = points.length;
    if (n < 3) return points;

    Point pivot = points.reduce((curr, next) => curr.y < next.y ? curr : next);

    points.sort((a, b) {
      double angleA = atan2(a.y - pivot.y, a.x - pivot.x);
      double angleB = atan2(b.y - pivot.y, b.x - pivot.x);
      return angleA.compareTo(angleB);
    });

    convexHull.add(pivot);
    convexHull.add(points[1]);

    for (int i = 2; i < n; i++) {
      while (convexHull.length > 1 &&
          orientation(convexHull[convexHull.length - 2],
                  convexHull[convexHull.length - 1], points[i]) !=
              2) {
        convexHull.removeLast();
      }
      convexHull.add(points[i]);
    }

    lengthFound = convexHull.length;
    return convexHull;
  }
}

class ConvexHullPainter extends CustomPainter {
  final List<Point> points;
  final List<Point> convexHull;

  ConvexHullPainter(this.points, this.convexHull);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pointPaint = Paint()..color = Colors.blue.shade800;
    final Paint convexHullPaint = Paint()..color = Colors.red.shade900;

    points.forEach((point) {
      canvas.drawCircle(Offset(point.x, point.y), 3, pointPaint);
    });

    if (convexHull.isNotEmpty) {
      for (int i = 0; i < convexHull.length - 1; i++) {
        canvas.drawLine(
          Offset(convexHull[i].x, convexHull[i].y),
          Offset(convexHull[i + 1].x, convexHull[i + 1].y),
          convexHullPaint,
        );
      }
      canvas.drawLine(
        Offset(convexHull.last.x, convexHull.last.y),
        Offset(convexHull.first.x, convexHull.first.y),
        convexHullPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
