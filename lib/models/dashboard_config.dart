// lib/models/dashboard_config.dart

class DashboardConfig {
  final bool showCharts;
  final bool showStats; // Los InfoBlocks (Presupuesto, Estado, etc.)
  final bool showProjects;
  final bool showCalendar; // Preparando para la integración futura

  DashboardConfig({
    this.showCharts = true,
    this.showStats = true,
    this.showProjects = true,
    this.showCalendar = false,
  });

  factory DashboardConfig.fromJson(Map<String, dynamic> json) {
    return DashboardConfig(
      showCharts: json['showCharts'] ?? true,
      showStats: json['showStats'] ?? true,
      showProjects: json['showProjects'] ?? true,
      showCalendar: json['showCalendar'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showCharts': showCharts,
      'showStats': showStats,
      'showProjects': showProjects,
      'showCalendar': showCalendar,
    };
  }

  // Helper para crear una copia modificada
  DashboardConfig copyWith({
    bool? showCharts,
    bool? showStats,
    bool? showProjects,
    bool? showCalendar,
  }) {
    return DashboardConfig(
      showCharts: showCharts ?? this.showCharts,
      showStats: showStats ?? this.showStats,
      showProjects: showProjects ?? this.showProjects,
      showCalendar: showCalendar ?? this.showCalendar,
    );
  }
}
