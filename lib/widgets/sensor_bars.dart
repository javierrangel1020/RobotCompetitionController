import 'package:flutter/material.dart';
import 'package:joystick/constants.dart';
import 'package:joystick/l10n/app_localizations.dart';
import 'package:joystick/models/line_follower.dart';

BoxDecoration _cardDecoration() => BoxDecoration(
      color: kWidgetColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white, width: 0.5),
    );

/// Topes posibles de la escala vertical de las barras.
const List<int> kBarScales = [64, 128, 255];

/// La escala mas chica en la que cabe [value]: asi las lecturas bajas (por
/// ejemplo sin calibrar, cuando el blanco da 50 o 60) se ven grandes.
int barScaleFor(int value) =>
    kBarScales.firstWhere((s) => value <= s, orElse: () => kBarScales.last);

/// Color de la raya del umbral (tambien el del control deslizante).
Color kThresholdColor = kControlColor;

/// Barras con las 8 lecturas del sensor de linea, S0 a la izquierda, en una
/// escala de 0 a [scale].
///
/// Normalmente dibuja el umbral como una raya que cruza todas las barras, con
/// la zona que cuenta como linea sombreada en verde, y pinta de verde los
/// sensores que ven la linea. Arrastrar o tocar sobre las barras mueve la raya
/// ([onThresholdChanged] mientras se mueve, [onThresholdChangeEnd] al soltar).
///
/// Calibrando ([calMin] y [calMax] no nulos) no hay umbral: dibuja el rango
/// visto por cada sensor, y su nombre en verde cuando ya tiene contraste.
class SensorBars extends StatelessWidget {
  final SensorReading? reading;
  final int threshold;
  final LineColor lineColor;
  final int scale;
  final List<int>? calMin;
  final List<int>? calMax;
  final ValueChanged<int>? onThresholdChanged;
  final VoidCallback? onThresholdChangeEnd;

  const SensorBars({
    super.key,
    required this.reading,
    required this.threshold,
    required this.lineColor,
    this.scale = 255,
    this.calMin,
    this.calMax,
    this.onThresholdChanged,
    this.onThresholdChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations texts = AppLocalizations.of(context)!;
    final reading = this.reading;
    final calMin = this.calMin;
    final calMax = this.calMax;
    final calibrating = calMin != null && calMax != null;

    if (reading == null) {
      return Container(
        height: 240,
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Center(child: Text(texts.sensorsWaiting, style: kSubtitleText)),
      );
    }

    final count = reading.values.length;
    final level = LineProtocol.thresholdLevel(threshold, lineColor);

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text('${texts.scale} 0-$scale',
                style: kSubtitleText.copyWith(fontSize: 11)),
          ),
          Row(
            children: [
              for (var i = 0; i < count; i++)
                Expanded(
                  child: Text('${reading.values[i]}',
                      textAlign: TextAlign.center,
                      style: kScaleTextStyle.copyWith(fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final h = constraints.maxHeight;
              double y(int v) => h * v.clamp(0, scale) / scale;

              Widget area = Stack(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < count; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: calibrating
                                ? _bar(reading.values[i], kOutputColor, y, h,
                                    rangeMin: calMin[i], rangeMax: calMax[i])
                                : _bar(
                                    reading.values[i],
                                    LineProtocol.onLine(reading.values[i],
                                            threshold, lineColor)
                                        ? kMathColor
                                        : kOutputColor,
                                    y,
                                    h),
                          ),
                        ),
                    ],
                  ),
                  if (!calibrating) ...[
                    // Zona que cuenta como linea: debajo de la raya con linea
                    // negra (valores bajos), encima con linea blanca.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: lineColor == LineColor.black ? 0 : y(level),
                      height: lineColor == LineColor.black
                          ? y(level)
                          : h - y(level),
                      child: IgnorePointer(
                        child: Container(
                            color: kMathColor.withValues(alpha: 0.15)),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: (y(level) - 1.5).clamp(0.0, h - 3),
                      height: 3,
                      child: IgnorePointer(
                        child: Container(color: kThresholdColor),
                      ),
                    ),
                  ],
                ],
              );

              final onChanged = onThresholdChanged;
              if (!calibrating && onChanged != null) {
                // Posicion del dedo -> umbral, en la misma escala que las barras.
                void drag(double dy) {
                  final v = ((1 - dy / h) * scale).round().clamp(0, 255);
                  final t = lineColor == LineColor.black ? v : 255 - v;
                  onChanged(t.clamp(LineFollowerParams.minThreshold,
                      LineFollowerParams.maxThreshold));
                }

                area = GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragStart: (d) => drag(d.localPosition.dy),
                  onVerticalDragUpdate: (d) => drag(d.localPosition.dy),
                  onVerticalDragEnd: (_) => onThresholdChangeEnd?.call(),
                  onTapUp: (d) {
                    drag(d.localPosition.dy);
                    onThresholdChangeEnd?.call();
                  },
                  child: area,
                );
              }
              return area;
            }),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (var i = 0; i < count; i++)
                Expanded(
                  child: Text(
                    'S$i',
                    textAlign: TextAlign.center,
                    style: calibrating &&
                            calMax[i] - calMin[i] >= LineProtocol.minContrast
                        ? kSubtitleText.copyWith(
                            fontSize: 12,
                            color: kMathColor,
                            fontWeight: FontWeight.bold)
                        : kSubtitleText.copyWith(fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Una barra: el valor relleno y, calibrando, el rango visto
  /// ([rangeMin] a [rangeMax]). [y] pasa un valor a pixeles desde abajo.
  Widget _bar(int value, Color color, double Function(int) y, double h,
      {int? rangeMin, int? rangeMax}) {
    return Container(
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: y(value).clamp(h * 0.02, h),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          if (rangeMin != null && rangeMax != null && rangeMax >= rangeMin)
            Positioned(
              left: 0,
              right: 0,
              bottom: y(rangeMin),
              height: (y(rangeMax) - y(rangeMin)).clamp(2.0, h),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
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
