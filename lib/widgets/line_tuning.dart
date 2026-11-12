import 'package:flutter/material.dart';
import 'package:joystick/constants.dart';
import 'package:joystick/l10n/app_localizations.dart';
import 'package:joystick/models/line_follower.dart';

BoxDecoration _cardDecoration() => BoxDecoration(
      color: kWidgetColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white, width: 0.5),
    );

/// Error medio (promedio del valor absoluto de la posicion) de las muestras en
/// que se vio la linea; null si no hay ninguna. Sirve para comparar ajustes del
/// PID en el mismo tramo de pista: mas bajo = el robot va mas centrado.
int? averageError(List<int?> history) {
  final seen = history.whereType<int>().toList();
  if (seen.isEmpty) return null;
  return seen.fold<int>(0, (sum, p) => sum + p.abs()) ~/ seen.length;
}

/// Grafica de la posicion de la linea en el tiempo (la mas reciente a la
/// derecha). Una curva que cruza el centro de un lado a otro es oscilacion: baja
/// Kp o sube Kd. Una curva que tarda en volver al centro: sube Kp. Las marcas
/// rojas abajo son los momentos en que el robot no vio la linea.
class PositionChart extends StatelessWidget {
  final List<int?> history;
  final int capacity;

  const PositionChart(
      {super.key, required this.history, required this.capacity});

  @override
  Widget build(BuildContext context) {
    AppLocalizations texts = AppLocalizations.of(context)!;
    final error = averageError(history);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(texts.positionHistory,
                    style: kTitleText, overflow: TextOverflow.ellipsis),
              ),
              Text(texts.averageError(error?.toString() ?? '-'),
                  style: kSubtitleText),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('S7', style: kSubtitleText.copyWith(fontSize: 10)),
                    Text('0', style: kSubtitleText.copyWith(fontSize: 10)),
                    Text('S0', style: kSubtitleText.copyWith(fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CustomPaint(
                      painter: _PositionPainter(history, capacity),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionPainter extends CustomPainter {
  final List<int?> history;
  final int capacity;

  _PositionPainter(this.history, this.capacity);

  @override
  void paint(Canvas canvas, Size size) {
    const range = LineProtocol.positionRange;
    canvas.drawRect(Offset.zero & size, Paint()..color = kBackgroundColor);

    // Centro (linea bajo el robot) y bandas de +/- 1000 (un sensor de distancia).
    final band = size.height / 2 * 1000 / range;
    canvas.drawRect(
        Rect.fromLTWH(0, size.height / 2 - band, size.width, 2 * band),
        Paint()..color = kMathColor.withValues(alpha: 0.12));
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), Paint()..color = Colors.white54);

    if (history.isEmpty || capacity < 2) return;
    final dx = size.width / (capacity - 1);
    // La muestra mas reciente queda en el borde derecho.
    final offset = capacity - history.length;
    double x(int i) => (i + offset) * dx;
    double y(int p) => size.height / 2 - p / range * size.height / 2;

    final line = Paint()
      ..color = kOutputColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final lost = Paint()..color = Colors.red;

    Path? path;
    for (var i = 0; i < history.length; i++) {
      final p = history[i];
      if (p == null) {
        // Sin linea: se corta la curva y se marca abajo.
        if (path != null) canvas.drawPath(path, line);
        path = null;
        canvas.drawRect(
            Rect.fromLTWH(x(i) - dx / 2, size.height - 4, dx, 4), lost);
        continue;
      }
      if (path == null) {
        path = Path()..moveTo(x(i), y(p));
      } else {
        path.lineTo(x(i), y(p));
      }
    }
    if (path != null) canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(_PositionPainter old) => true;
}

/// Calibracion guardada en el robot: para cada sensor, una barra de 0 a 255 con
/// el rango entre su negro y su blanco (sin calibrar). Verde si tiene contraste
/// suficiente, rojo si no; debajo, el contraste.
class CalibrationRangesCard extends StatelessWidget {
  final SensorCalibration? calibration;

  const CalibrationRangesCard({super.key, required this.calibration});

  @override
  Widget build(BuildContext context) {
    AppLocalizations texts = AppLocalizations.of(context)!;
    final cal = calibration;

    String status;
    Color statusColor = Colors.white70;
    if (cal == null) {
      status = texts.calibrationWaiting;
    } else if (cal.isDefault) {
      status = texts.notCalibrated;
      statusColor = kControlColor;
    } else {
      final weak = [
        for (var i = 0; i < LineProtocol.sensorCount; i++)
          if (!cal.hasContrast(i)) 'S$i'
      ];
      if (weak.isEmpty) {
        status = texts.calibrationOk;
        statusColor = kMathColor;
      } else {
        status = texts.calibrationWeak(weak.join(', '));
        statusColor = Colors.redAccent;
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(texts.storedCalibration, style: kTitleText),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(status,
                style: kSubtitleText.copyWith(fontSize: 13, color: statusColor)),
          ),
          if (cal != null && !cal.isDefault) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: Row(
                children: [
                  for (var i = 0; i < LineProtocol.sensorCount; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _rangeBar(cal, i),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (var i = 0; i < LineProtocol.sensorCount; i++)
                  Expanded(
                    child: Column(
                      children: [
                        Text('S$i',
                            textAlign: TextAlign.center,
                            style: kSubtitleText.copyWith(fontSize: 12)),
                        Text('${cal.contrast(i)}',
                            textAlign: TextAlign.center,
                            style: kScaleTextStyle.copyWith(
                                fontSize: 11,
                                color: cal.hasContrast(i)
                                    ? kMathColor
                                    : Colors.redAccent)),
                      ],
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
              child: Text(texts.storedCalibrationMessage,
                  style: kSubtitleText.copyWith(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rangeBar(SensorCalibration cal, int i) {
    return LayoutBuilder(builder: (context, constraints) {
      final h = constraints.maxHeight;
      double y(int v) => h * v.clamp(0, 255) / 255;
      final color = cal.hasContrast(i) ? kMathColor : Colors.redAccent;
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
              bottom: y(cal.black[i]),
              height: (y(cal.white[i]) - y(cal.black[i])).clamp(2.0, h),
              child: Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.6),
                  border: Border.all(color: color, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
