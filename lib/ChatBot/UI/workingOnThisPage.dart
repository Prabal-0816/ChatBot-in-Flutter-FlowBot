import 'package:flutter/material.dart';

class WorkingOnThisPage extends StatelessWidget {
  final String featureName;
  final String applianceName;

  const WorkingOnThisPage({
    Key? key,
    required this.featureName,
    required this.applianceName
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFAB2138),
          title: Text('$featureName Feature'),
        ),
        body: Center(
          child: Text(
            '$applianceName AI coming soon...',
            style: const TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),
          ),
        )
    );
  }
}