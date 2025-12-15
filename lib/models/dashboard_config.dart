// lib/models/dashboard_config.dart

class DashboardConfig {
  final bool showCharts;
  final bool showStats;
  final bool showProjects;
  final bool showCalendar;
  final bool showShortcuts; // Nuevo módulo de accesos rápidos

  // Lista ordenada de IDs de los módulos
  // IDs: 'shortcuts', 'charts', 'stats', 'calendar', 'projects'
  final List<String> layout;

  DashboardConfig({
    this.showCharts = true,
    this.showStats = true,
    this.showProjects = true,
    this.showCalendar = true,
    this.showShortcuts = true,
    List<String>? layout,
  }) : layout =
           layout ?? ['shortcuts', 'calendar', 'charts', 'stats', 'projects'];

  factory DashboardConfig.fromJson(Map<String, dynamic> json) {
    // Recuperamos la lista o usamos el orden por defecto si no existe
    List<String> loadedLayout = [];
    if (json['layout'] != null) {
      loadedLayout = List<String>.from(json['layout']);
    } else {
      loadedLayout = ['shortcuts', 'calendar', 'charts', 'stats', 'projects'];
    }

    return DashboardConfig(
      showCharts: json['showCharts'] ?? true,
      showStats: json['showStats'] ?? true,
      showProjects: json['showProjects'] ?? true,
      showCalendar: json['showCalendar'] ?? true,
      showShortcuts: json['showShortcuts'] ?? true,
      layout: loadedLayout,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showCharts': showCharts,
      'showStats': showStats,
      'showProjects': showProjects,
      'showCalendar': showCalendar,
      'showShortcuts': showShortcuts,
      'layout': layout,
    };
  }

  DashboardConfig copyWith({
    bool? showCharts,
    bool? showStats,
    bool? showProjects,
    bool? showCalendar,
    bool? showShortcuts,
    List<String>? layout,
  }) {
    return DashboardConfig(
      showCharts: showCharts ?? this.showCharts,
      showStats: showStats ?? this.showStats,
      showProjects: showProjects ?? this.showProjects,
      showCalendar: showCalendar ?? this.showCalendar,
      showShortcuts: showShortcuts ?? this.showShortcuts,
      layout: layout ?? this.layout,
    );
  }
}
