import 'package:flutter/material.dart';
import 'package:joystick/constants.dart';
import 'package:joystick/l10n/app_localizations.dart';
import 'package:joystick/models/line_follower.dart';

BoxDecoration _cardDecoration() => BoxDecoration(
      color: kWidgetColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white, width: 0.5),
    );

/// Barras con las 8 lecturas del sensor de linea (0-255), S0 a la izquierda.
class SensorBars extends StatelessWidget {
  final SensorReading? reading;
  const SensorBars({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    AppLocalizations texts = AppLocalizations.of(context)!;
    final reading = this.reading;

    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: reading == null
          ? Center(child: Text(texts.sensorsWaiting, style: kSubtitleText))
          : Row(
              children: [
                for (var i = 0; i < reading.values.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        children: [
                          Text('${reading.values[i]}',
                              style: kScaleTextStyle.copyWith(fontSize: 11)),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: kBackgroundColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor:
                                    (reading.values[i] / 255).clamp(0.02, 1.0),
                                widthFactor: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: kOutputColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('S$i', style: kSubtitleText.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Posicion de la linea bajo el robot: -3500 (bajo S0) a 3500 (bajo S7).
class LinePositionBar extends StatelessWidget {
  final int? position;
  const LinePositionBar({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    AppLocalizations texts = AppLocalizations.of(context)!;
    final position = this.position;
    const range = LineProtocol.positionRange;
    const marker = 20.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(texts.position, style: kTitleText),
              Text(position?.toString() ?? '-', style: kSubtitleText),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: marker + 4,
            child: LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                children: [
                  Positioned.fill(
                    top: 8,
                    bottom: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kBackgroundColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Positioned(
                    left: width / 2 - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.white54),
                  ),
                  if (position != null)
                    Positioned(
                      left: ((position + range) / (2 * range) * width -
                              marker / 2)
                          .clamp(0.0, width - marker),
                      top: 2,
                      child: Container(
                        width: marker,
                        height: marker,
                        decoration: BoxDecoration(
                          color: kMathColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
