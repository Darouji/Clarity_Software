// lib/widgets/pie_chart.dart
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/client/project_details_screen.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// Lógica de colores (corregida en el paso anterior, se mantiene)
Color _getProjectColorByProgress(double progress) {
  if (progress == 0.0) return AppColors.accentMagenta; // 0%
  if (progress < 0.41) return AppColors.accentOrange; // 1% - 40%
  if (progress < 1.0) return AppColors.cyberBlue; // 41% - 99%
  return AppColors.accentGreen; // 100%
}

class PieChart extends StatefulWidget {
  final List<Project> projects;
  final double size;

  const PieChart({super.key, required this.projects, this.size = 220});

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get _globalProgress {
    if (widget.projects.isEmpty) return 0.0;
    final total = widget.projects.fold<double>(
      0.0,
      (sum, p) => sum + p.overallProgress,
    );
    return total / widget.projects.length;
  }

  // Normaliza un ángulo a [0, 2π)
  double _norm(double angle) {
    // --- CORRECCIÓN LINTER ---
    // Se elimina la variable 'twoPi' no utilizada
    // y se usa el valor (2 * math.pi) directamente.
    angle = angle % (2 * math.pi);
    if (angle < 0) angle += (2 * math.pi);
    // --- FIN CORRECCIÓN ---
    return angle;
  }

  // Devuelve true si 'angle' cae dentro del sector [start, start+sweep) con wrap correcto
  bool _angleInRange(double angle, double start, double sweep) {
    // final twoPi = 2 * math.pi; // Esta variable no es necesaria aquí tampoco
    final s = _norm(start);
    final e = _norm(start + sweep);
    angle = _norm(angle);

    if (s == e) return sweep > 0; // barrido completo
    if (s < e) {
      return angle >= s && angle < e;
    } else {
      // envuelve 2π -> 0
      return angle >= s || angle < e;
    }
  }

  void _handleTap(BuildContext context, TapDownDetails details) {
    final Offset tapLocal = details.localPosition;
    final renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double outerRadius = math.min(size.width, size.height) / 2;

    final double innerRadius = outerRadius * 0.70;

    final double dx = tapLocal.dx - center.dx;
    final double dy = tapLocal.dy - center.dy;
    final double distance = math.sqrt(dx * dx + dy * dy);
    if (distance > outerRadius || distance < innerRadius) return;

    final double tapAngle = _norm(math.atan2(dy, dx));

    const double minProgressValue = 0.05;
    final double totalAdjusted = widget.projects.fold<double>(
      0.0,
      (sum, p) => sum + math.max(p.overallProgress, minProgressValue),
    );
    if (totalAdjusted == 0) return;

    const double gapAngle = 0.08;

    final int numGaps = widget.projects.length;
    final double totalGapAngle = gapAngle * numGaps;
    final double totalAvailableAngle = (2 * math.pi) - totalGapAngle;

    double startAngle = _norm(-math.pi / 2);

    for (final project in widget.projects) {
      final double adjusted = math.max(
        project.overallProgress,
        minProgressValue,
      );
      final double sweep = (adjusted / totalAdjusted) * totalAvailableAngle;

      if (_angleInRange(tapAngle, startAngle, sweep)) {
        _showProjectDetailsPopup(context, project, details.globalPosition);
        return;
      }
      startAngle = _norm(startAngle + sweep + gapAngle);
    }
  }

  void _showProjectDetailsPopup(
    BuildContext context,
    Project project,
    Offset tapGlobal,
  ) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset localOffset = overlay.globalToLocal(tapGlobal);

    final double clampedX = localOffset.dx.clamp(
      20.0,
      overlay.size.width - 220.0,
    );
    final double clampedY = localOffset.dy.clamp(
      20.0,
      overlay.size.height - 120.0,
    );

    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'Project Details Popup',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            Positioned(
              left: clampedX - 100,
              top: clampedY - 75,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.cardBlack.withAlpha(240),
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: _getProjectColorByProgress(
                        project.overallProgress,
                      ),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getProjectColorByProgress(
                          project.overallProgress,
                        ).withAlpha(120),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        project.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Estado: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.neonYellow,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${project.status} (${(project.overallProgress * 100).toStringAsFixed(0)}%)',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.cyberBlue,
                          side: const BorderSide(
                            color: AppColors.cyberBlue,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProjectDetailsScreen(project: project),
                            ),
                          );
                        },
                        child: const Text('Ver Detalles'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Builder(
          builder: (BuildContext innerContext) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => _handleTap(innerContext, details),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(
                  painter: _PieChartPainter(
                    projects: widget.projects,
                    animationValue: _animation.value,
                    cardColor: theme.scaffoldBackgroundColor,
                  ),
                  child: Center(
                    child: Text(
                      '${(_globalProgress * 100).toStringAsFixed(0)}%',
                      style: textStyle,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<Project> projects;
  final double animationValue;
  final Color cardColor;

  _PieChartPainter({
    required this.projects,
    required this.animationValue,
    required this.cardColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (projects.isEmpty) return;

    final Paint paint = Paint()..style = PaintingStyle.fill;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double outerRadius = math.min(size.width / 2, size.height / 2);
    final double innerRadius = outerRadius * 0.70; // 70% del radio

    const double gapAngle = 0.08; // <-- Usamos el valor unificado de 0.08

    final int numGaps = projects.length;
    final double totalGapAngle = gapAngle * numGaps;
    final double totalAvailableAngle = (2 * math.pi) - totalGapAngle;
    final double animatedTotalAngle = totalAvailableAngle * animationValue;

    const double minProgressValue = 0.05;

    final double totalAdjusted = projects.fold<double>(
      0.0,
      (sum, p) => sum + math.max(p.overallProgress, minProgressValue),
    );
    if (totalAdjusted == 0) return;

    double startAngle = -math.pi / 2;

    for (final project in projects) {
      final double adjusted = math.max(
        project.overallProgress,
        minProgressValue,
      );
      final double sweepAngle = (adjusted / totalAdjusted) * animatedTotalAngle;

      paint.color = _getProjectColorByProgress(project.overallProgress);

      final Path path = Path();

      // --- CORRECCIÓN LINTER ---
      // Se eliminaron 'outerRRect' e 'innerRRect' que no se usaban.
      final Rect outerRect = Rect.fromCircle(
        center: center,
        radius: outerRadius,
      );
      final Rect innerRect = Rect.fromCircle(
        center: center,
        radius: innerRadius,
      );
      // --- FIN CORRECCIÓN ---

      path.arcTo(outerRect, startAngle, sweepAngle, false);

      path.arcTo(innerRect, startAngle + sweepAngle, -sweepAngle, false);

      path.close();

      canvas.drawPath(path, paint);

      startAngle += sweepAngle + gapAngle;
    }

    final innerCirclePaint = Paint()..color = cardColor;
    canvas.drawCircle(center, innerRadius, innerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter old) {
    return old.animationValue != animationValue || old.projects != projects;
  }
}
