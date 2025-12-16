// lib/screens/client/overview_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/dashboard_config.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/client/booking_screen.dart';
import 'package:clarity_software/screens/client/notifications_screen.dart';
import 'package:clarity_software/screens/client/projects_dashboard_screen.dart';
import 'package:clarity_software/services/user_service.dart';
import 'package:clarity_software/widgets/dashboard_tile.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:clarity_software/services/project_service.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/latest_milestones_widget.dart';
import 'package:flutter/material.dart';
import 'package:clarity_software/services/auth_service.dart';
import 'package:clarity_software/models/client_user.dart';
import 'package:clarity_software/widgets/calendar_widget.dart';
import 'package:clarity_software/services/preference_service.dart';
import 'package:clarity_software/screens/shared/chat_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final ProjectService _projectService = ProjectService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final PreferenceService _preferenceService = PreferenceService();

  ClientUser? _currentUser;
  bool _isEditMode = false;

  final Set<String> _smallTiles = {
    'shortcuts',
    'tile_projects',
    'tile_notifs',
    'tile_chat',
    'tile_files',
  };

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
  }

  void _editName(ClientUser user) {
    final TextEditingController nameController = TextEditingController(
      text: user.name,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Editar Nombre',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nombre visible',
            labelStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white30),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.cyberBlue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await _userService.updateUserName(user.id, nameController.text);

                // CORRECCIÓN FINAL: Chequeo explícito de mounted
                if (!mounted) return;
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentMagenta,
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  DashboardConfig _toggleVisibility(
    DashboardConfig config,
    String id,
    bool val,
  ) {
    switch (id) {
      case 'calendar':
        return config.copyWith(showCalendar: val);
      case 'milestones':
        return config.copyWith(showMilestones: val);
      case 'shortcuts':
        return config.copyWith(showShortcuts: val);
      case 'tile_projects':
        return config.copyWith(showTileProjects: val);
      case 'tile_notifs':
        return config.copyWith(showTileNotifications: val);
      case 'tile_chat':
        return config.copyWith(showTileChat: val);
      case 'tile_files':
        return config.copyWith(showTileFiles: val);
      default:
        return config;
    }
  }

  Widget _getWidgetById(
    String id,
    DashboardConfig config,
    List<Project> projects,
    int activeCount,
  ) {
    if (!_isIdVisible(id, config) && !_isEditMode) {
      return const SizedBox.shrink();
    }

    switch (id) {
      case 'calendar':
        return CalendarWidget(projects: projects);
      case 'milestones':
        return LatestMilestonesWidget(projects: projects);
      case 'shortcuts':
        return _buildBookingShortcutTile(config);
      case 'tile_projects':
        return DashboardTile(
          title: 'Proyectos Activos',
          icon: Icons.bar_chart,
          color: AppColors.cyberBlue,
          badgeText: activeCount > 0 ? '$activeCount' : null,
          isEditMode: _isEditMode,
          isVisible: config.showTileProjects,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProjectsDashboardScreen(),
            ),
          ),
          onToggleVisibility: () => _toggleItem(id, config),
        );
      case 'tile_notifs':
        return DashboardTile(
          title: 'Notificaciones',
          icon: Icons.notifications_none,
          color: AppColors.accentMagenta,
          isEditMode: _isEditMode,
          isVisible: config.showTileNotifications,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          ),
          onToggleVisibility: () => _toggleItem(id, config),
        );
      case 'tile_chat':
        return DashboardTile(
          title: 'Mensajería',
          icon: Icons.chat_bubble_outline,
          color: AppColors.accentOrange,
          isEditMode: _isEditMode,
          isVisible: config.showTileChat,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatScreen(),
              ),
            );
          },
          onToggleVisibility: () => _toggleItem(id, config),
        );
      case 'tile_files':
        return DashboardTile(
          title: 'Mis Archivos',
          icon: Icons.folder_open,
          color: AppColors.accentGreen,
          isEditMode: _isEditMode,
          isVisible: config.showTileFiles,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProjectsDashboardScreen(),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selecciona un proyecto para ver sus archivos'),
              ),
            );
          },
          onToggleVisibility: () => _toggleItem(id, config),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBookingShortcutTile(DashboardConfig config) {
    return DashboardTile(
      title: 'Agendar Cita',
      icon: Icons.calendar_month,
      color: AppColors.accentMagenta,
      isEditMode: _isEditMode,
      isVisible: config.showShortcuts,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BookingScreen()),
      ),
      onToggleVisibility: () => _toggleItem('shortcuts', config),
    );
  }

  bool _isIdVisible(String id, DashboardConfig config) {
    switch (id) {
      case 'calendar':
        return config.showCalendar;
      case 'milestones':
        return config.showMilestones;
      case 'shortcuts':
        return config.showShortcuts;
      case 'tile_projects':
        return config.showTileProjects;
      case 'tile_notifs':
        return config.showTileNotifications;
      case 'tile_chat':
        return config.showTileChat;
      case 'tile_files':
        return config.showTileFiles;
      default:
        return true;
    }
  }

  void _toggleItem(String id, DashboardConfig config) {
    final newVal = !_isIdVisible(id, config);
    final newConfig = _toggleVisibility(config, id, newVal);
    _preferenceService.saveDashboardConfig(newConfig);
  }

  List<Widget> _buildViewLayout(
    List<String> layout,
    DashboardConfig config,
    List<Project> projects,
    int activeCount,
  ) {
    List<Widget> widgets = [];
    int i = 0;
    while (i < layout.length) {
      String currentId = layout[i];

      if (!_isIdVisible(currentId, config)) {
        i++;
        continue;
      }

      bool isSmall = _smallTiles.contains(currentId);

      if (isSmall) {
        String? nextId;
        int nextIndex = i + 1;
        while (nextIndex < layout.length) {
          if (_isIdVisible(layout[nextIndex], config)) {
            nextId = layout[nextIndex];
            break;
          }
          nextIndex++;
        }

        if (nextId != null && _smallTiles.contains(nextId)) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _getWidgetById(
                        currentId,
                        config,
                        projects,
                        activeCount,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _getWidgetById(
                        nextId,
                        config,
                        projects,
                        activeCount,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          i = nextIndex + 1;
        } else {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _getWidgetById(
                        currentId,
                        config,
                        projects,
                        activeCount,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(child: SizedBox()), // Espacio vacío
                ],
              ),
            ),
          );
          i++;
        }
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _getWidgetById(currentId, config, projects, activeCount),
          ),
        );
        i++;
      }
    }
    return widgets;
  }

  Widget _buildEditableWrapper({
    required Widget child,
    required String id,
    required bool isVisible,
    required DashboardConfig config,
    required ValueKey<String> key,
  }) {
    if (!_isEditMode && !isVisible) {
      return SizedBox(key: ValueKey(id), height: 0);
    }

    return Padding(
      key: ValueKey(id),
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Opacity(
            opacity: (_isEditMode && !isVisible) ? 0.4 : 1.0,
            child: child,
          ),
          if (_isEditMode)
            Positioned(
              top: -8,
              left: -8,
              child: GestureDetector(
                onTap: () => _toggleItem(id, config),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color:
                        isVisible ? AppColors.accentRed : AppColors.accentGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    isVisible ? Icons.remove : Icons.add,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double appBarHeight = 70.0;
    final double topPadding =
        MediaQuery.of(context).padding.top + appBarHeight + 20;

    if (_currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<DashboardConfig>(
      stream: _preferenceService.getDashboardConfigStream(),
      builder: (context, configSnapshot) {
        final config = configSnapshot.data ?? DashboardConfig();

        // Limpieza de duplicados
        final uniqueLayout = config.layout.toSet().toList();
        final layout = List<String>.from(uniqueLayout);

        if (!layout.contains('shortcuts')) {
          layout.add('shortcuts');
        }
        if (!layout.contains('tile_projects')) {
          layout.add('tile_projects');
        }
        if (!layout.contains('tile_notifs')) {
          layout.add('tile_notifs');
        }
        if (!layout.contains('tile_chat')) {
          layout.add('tile_chat');
        }
        if (!layout.contains('tile_files')) {
          layout.add('tile_files');
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
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: StreamBuilder<ClientUser?>(
                            stream: _userService.getUserStream(
                              _currentUser!.id,
                            ),
                            builder: (context, snapshot) {
                              final user = snapshot.data ?? _currentUser!;
                              return GestureDetector(
                                onTap: () => _editName(user),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hola,',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            user.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.edit,
                                          size: 14,
                                          color: Colors.white30,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isEditMode ? Icons.check_circle : Icons.tune,
                                color: _isEditMode
                                    ? AppColors.accentGreen
                                    : Colors.white,
                              ),
                              onPressed: () {
                                setState(() => _isEditMode = !_isEditMode);
                                if (!_isEditMode) {
                                  _preferenceService.saveDashboardConfig(
                                    config.copyWith(layout: layout),
                                  );
                                }
                              },
                            ),
                            if (!_isEditMode)
                              const GlobalAppBarMenu(
                                currentScreen: AppScreen.overview,
                              ),
                          ],
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
              final projects = snapshot.data ?? [];
              final activeCount =
                  projects.where((p) => p.status != 'Finalizado').length;

              if (_isEditMode) {
                return ReorderableListView(
                  padding: EdgeInsets.fromLTRB(16.0, topPadding, 16.0, 30.0),
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = layout.removeAt(oldIndex);
                    layout.insert(newIndex, item);
                    _preferenceService.saveDashboardConfig(
                      config.copyWith(layout: layout),
                    );
                  },
                  proxyDecorator: (child, index, animation) =>
                      Material(color: Colors.transparent, child: child),
                  children: [
                    for (final id in layout)
                      _buildEditableWrapper(
                        key: ValueKey(id),
                        id: id,
                        isVisible: _isIdVisible(id, config),
                        config: config,
                        child: _getWidgetById(
                          id,
                          config,
                          projects,
                          activeCount,
                        ),
                      ),
                  ],
                );
              } else {
                return ListView(
                  padding: EdgeInsets.fromLTRB(16.0, topPadding, 16.0, 30.0),
                  children: _buildViewLayout(
                    layout,
                    config,
                    projects,
                    activeCount,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
