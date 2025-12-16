// lib/models/dashboard_config.dart

class DashboardConfig {
  // Estados de visibilidad
  final bool showCalendar;
  final bool showMilestones;
  final bool showShortcuts; // Botones de Agendar/Archivos
  final bool showTileProjects;
  final bool showTileNotifications;
  final bool showTileChat;
  final bool showTileFiles;

  // Lista ordenada de IDs
  final List<String> layout;

  DashboardConfig({
    this.showCalendar = true,
    this.showMilestones = true,
    this.showShortcuts = true,
    this.showTileProjects = true,
    this.showTileNotifications = true,
    this.showTileChat = true,
    this.showTileFiles = true,
    List<String>? layout,
  }) : layout =
           layout ??
           [
             'shortcuts',
             'calendar',
             'milestones',
             'tile_projects',
             'tile_notifs',
             'tile_chat',
             'tile_files',
           ];

  factory DashboardConfig.fromJson(Map<String, dynamic> json) {
    return DashboardConfig(
      showCalendar: json['showCalendar'] ?? true,
      showMilestones: json['showMilestones'] ?? true,
      showShortcuts: json['showShortcuts'] ?? true,
      showTileProjects: json['showTileProjects'] ?? true,
      showTileNotifications: json['showTileNotifications'] ?? true,
      showTileChat: json['showTileChat'] ?? true,
      showTileFiles: json['showTileFiles'] ?? true,
      layout: json['layout'] != null
          ? List<String>.from(json['layout'])
          : [
              'shortcuts',
              'calendar',
              'milestones',
              'tile_projects',
              'tile_notifs',
              'tile_chat',
              'tile_files',
            ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showCalendar': showCalendar,
      'showMilestones': showMilestones,
      'showShortcuts': showShortcuts,
      'showTileProjects': showTileProjects,
      'showTileNotifications': showTileNotifications,
      'showTileChat': showTileChat,
      'showTileFiles': showTileFiles,
      'layout': layout,
    };
  }

  // Método copyWith para actualizaciones inmutables
  DashboardConfig copyWith({
    bool? showCalendar,
    bool? showMilestones,
    bool? showShortcuts,
    bool? showTileProjects,
    bool? showTileNotifications,
    bool? showTileChat,
    bool? showTileFiles,
    List<String>? layout,
  }) {
    return DashboardConfig(
      showCalendar: showCalendar ?? this.showCalendar,
      showMilestones: showMilestones ?? this.showMilestones,
      showShortcuts: showShortcuts ?? this.showShortcuts,
      showTileProjects: showTileProjects ?? this.showTileProjects,
      showTileNotifications:
          showTileNotifications ?? this.showTileNotifications,
      showTileChat: showTileChat ?? this.showTileChat,
      showTileFiles: showTileFiles ?? this.showTileFiles,
      layout: layout ?? this.layout,
    );
  }
}
