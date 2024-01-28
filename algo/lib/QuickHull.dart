import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class QuickHullScreen extends StatefulWidget {
  @override
  _QuickHullScreenState createState() => _QuickHullScreenState();
}

class _QuickHullScreenState extends State<QuickHullScreen> {
  List<Point> points = [];
  List<Point> convexHull = [];
  int step = 0;
  int foundPoints = 0;
  int timeTaken = 0; // default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 64, 140, 255),
          title: const Text(
            'Quick Hull Convex Hull Solution',
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
                  'Black Dots = Random Points',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 2,
                ),
                Text(
                  'Blue Lines = Convex Hull Lines',
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
                    painter: QuickHullPainter(points, convexHull, step),
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

                runQuickHull();

                stopwatch.stop();
                setState(() {
                  timeTaken = stopwatch.elapsedMilliseconds;
                  timeTaken++;
                });
              },
              child: const Text('Run Quick Hull'),
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
                  '$foundPoints Points Found on Convex Hull',
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
      points.clear();
      convexHull.clear();
      step = 0;

      Random random = Random();
      for (int i = 0; i < 20; i++) {
        points.add(Point(
          random.nextDouble() * 200 + 50,
          random.nextDouble() * 200 + 50,
        ));
      }
    });
  }

  void runQuickHull() {
    setState(() {
      convexHull = quickHull(points);
      step = 0;
    });

    _runQuickHullStepByStep(convexHull, 0, convexHull.length - 1);
    foundPoints = convexHull.length - 2;
  }

  Future<void> _runQuickHullStepByStep(
      List<Point> points, int left, int right) async {
    if (left >= right) return;

    // Find the point with the maximum distance
    int pivot = findPivot(points, left, right);

    // Recursively compute the convex hull for points on the left and right of the pivot
    await Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        step = pivot;
      });
    });

    await _runQuickHullStepByStep(points, left, pivot);
    await _runQuickHullStepByStep(points, pivot, right);
  }

  int findPivot(List<Point> points, int left, int right) {
    // Find the point with the maximum distance
    double maxDistance = 0;
    int pivot = left;

    for (int i = left + 1; i < right; i++) {
      double distance = distanceToLine(points[left], points[right], points[i]);
      if (distance > maxDistance) {
        maxDistance = distance;
        pivot = i;
      }
    }

    return pivot;
  }

  List<Point> quickHull(List<Point> points) {
    // Sort the points by x-coordinate
    points.sort((a, b) => a.x.compareTo(b.x));

    List<Point> upperHull = buildHull(points);
    List<Point> lowerHull = buildHull(points.reversed.toList());

    // Combine the upper and lower hulls
    return [...upperHull, ...lowerHull];
  }

  List<Point> buildHull(List<Point> points) {
    List<Point> hull = [];
    for (Point point in points) {
      while (hull.length >= 2 &&
          orientation(hull[hull.length - 2], hull.last, point) != 2) {
        hull.removeLast();
      }
      hull.add(point);
    }
    return hull;
  }

  int orientation(Point p, Point q, Point r) {
    double val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);
    return (val > 0)
        ? 1
        : (val < 0)
            ? 2
            : 0;
  }

  double distanceToLine(Point a, Point b, Point c) {
    double numerator = (c.y - a.y) * (b.x - a.x) - (c.x - a.x) * (b.y - a.y);
    double denominator = sqrt(pow(b.y - a.y, 2) + pow(b.x - a.x, 2));
    return numerator.abs() / denominator;
  }
}

class Point {
  double x;
  double y;

  Point(this.x, this.y);
}

class QuickHullPainter extends CustomPainter {
  final List<Point> points;
  final List<Point> convexHull;
  final int step;

  QuickHullPainter(this.points, this.convexHull, this.step);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw points
    Paint pointPaint = Paint()..color = Colors.black;
    for (Point point in points) {
      canvas.drawCircle(Offset(point.x, point.y), 4, pointPaint);
    }

    // Draw convex hull
    Paint hullPaint = Paint()
      ..color = Colors.blue.shade800
      ..strokeWidth = 2;
    for (int i = 0; i < convexHull.length - 1; i++) {
      canvas.drawLine(
        Offset(convexHull[i].x, convexHull[i].y),
        Offset(convexHull[i + 1].x, convexHull[i + 1].y),
        hullPaint,
      );
    }

    // Draw step point
    if (step < convexHull.length) {
      Paint stepPaint = Paint()..color = Colors.red;
      canvas.drawCircle(
        Offset(convexHull[step].x, convexHull[step].y),
        6,
        stepPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
