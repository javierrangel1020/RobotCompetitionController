import 'package:flutter/material.dart';
import 'package:joystick/constants.dart';
import 'package:joystick/l10n/app_localizations.dart';
import 'package:joystick/pages/joystick_page.dart';
import 'package:joystick/pages/line_follower_page.dart';
import 'package:joystick/pages/terminal_page.dart';
import 'package:joystick/widgets/connection_chip.dart';

/// Pantalla de inicio: elige entre joystick, seguidor de linea y terminal.
class InitialPage extends StatelessWidget {
  static const String id = 'InitialPage';
  const InitialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;
    } else {
      screenHeight = MediaQuery.of(context).size.width;
      screenWidth = MediaQuery.of(context).size.height;
    }
    AppLocalizations texts = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('ROBLEX'),
        backgroundColor: kWidgetColor,
        foregroundColor: Colors.white,
        actions: const [ConnectionChip()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _SectionCard(
                  icon: Icons.sports_esports,
                  color: kOutputColor,
                  title: texts.joystick,
                  subtitle: texts.joystickSubtitle,
                  onTap: () => Navigator.pushNamed(context, JoystickPage.id),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _SectionCard(
                  icon: Icons.route,
                  color: kMathColor,
                  title: texts.lineFollower,
                  subtitle: texts.lineFollowerSubtitle,
                  onTap: () =>
                      Navigator.pushNamed(context, LineFollowerPage.id),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _SectionCard(
                  icon: Icons.terminal,
                  color: kControlColor,
                  title: texts.terminal,
                  subtitle: texts.terminalSubtitle,
                  onTap: () => Navigator.pushNamed(context, TerminalPage.id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SectionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kWidgetColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 34),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: kBotonText.copyWith(fontSize: 22)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: kSubtitleText.copyWith(fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
