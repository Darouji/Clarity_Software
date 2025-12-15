// lib/screens/client/overview_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/dashboard_config.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/client/booking_screen.dart'; // Importar Booking
import 'package:clarity_software/screens/client/dashboard_customizer_dialog.dart';
import 'package:clarity_software/screens/client/project_details_screen.dart';
import 'package:clarity_software/services/preference_service.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:clarity_software/services/project_service.dart';
import 'package:clarity_software/services/view_status_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:clarity_software/widgets/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:clarity_software/widgets/info_block.dart';
import 'package:clarity_software/widgets/bar_chart.dart';
import 'package:clarity_software/services/auth_service.dart';
import 'package:clarity_software/models/client_user.dart';
import 'package:clarity_software/services/feedback_notification_service.dart';
import 'package:clarity_software/models/feedback_message.dart';
import 'package:clarity_software/widgets/calendar_widget.dart';

Color getProjectColorByProgress(double progress) {
  if (progress == 0.0) return AppColors.accentMagenta;
  if (progress < 0.41) return AppColors.accentOrange;
  if (progress < 1.0) return AppColors.cyberBlue;
  return AppColors.accentGreen;
}

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen>
    with SingleTickerProviderStateMixin {
  final ProjectService _projectService = ProjectService();
  final ViewStatusService _viewStatusService = ViewStatusService();
  final AuthService _authService = AuthService();
  final FeedbackNotificationService _feedbackService =
      FeedbackNotificationService();
  final PreferenceService _preferenceService = PreferenceService();

  late AnimationController _blinkAnimationController;
  late Animation<double> _blinkAnimation;

  ClientUser? _currentUser;
  final PageController _pageController = PageController();
  int _currentChartPage = 0;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;

    _blinkAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _blinkAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(_blinkAnimationController);
    _blinkAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _blinkAnimationController.dispose();
    super.dispose();
  }

  void _openCustomizer(DashboardConfig currentConfig) async {
    final result = await showDialog<DashboardConfig>(
      context: context,
      builder: (context) =>
          DashboardCustomizerDialog(initialConfig: currentConfig),
    );

    if (result != null) {
      await _preferenceService.saveDashboardConfig(result);
    }
  }

  String _formatLastUpdate(DateTime lastUpdate) {
    final Duration difference = DateTime.now().difference(lastUpdate);
    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace un momento';
    }
  }

  Widget _buildDot(int index) {
    bool isActive = index == _currentChartPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.cyberBlue
            : AppColors.grey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  // --- WIDGETS MODULARES ---

  Widget _buildShortcutsModule() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              label: const Text('Agendar Cita'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentMagenta,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Futura expansión: Ver todos los archivos globales
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Accede a los archivos desde cada proyecto'),
                  ),
                );
              },
              icon: const Icon(Icons.folder_shared, color: AppColors.cyberBlue),
              label: const Text('Mis Archivos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cyberBlue,
                side: const BorderSide(color: AppColors.cyberBlue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsModule(List<Project> sortedProjects) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView(
            controller: _pageController,
            onPageChanged: (int page) =>
                setState(() => _currentChartPage = page),
            children: [
              PieChart(projects: sortedProjects, size: 220),
              BarChart(projects: sortedProjects, size: 220),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildDot(0), _buildDot(1)],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProjectsModule(
    List<Project> sortedProjects,
    bool showStats,
    int activeCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Proyectos Activos ($activeCount)',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 15),
        ...sortedProjects.map((project) {
          final projectColor = getProjectColorByProgress(
            project.overallProgress,
          );

          return StreamBuilder<List<FeedbackMessage>>(
            stream: _feedbackService.getUnreadFeedbackStream(project.id),
            builder: (context, feedbackSnapshot) {
              final unreadMessages = feedbackSnapshot.data ?? [];
              final int unreadCount = unreadMessages.length;
              final bool hasUnreadFeedback = unreadCount > 0;
              final bool hasUnreadView = !_viewStatusService.hasBeenViewed(
                project.id,
              );

              String subtitleText;
              Color subtitleColor = AppColors.secondaryText;
              String? highlightMilestoneTitle;

              if (hasUnreadFeedback) {
                subtitleText =
                    '$unreadCount novedad${unreadCount > 1 ? 'es' : ''} requiere${unreadCount > 1 ? 'n' : ''} atención';
                subtitleColor = projectColor;
                highlightMilestoneTitle = unreadMessages.first.milestoneTitle;
              } else if (project.status == 'Finalizado') {
                subtitleText = hasUnreadView
                    ? 'Hay novedades sin revisar'
                    : 'Finalizado con éxito';
                if (!hasUnreadView) {
                  subtitleColor = AppColors.statusFinishedText;
                }
              } else {
                subtitleText = hasUnreadView
                    ? 'Nuevo proyecto'
                    : _formatLastUpdate(project.lastUpdate);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailsScreen(
                          project: project,
                          highlightMilestoneTitle: highlightMilestoneTitle,
                        ),
                      ),
                    );
                    _viewStatusService.markAsViewed(project.id);
                  },
                  child: NeonCard(
                    glowColor: projectColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (hasUnreadFeedback)
                              FadeTransition(
                                opacity: _blinkAnimation,
                                child: Icon(
                                  Icons.notification_important,
                                  color: subtitleColor,
                                  size: 14,
                                ),
                              ),
                            if (hasUnreadFeedback) const SizedBox(width: 4),
                            Expanded(
                              child: hasUnreadFeedback
                                  ? FadeTransition(
                                      opacity: _blinkAnimation,
                                      child: Text(
                                        subtitleText,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: subtitleColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      subtitleText,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: subtitleColor),
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: LinearProgressIndicator(
                            value: project.overallProgress,
                            minHeight: 8,
                            backgroundColor: AppColors.black.withValues(
                              alpha: 0.5,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              projectColor,
                            ),
                          ),
                        ),
                        // --- STATS DENTRO DE LA TARJETA (CONDICIONAL) ---
                        if (showStats) ...[
                          const SizedBox(height: 15),
                          GridView(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 8.0,
                                  crossAxisSpacing: 8.0,
                                  childAspectRatio: 2.5,
                                ),
                            children: [
                              InfoBlock(
                                icon: Icons.flag_outlined,
                                label: 'ESTADO',
                                value: project.status,
                                glowColor: AppColors.neonYellow,
                              ),
                              InfoBlock(
                                icon: Icons.attach_money_outlined,
                                label: 'PRESUPUESTO',
                                value: '\$${project.budget}',
                                glowColor: AppColors.neonMoneyGreen,
                              ),
                              InfoBlock(
                                icon: Icons.people_outline,
                                label: 'EQUIPO',
                                value: '${project.team.length}',
                                glowColor: AppColors.neonPink,
                              ),
                              InfoBlock(
                                icon: Icons.code_outlined,
                                label: 'TECH',
                                value: '${project.technologies.length}',
                                glowColor: AppColors.cyberBlue,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double appBarHeight = 65.0;

    if (_currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<DashboardConfig>(
      stream: _preferenceService.getDashboardConfigStream(),
      builder: (context, configSnapshot) {
        final config = configSnapshot.data ?? DashboardConfig();

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(appBarHeight),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: theme.appBarTheme.backgroundColor,
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Align(
                          alignment: const Alignment(0.0, 0.2),
                          child: Text(
                            _currentUser?.name ?? 'Visión General',
                            style: theme.appBarTheme.titleTextStyle,
                          ),
                        ),
                        Align(
                          alignment: const Alignment(1.0, 0.2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.tune,
                                  color: Colors.white70,
                                ),
                                onPressed: () => _openCustomizer(config),
                              ),
                              const GlobalAppBarMenu(
                                currentScreen: AppScreen.overview,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: StreamBuilder<List<Project>>(
            stream: _projectService.getProjectsStream(
              _currentUser!.id,
              _currentUser!.role,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.cyberBlue),
                );
              }

              final projects = snapshot.data ?? [];
              final sortedProjects = List<Project>.from(projects);
              sortedProjects.sort(
                (a, b) => a.overallProgress.compareTo(b.overallProgress),
              );
              final activeCount = projects
                  .where((p) => p.status != 'Finalizado')
                  .length;

              // --- CONSTRUCCIÓN DINÁMICA DEL DASHBOARD ---
              // Iteramos sobre el orden definido en 'config.layout'
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  const SizedBox(height: appBarHeight + 20.0),

                  for (String moduleId in config.layout)
                    Builder(
                      builder: (context) {
                        switch (moduleId) {
                          case 'shortcuts':
                            if (config.showShortcuts) {
                              return _buildShortcutsModule();
                            }
                            return const SizedBox();
                          case 'calendar':
                            if (config.showCalendar) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: CalendarWidget(projects: sortedProjects),
                              );
                            }
                            return const SizedBox();
                          case 'charts':
                            if (config.showCharts && projects.isNotEmpty) {
                              return _buildChartsModule(sortedProjects);
                            }
                            return const SizedBox();
                          case 'stats':
                            // Nota: Stats se integra en 'projects' o se muestra globalmente.
                            // En esta versión simplificada, 'stats' controla la visibilidad
                            // de los detalles dentro de las tarjetas de proyecto.
                            return const SizedBox();
                          case 'projects':
                            if (config.showProjects) {
                              return _buildProjectsModule(
                                sortedProjects,
                                config.showStats,
                                activeCount,
                              );
                            }
                            return const SizedBox();
                          default:
                            return const SizedBox();
                        }
                      },
                    ),

                  const SizedBox(height: 30),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
