import 'package:flutter/material.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

// complex waveAnimation widget class

class WaveAnimation extends StatelessWidget {
  const WaveAnimation({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 2,
      child: WaveWidget(
        waveFrequency: 1,
        duration: 0,
        config: CustomConfig(
          gradients: [
            [Colors.white.withOpacity(0.4), Colors.blueGrey],
            [Colors.grey, Colors.black26],
            [Colors.orange, const Color(0x66FF9800)],
            [Colors.orange[300], const Color(0xffF7AC1B)]
          ],
          durations: [35000, 19440, 10800, 6000],
          heightPercentages: [0.05, 0.05, 0.05, 0.07],
          gradientBegin: Alignment.bottomLeft,
          gradientEnd: Alignment.topRight,
        ),
        waveAmplitude: 0,
        backgroundColor: const Color(0xff363A46),
        size: const Size(double.infinity, double.infinity),
      ),
    );
  }
}