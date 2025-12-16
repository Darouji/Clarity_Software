// lib/screens/client/projects_dashboard_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/client/project_details_screen.dart';
import 'package:clarity_software/services/auth_service.dart';
import 'package:clarity_software/services/feedback_notification_service.dart';
import 'package:clarity_software/models/feedback_message.dart';
import 'package:clarity_software/services/project_service.dart';
import 'package:clarity_software/services/view_status_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/bar_chart.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:clarity_software/widgets/info_block.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:clarity_software/widgets/pie_chart.dart';
import 'package:flutter/material.dart';

Color getProjectColorByProgress(double progress) {
  if (progress == 0.0) return AppColors.accentMagenta;
  if (progress < 0.41) return AppColors.accentOrange;
  if (progress < 1.0) return AppColors.cyberBlue;
  return AppColors.accentGreen;
}

class ProjectsDashboardScreen extends StatefulWidget {
  const ProjectsDashboardScreen({super.key});

  @override
  State<ProjectsDashboardScreen> createState() =>
      _ProjectsDashboardScreenState();
}

class _ProjectsDashboardScreenState extends State<ProjectsDashboardScreen> {
  final ProjectService _projectService = ProjectService();
  final ViewStatusService _viewStatusService = ViewStatusService();
  final AuthService _authService = AuthService();
  final FeedbackNotificationService _feedbackService =
      FeedbackNotificationService();

  final PageController _pageController = PageController();
  int _currentChartPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authService.currentUser;
    const double appBarHeight = 65.0;
    // Padding superior dinámico para evitar que el banner tape el contenido
    final double topContentPadding =
        MediaQuery.of(context).padding.top + appBarHeight + 20;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                      alignment: const Alignment(-1.0, 0.2),
                      child: BackButton(color: theme.iconTheme.color),
                    ),
                    const Align(
                      alignment: Alignment(0.0, 0.2),
                      child: Text(
                        'Mis Proyectos', // CAMBIO DE NOMBRE
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment(1.0, 0.2),
                      child: GlobalAppBarMenu(
                        currentScreen: AppScreen.overview,
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
        stream: _projectService.getProjectsStream(user.id, user.role),
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

          if (projects.isEmpty) {
            return const Center(
              child: Text(
                'No tienes proyectos asignados.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(16, topContentPadding, 16, 20),
            children: [
              // --- MÓDULO DE GRÁFICOS ---
              SizedBox(
                height: 220,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) =>
                      setState(() => _currentChartPage = page),
                  children: [
                    PieChart(projects: sortedProjects, size: 220),
                    // Aseguramos que el segundo hijo sea BarChart
                    BarChart(projects: sortedProjects, size: 220),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_buildDot(0), _buildDot(1)],
              ),
              const SizedBox(height: 30),

              // --- LISTA DE PROYECTOS ---
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
                    final bool hasUnreadView = !_viewStatusService
                        .hasBeenViewed(project.id);

                    String subtitleText;
                    Color subtitleColor = AppColors.secondaryText;
                    String? highlightMilestoneTitle;

                    if (hasUnreadFeedback) {
                      subtitleText =
                          '$unreadCount novedad${unreadCount > 1 ? 'es' : ''}';
                      subtitleColor = projectColor;
                      highlightMilestoneTitle =
                          unreadMessages.first.milestoneTitle;
                    } else if (project.status == 'Finalizado') {
                      subtitleText = hasUnreadView
                          ? 'Revisión final pendiente'
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
                                highlightMilestoneTitle:
                                    highlightMilestoneTitle,
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
                                    Icon(
                                      Icons.notification_important,
                                      color: subtitleColor,
                                      size: 14,
                                    ),
                                  if (hasUnreadFeedback)
                                    const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      subtitleText,
                                      style: TextStyle(
                                        color: subtitleColor,
                                        fontWeight:
                                            hasUnreadFeedback || hasUnreadView
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 12,
                                      ),
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
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
