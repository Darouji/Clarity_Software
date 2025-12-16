// lib/widgets/bar_chart.dart
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/client/project_details_screen.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// Lógica de color
Color _getProjectColorByProgress(double progress) {
  if (progress == 0.0) return AppColors.accentMagenta; // 0%
  if (progress < 0.41) return AppColors.accentOrange; // 1% - 40%
  if (progress < 1.0) return AppColors.cyberBlue; // 41% - 99%
  return AppColors.accentGreen; // 100%
}

class BarChart extends StatefulWidget {
  final List<Project> projects;
  final double size;

  const BarChart({super.key, required this.projects, this.size = 220});

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart>
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

  void _handleTap(BuildContext context, TapDownDetails details) {
    if (widget.projects.isEmpty) return;

    final Offset tapLocal = details.localPosition;
    final renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final double chartHeight = size.height;

    // Ajuste de Altura para UI segura
    final double maxBarHeight = chartHeight * 0.85; // Margen para texto
    final double minBarHeight = chartHeight * 0.05;

    const double barGap = 12.0;
    // Espacio total ocupado por gaps (n+1 gaps)
    final double totalGaps = barGap * (widget.projects.length + 1);
    // Ancho restante dividido por número de proyectos
    final double barWidth = (size.width - totalGaps) / widget.projects.length;

    double currentLeft = barGap;

    for (final project in widget.projects) {
      final double barHeight = math.max(
        maxBarHeight * project.overallProgress,
        minBarHeight,
      );

      final Rect barRect = Rect.fromLTWH(
        currentLeft,
        chartHeight - barHeight,
        barWidth,
        barHeight,
      );

      // Expandimos ligeramente el área de toque horizontalmente para mejor UX
      final Rect touchArea = barRect.inflate(barGap / 2);

      if (touchArea.contains(tapLocal)) {
        _showProjectDetailsPopup(context, project, details.globalPosition);
        return;
      }
      currentLeft += barWidth + barGap;
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
                  painter: _BarChartPainter(
                    projects: widget.projects,
                    animationValue: _animation.value,
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

class _BarChartPainter extends CustomPainter {
  final List<Project> projects;
  final double animationValue;

  _BarChartPainter({required this.projects, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (projects.isEmpty) return;

    final Paint paint = Paint();
    final double chartHeight = size.height;
    const double barGap = 12.0;
    const double cornerRadius = 6.0;

    // Altura máxima reservada para la barra (dejando espacio para texto)
    final double maxBarHeight = chartHeight * 0.85;
    // Altura mínima visual (para 0% de progreso, que se vea algo)
    final double minBarHeight = chartHeight * 0.05;

    final double totalGaps = barGap * (projects.length + 1);
    final double barWidth = (size.width - totalGaps) / projects.length;

    double currentLeft = barGap;

    for (final project in projects) {
      final double targetHeight = math.max(
        maxBarHeight * project.overallProgress,
        minBarHeight,
      );

      final double animatedHeight = targetHeight * animationValue;
      paint.color = _getProjectColorByProgress(project.overallProgress);

      final RRect barRRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          currentLeft,
          chartHeight - animatedHeight,
          barWidth,
          animatedHeight,
        ),
        topLeft: const Radius.circular(cornerRadius),
        topRight: const Radius.circular(cornerRadius),
      );

      canvas.drawRRect(barRRect, paint);

      // --- PINTAR TEXTO DE PORCENTAJE ---
      final String percentText =
          '${(project.overallProgress * 100).toStringAsFixed(0)}%';

      final textSpan = TextSpan(
        text: percentText,
        style: const TextStyle(
          color: Colors.white, // Forzamos blanco para visibilidad
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      // Limitamos el ancho del texto al ancho de la barra para evitar desbordes
      textPainter.layout(minWidth: 0, maxWidth: barWidth + 20);

      // Centrado Horizontal
      final double barCenterX = currentLeft + (barWidth / 2);
      final double textX = barCenterX - (textPainter.width / 2);

      // Posición Vertical: Justo encima de la barra
      final double barTopY = chartHeight - animatedHeight;
      final double textY = barTopY - textPainter.height - 4.0;

      textPainter.paint(canvas, Offset(textX, textY));

      currentLeft += barWidth + barGap;
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) {
    return old.animationValue != animationValue || old.projects != projects;
  }
}
