import 'dart:ui';
import 'package:clarity_software/models/dashboard_config.dart';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/screens/client/booking_screen.dart';
import 'package:clarity_software/screens/client/notifications_screen.dart';
import 'package:clarity_software/screens/client/projects_dashboard_screen.dart';
import 'package:clarity_software/screens/shared/signature_screen.dart';
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

  DashboardConfig? _localConfig;
  List<String>? _localLayout;

  final Set<String> _smallTiles = {
    'shortcuts',
    'tile_projects',
    'tile_notifs',
    'tile_chat',
    'tile_files',
    'tile_signature',
    'empty',
  };

  // CORRECCIÓN: 'empty' agregado aquí para que no se borre al limpiar layout
  final Set<String> _validIds = {
    'calendar',
    'milestones',
    'shortcuts',
    'tile_projects',
    'tile_notifs',
    'tile_chat',
    'tile_files',
    'tile_signature',
    'empty',
  };

  final double _largeBlockHeight = 240.0;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
  }

  // --- LÓGICA DE DATOS ---

  List<String> _cleanLayout(List<String> rawLayout) {
    final uniqueLayout = rawLayout.toSet().toList();
    // Filtramos solo IDs válidos
    final validLayout =
        uniqueLayout.where((id) => _validIds.contains(id)).toList();

    // Agregamos los que falten (excepto 'empty', ese se agrega dinámicamente si falta)
    for (var id in _validIds) {
      if (id != 'empty' && !validLayout.contains(id)) {
        validLayout.add(id);
      }
    }
    return validLayout;
  }

  List<String> _prepareLayout(List<String> rawLayout) {
    // 1. Limpiamos basura
    final List<String> cleanList = _cleanLayout(rawLayout);

    // 2. Normalizamos para asegurar pares
    final List<String> normalizedList = [];
    int i = 0;
    while (i < cleanList.length) {
      String current = cleanList[i];
      bool isSmall = _smallTiles.contains(current);

      if (!isSmall) {
        normalizedList.add(current);
        i++;
      } else {
        normalizedList.add(current);
        if (i + 1 < cleanList.length) {
          String next = cleanList[i + 1];
          if (_smallTiles.contains(next)) {
            normalizedList.add(next);
            i += 2;
          } else {
            // Si el siguiente es grande, rellenamos con empty
            normalizedList.add('empty');
            i += 1;
          }
        } else {
          // Si es el último, rellenamos
          normalizedList.add('empty');
          i += 1;
        }
      }
    }
    return normalizedList;
  }

  void _enterEditMode(DashboardConfig currentConfig) {
    setState(() {
      _localConfig = currentConfig;
      _localLayout = _prepareLayout(List<String>.from(currentConfig.layout));
      _isEditMode = true;
    });
  }

  void _exitEditMode(bool save) async {
    if (save && _localConfig != null && _localLayout != null) {
      final finalConfig = _localConfig!.copyWith(layout: _localLayout);
      await _preferenceService.saveDashboardConfig(finalConfig);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Diseño guardado'),
            backgroundColor: AppColors.cyberBlue,
            duration: Duration(seconds: 1)));
      }
    }
    setState(() {
      _isEditMode = false;
      _localConfig = null;
      _localLayout = null;
    });
  }

  void _moveItem(String draggedId, String targetId) {
    if (draggedId == targetId) return;
    setState(() {
      final int oldIndex = _localLayout!.indexOf(draggedId);
      final int newIndex = _localLayout!.indexOf(targetId);
      // Intercambio simple para mantener estructura
      final temp = _localLayout![oldIndex];
      _localLayout![oldIndex] = _localLayout![newIndex];
      _localLayout![newIndex] = temp;
    });
  }

  void _toggleVisibilityLocal(String id) {
    if (_localConfig == null) return;
    bool currentVal = _isIdVisible(id, _localConfig!);
    DashboardConfig newConfig =
        _toggleConfigVisibility(_localConfig!, id, !currentVal);
    setState(() => _localConfig = newConfig);
  }

  DashboardConfig _toggleConfigVisibility(
      DashboardConfig config, String id, bool val) {
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
      case 'tile_signature':
        return true;
      case 'empty':
        return true;
      default:
        return true;
    }
  }

  void _editName(ClientUser user) {
    final TextEditingController nameController =
        TextEditingController(text: user.name);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title:
            const Text('Editar Nombre', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
              labelText: 'Nombre visible',
              labelStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.cyberBlue))),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  await _userService.updateUserName(
                      user.id, nameController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentMagenta),
              child:
                  const Text('Guardar', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _getWidgetById(String id, DashboardConfig config,
      List<Project> projects, int activeCount) {
    if (id == 'empty') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: _isEditMode
              ? Border.all(
                  color: Colors.white10, width: 2, style: BorderStyle.solid)
              : null,
        ),
        child: _isEditMode
            ? const Center(child: Icon(Icons.add, color: Colors.white10))
            : null,
      );
    }

    final bool isVisible = _isIdVisible(id, config);
    if (!_isEditMode && !isVisible) return const SizedBox.shrink();

    Widget content;
    switch (id) {
      case 'calendar':
        content = CalendarWidget(projects: projects);
        break;
      case 'milestones':
        content = LatestMilestonesWidget(projects: projects);
        break;
      case 'shortcuts':
        content = DashboardTile(
          title: 'Agendar Cita',
          icon: Icons.calendar_month,
          color: AppColors.accentMagenta,
          isVisible: isVisible,
          onTap: () {
            if (!_isEditMode && _currentUser != null)
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BookingScreen(userId: _currentUser!.id)));
          },
        );
        break;
      case 'tile_projects':
        content = DashboardTile(
          title: 'Proyectos',
          icon: Icons.bar_chart,
          color: AppColors.cyberBlue,
          badgeText: activeCount > 0 ? '$activeCount' : null,
          isVisible: isVisible,
          onTap: () => !_isEditMode
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProjectsDashboardScreen()))
              : null,
        );
        break;
      case 'tile_notifs':
        content = DashboardTile(
          title: 'Notificaciones',
          icon: Icons.notifications_none,
          color: AppColors.accentMagenta,
          isVisible: isVisible,
          onTap: () => !_isEditMode
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsScreen()))
              : null,
        );
        break;
      case 'tile_chat':
        content = DashboardTile(
          title: 'Mensajería',
          icon: Icons.chat_bubble_outline,
          color: AppColors.accentOrange,
          isVisible: isVisible,
          onTap: () {
            if (!_isEditMode && _currentUser != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(
                          clientId: _currentUser!.id, title: "Chat")));
            }
          },
        );
        break;
      case 'tile_files':
        content = DashboardTile(
          title: 'Mis Archivos',
          icon: Icons.folder_open,
          color: AppColors.accentGreen,
          isVisible: isVisible,
          onTap: () {
            if (!_isEditMode) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProjectsDashboardScreen()));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('Selecciona un proyecto para ver sus archivos')));
            }
          },
        );
        break;
      case 'tile_signature':
        content = DashboardTile(
          title: 'Firma Digital',
          icon: Icons.draw,
          color: AppColors.cyberBlue,
          isVisible: isVisible,
          onTap: () {
            if (!_isEditMode)
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignatureScreen()));
          },
        );
        break;
      default:
        content = const SizedBox.shrink();
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 90;
    final screenWidth = MediaQuery.of(context).size.width;
    final double tileSpacing = 16.0;
    final double paddingH = 16.0;
    final double smallTileWidth =
        (screenWidth - (paddingH * 2) - tileSpacing) / 2;
    final double bigTileWidth = screenWidth - (paddingH * 2);

    if (_currentUser == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return StreamBuilder<DashboardConfig>(
      stream: _preferenceService.getDashboardConfigStream(),
      builder: (context, configSnapshot) {
        final DashboardConfig config = _isEditMode
            ? (_localConfig ?? DashboardConfig())
            : (configSnapshot.data ?? DashboardConfig());
        final List<String> layout = _isEditMode
            ? (_localLayout ?? [])
            : _prepareLayout(List<String>.from(config.layout));

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: ClipRRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(color: Colors.black.withOpacity(0.3)))),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: StreamBuilder<ClientUser?>(
                    stream: _userService.getUserStream(_currentUser!.id),
                    builder: (context, snapshot) {
                      final user = snapshot.data ?? _currentUser!;
                      return GestureDetector(
                        onTap: () => _editName(user),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hola,',
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.6),
                                      fontSize: 14)),
                              Row(children: [
                                Flexible(
                                    child: Text(user.name,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 6),
                                const Icon(Icons.edit,
                                    size: 14, color: Colors.white30)
                              ])
                            ]),
                      );
                    },
                  ),
                ),
                IconButton(
                    icon: Icon(_isEditMode ? Icons.check_circle : Icons.tune,
                        color:
                            _isEditMode ? AppColors.accentGreen : Colors.white,
                        size: 28),
                    onPressed: () {
                      if (_isEditMode) {
                        _exitEditMode(true);
                      } else {
                        _enterEditMode(config);
                      }
                    }),
                if (!_isEditMode)
                  const GlobalAppBarMenu(currentScreen: AppScreen.overview),
              ],
            ),
          ),
          body: StreamBuilder<List<Project>>(
            stream: _projectService.getProjectsStream(
                _currentUser!.id, _currentUser!.role),
            builder: (context, snapshot) {
              final projects = snapshot.data ?? [];
              final activeCount =
                  projects.where((p) => p.status != 'Finalizado').length;

              List<Widget> finalRows = [];
              int k = 0;
              while (k < layout.length) {
                String id1 = layout[k];
                bool isSmall = _smallTiles.contains(id1);

                if (!isSmall) {
                  // GRANDE
                  Widget content =
                      _getWidgetById(id1, config, projects, activeCount);
                  Widget wrapper = SizedBox(
                      width: bigTileWidth,
                      height: _largeBlockHeight,
                      child: content);
                  if (_isEditMode) {
                    finalRows.add(Padding(
                        padding: EdgeInsets.only(bottom: tileSpacing),
                        child: _DraggableTileWrapper(
                            id: id1,
                            width: bigTileWidth,
                            height: _largeBlockHeight,
                            isSmall: false,
                            isVisible: _isIdVisible(id1, config),
                            onToggle: () => _toggleVisibilityLocal(id1),
                            onDropAccept: (draggedId) =>
                                _moveItem(draggedId, id1),
                            child: wrapper)));
                  } else {
                    if (_isIdVisible(id1, config))
                      finalRows.add(Padding(
                          padding: EdgeInsets.only(bottom: tileSpacing),
                          child: wrapper));
                  }
                  k++;
                } else {
                  // PEQUEÑO (PAR)
                  if (k + 1 >= layout.length) break;
                  String id2 = layout[k + 1];
                  Widget w1 = SizedBox(
                      width: smallTileWidth,
                      height: smallTileWidth,
                      child:
                          _getWidgetById(id1, config, projects, activeCount));
                  Widget w2 = SizedBox(
                      width: smallTileWidth,
                      height: smallTileWidth,
                      child:
                          _getWidgetById(id2, config, projects, activeCount));

                  Widget slot1 = _isEditMode
                      ? _DraggableTileWrapper(
                          id: id1,
                          width: smallTileWidth,
                          height: smallTileWidth,
                          isSmall: true,
                          isVisible: _isIdVisible(id1, config),
                          onToggle: () => _toggleVisibilityLocal(id1),
                          onDropAccept: (d) => _moveItem(d, id1),
                          child: w1)
                      : w1;
                  Widget slot2 = _isEditMode
                      ? _DraggableTileWrapper(
                          id: id2,
                          width: smallTileWidth,
                          height: smallTileWidth,
                          isSmall: true,
                          isVisible: _isIdVisible(id2, config),
                          onToggle: () => _toggleVisibilityLocal(id2),
                          onDropAccept: (d) => _moveItem(d, id2),
                          child: w2)
                      : w2;

                  bool showRow = _isEditMode ||
                      _isIdVisible(id1, config) ||
                      _isIdVisible(id2, config);
                  // En modo lectura, mantenemos el SizedBox para alinear correctamente aunque uno esté oculto/vacío
                  if (!_isEditMode) {
                    if (!_isIdVisible(id1, config) || id1 == 'empty')
                      slot1 = SizedBox(
                          width: smallTileWidth, height: smallTileWidth);
                    if (!_isIdVisible(id2, config) || id2 == 'empty')
                      slot2 = SizedBox(
                          width: smallTileWidth, height: smallTileWidth);
                    if ((!_isIdVisible(id1, config) &&
                            !_isIdVisible(id2, config)) ||
                        (id1 == 'empty' && id2 == 'empty')) showRow = false;
                  }

                  if (showRow)
                    finalRows.add(Padding(
                        padding: EdgeInsets.only(bottom: tileSpacing),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [slot1, slot2])));
                  k += 2;
                }
              }
              return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.0, topPadding, 16.0, 100.0),
                  child: Column(children: finalRows));
            },
          ),
        );
      },
    );
  }
}

class _DraggableTileWrapper extends StatelessWidget {
  final String id;
  final Widget child;
  final double width;
  final double height;
  final bool isSmall;
  final bool isVisible;
  final VoidCallback onToggle;
  final Function(String) onDropAccept;

  static const Set<String> _validSmallTiles = {
    'shortcuts',
    'tile_projects',
    'tile_notifs',
    'tile_chat',
    'tile_files',
    'tile_signature',
    'empty'
  };

  const _DraggableTileWrapper(
      {required this.id,
      required this.child,
      required this.width,
      required this.height,
      required this.isSmall,
      required this.isVisible,
      required this.onToggle,
      required this.onDropAccept});

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAccept: (draggedId) {
        if (draggedId == null || draggedId == id) return false;
        // Prevenir que bloques grandes entren en espacios pequeños
        if (isSmall && !_validSmallTiles.contains(draggedId)) return false;
        return true;
      },
      onAccept: onDropAccept,
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return LongPressDraggable<String>(
          data: id,
          delay: const Duration(milliseconds: 200),
          feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                  width: width,
                  height: height,
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 15,
                                spreadRadius: 2)
                          ]),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Opacity(opacity: 0.9, child: child))))),
          childWhenDragging: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10))),
          child: Stack(clipBehavior: Clip.none, children: [
            Opacity(
                opacity: (isVisible || id == 'empty')
                    ? (isHovering ? 0.5 : 1.0)
                    : 0.4,
                child: Container(
                    width: width,
                    height: height,
                    decoration: isHovering
                        ? BoxDecoration(
                            border: Border.all(
                                color: AppColors.cyberBlue, width: 2),
                            borderRadius: BorderRadius.circular(16))
                        : null,
                    child: child)),
            if (id != 'empty') ...[
              Positioned(
                  top: -8,
                  left: -8,
                  child: GestureDetector(
                      onTap: onToggle,
                      child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                              color: isVisible
                                  ? AppColors.accentRed
                                  : AppColors.accentGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 4)
                              ]),
                          child: Icon(isVisible ? Icons.remove : Icons.add,
                              size: 20, color: Colors.white)))),
              Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white54, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 4)
                          ]),
                      child: const Icon(Icons.drag_handle,
                          size: 18, color: Colors.white)))
            ]
          ]),
        );
      },
    );
  }
}
