// lib/screens/client/overview_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/client/project_details_screen.dart';
import 'package:clarity_software/widgets/global_menu.dart';
// --- CAMBIO: Usamos el servicio real, no el Mock ---
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
  // --- SERVICIOS REALES ---
  final ProjectService _projectService =
      ProjectService(); // <-- Conexión a Firebase
  final ViewStatusService _viewStatusService = ViewStatusService();
  final AuthService _authService = AuthService();
  final FeedbackNotificationService _feedbackService =
      FeedbackNotificationService();

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    const double appBarHeight = 65.0;

    // Si no hay usuario logueado, mostramos error o login
    if (_currentUser == null) {
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
                      alignment: const Alignment(0.0, 0.2),
                      child: Text(
                        _currentUser?.name ?? 'Visión General',
                        style: theme.appBarTheme.titleTextStyle,
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
      // --- STREAM BUILDER: ESCUCHA A FIREBASE EN TIEMPO REAL ---
      body: StreamBuilder<List<Project>>(
        stream: _projectService.getProjectsStream(
          _currentUser!.id,
          _currentUser!.role,
        ),
        builder: (context, snapshot) {
          // 1. Cargando...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyberBlue),
            );
          }

          // 2. Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar proyectos:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          // 3. Datos Vacíos
          final projects = snapshot.data ?? [];
          if (projects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.folder_open,
                      size: 60,
                      color: AppColors.grey,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No tienes proyectos activos.',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tus proyectos aparecerán aquí automáticamente.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 4. Datos Listos -> Mostrar UI
          final int activeProjectsCount = projects
              .where((p) => p.status != 'Finalizado')
              .length;
          final List<Project> sortedProjects = List.from(projects);
          sortedProjects.sort(
            (a, b) => a.overallProgress.compareTo(b.overallProgress),
          );

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              const SizedBox(height: appBarHeight + 20.0),

              // --- SECCIÓN DE GRÁFICOS ---
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
              Text(
                'Proyectos Activos ($activeProjectsCount)',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // --- LISTA DE TARJETAS DE PROYECTO ---
              ...sortedProjects.map((project) {
                // Lógica de notificaciones y colores
                final List<FeedbackMessage> unreadMessages = _feedbackService
                    .getUnreadFeedbackForProject(project.id);
                final int unreadCount = unreadMessages.length;
                final bool hasUnreadFeedback = unreadCount > 0;
                final bool hasUnreadView = !_viewStatusService.hasBeenViewed(
                  project.id,
                );

                String subtitleText;
                Color subtitleColor = AppColors.secondaryText;
                String? highlightMilestoneTitle;
                final projectColor = getProjectColorByProgress(
                  project.overallProgress,
                );

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
                  padding: const EdgeInsets.only(bottom: 30.0),
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
                      // Al volver, marcamos como visto
                      _viewStatusService.markAsViewed(project.id);
                      // No necesitamos _loadProjects() porque el Stream lo hace solo
                      setState(() {});
                    },
                    child: NeonCard(
                      glowColor: projectColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título
                          Text(
                            project.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Subtítulo con notificación
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
                                          style: textTheme.bodySmall?.copyWith(
                                            color: subtitleColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        subtitleText,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: subtitleColor,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Barra de Progreso
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
                          // Bloques de Info
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
              }),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}
