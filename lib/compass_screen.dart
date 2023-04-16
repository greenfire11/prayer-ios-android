import 'package:flutter/material.dart';
import 'package:smooth_compass/utils/smooth_compass.dart';
import 'package:smooth_compass/utils/src/compass_ui.dart';
import 'package:smooth_compass/utils/src/qibla_utils.dart';
import 'package:smooth_compass/utils/src/widgets/error_widget.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: SmoothCompass(
            height: 200,
            width: 200,
            isQiblahCompass: true,
            compassBuilder: (context, snapshot, child) {
              return AnimatedRotation(
                duration: const Duration(milliseconds: 800),
                turns: snapshot?.data?.turns ?? 0,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Image.asset(
                        "assets/images/compass.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                    
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedRotation(
                          duration: const Duration(milliseconds: 500),
                          turns: (snapshot?.data?.qiblahOffset ?? 0) / 360,

                          //Place your qiblah needle here
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: const VerticalDivider(
                              color: Colors.grey,
                              thickness: 5,
                            ),
                          )),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
