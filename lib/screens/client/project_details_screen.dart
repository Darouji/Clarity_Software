// lib/screens/client/project_details_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/info_block.dart';
import 'package:clarity_software/widgets/kanban_board.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';
import 'package:clarity_software/widgets/global_menu.dart';
// --- INICIO DE CAMBIOS ---
// Importamos el modelo de Hito para buscar la fase
import 'package:clarity_software/models/milestone.dart';
// --- FIN DE CAMBIOS ---

class ProjectDetailsScreen extends StatefulWidget {
  // --- INICIO DE CAMBIOS ---
  // Añadimos el nuevo parámetro
  final String? highlightMilestoneTitle;
  // --- FIN DE CAMBIOS ---
  const ProjectDetailsScreen({
    super.key,
    required this.project,
    this.highlightMilestoneTitle, // <--
  });
  final Project project;

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late PageController _titlePageController;
  late PageController _boardPageController;
  // --- INICIO DE CAMBIOS ---
  // Controllers para el auto-scroll
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _kanbanKey = GlobalKey();
  // --- FIN DE CAMBIOS ---

  static const int _kanbanInitialPage = 5000;
  int _currentPageIndex = 0;

  final List<String> _columnTitles = [
    KanbanBoard.fase1,
    KanbanBoard.fase2,
    KanbanBoard.fase3,
    KanbanBoard.fase4,
  ];

  @override
  void initState() {
    super.initState();

    _titlePageController = PageController(
      initialPage: _kanbanInitialPage,
      viewportFraction: 0.35,
    );
    _boardPageController = PageController(initialPage: _kanbanInitialPage);

    _currentPageIndex = _kanbanInitialPage % _columnTitles.length; // = 0

    _boardPageController.addListener(() {
      if (_titlePageController.page != _boardPageController.page) {
        _titlePageController.jumpToPage(_boardPageController.page!.round());
      }
    });

    _titlePageController.addListener(() {
      if (_boardPageController.page != _titlePageController.page) {
        _boardPageController.jumpToPage(_titlePageController.page!.round());
      }
    });

    // --- INICIO DE CAMBIOS ---
    // Registramos la función de "highlight" para que se ejecute
    // después de que la pantalla se haya construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleHighlight();
    });
    // --- FIN DE CAMBIOS ---
  }

  @override
  void dispose() {
    _titlePageController.dispose();
    _boardPageController.dispose();
    _scrollController.dispose(); // <-- Dispose
    super.dispose();
  }

  // --- INICIO DE NUEVO MÉTODO ---
  void _handleHighlight() {
    if (widget.highlightMilestoneTitle == null) return;

    try {
      // 1. Encontrar el hito y su fase
      final milestoneToFind = widget.project.milestones.firstWhere(
        (m) => m.title == widget.highlightMilestoneTitle,
      );
      final faseName = getFaseName(milestoneToFind.fase);

      // 2. Encontrar el índice de la página (columna)
      int targetRealIndex = _columnTitles.indexOf(faseName);
      if (targetRealIndex == -1) return; // No se encontró la fase

      // 3. Animar el PageView (Kanban) a esa fase
      _scrollToPage(targetRealIndex);

      // 4. Animar el ListView (pantalla) hasta el tablero Kanban
      final kanbanContext = _kanbanKey.currentContext;
      if (kanbanContext != null) {
        Scrollable.ensureVisible(
          kanbanContext,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      // No hacer nada si el hito no se encuentra (raro, pero seguro)
    }
  }
  // --- FIN DE NUEVO MÉTODO ---

  void _scrollToPage(int pageIndex) {
    // Calculamos la página "infinita" más cercana
    final int currentPage = _boardPageController.page!.round();
    final int currentRealIndex = currentPage % _columnTitles.length;
    final int targetRealIndex = pageIndex % _columnTitles.length;

    int pageDifference = targetRealIndex - currentRealIndex;
    if (pageDifference.abs() > _columnTitles.length / 2) {
      if (pageDifference > 0) {
        pageDifference -= _columnTitles.length;
      } else {
        pageDifference += _columnTitles.length;
      }
    }
    final int targetPage = currentPage + pageDifference;

    const Duration duration = Duration(milliseconds: 300);
    const Curve curve = Curves.easeInOut;

    _titlePageController.animateToPage(
      targetPage,
      duration: duration,
      curve: curve,
    );
    _boardPageController.animateToPage(
      targetPage,
      duration: duration,
      curve: curve,
    );
  }

  Color _getBorderColor(String statusTitle) {
    switch (statusTitle) {
      case KanbanBoard.fase1:
        return AppColors.accentRed;
      case KanbanBoard.fase2:
        return AppColors.accentOrange;
      case KanbanBoard.fase3:
        return AppColors.cyberBlue;
      case KanbanBoard.fase4:
        return AppColors.accentGreen;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTextStyle = theme.appBarTheme.titleTextStyle;
    const double appBarHeight = 80.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(appBarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: theme.appBarTheme.backgroundColor,
              child: SafeArea(
                child: Stack(
                  children: [
                    Align(
                      alignment: const Alignment(-1.0, 0.2),
                      child: BackButton(color: theme.iconTheme.color),
                    ),
                    Align(
                      alignment: const Alignment(0.0, 0.2),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: Text(
                          widget.project.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: appBarTextStyle,
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment(1.0, 0.2),
                      child: GlobalAppBarMenu(
                        currentScreen: AppScreen.projectDetails,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // --- INICIO DE CAMBIOS: Añadimos el ScrollController ---
      body: ListView(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        // --- FIN DE CAMBIOS ---
        children: [
          const SizedBox(height: appBarHeight),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 55, 16, 0),
            child: NeonCard(
              glowColor: AppColors.tonalBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.project.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cyberBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.project.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      InfoBlock(
                        icon: Icons.flag_outlined,
                        label: 'ESTADO',
                        value:
                            '${widget.project.status} (${(widget.project.overallProgress * 100).toStringAsFixed(0)}%)',
                        glowColor: AppColors.neonYellow,
                      ),
                      const SizedBox(height: 12),
                      InfoBlock(
                        icon: Icons.attach_money_outlined,
                        label: 'PRESUPUESTO',
                        value: '\$${widget.project.budget}',
                        glowColor: AppColors.neonMoneyGreen,
                      ),
                      const SizedBox(height: 12),
                      InfoBlock(
                        icon: Icons.people_outline,
                        label: 'EQUIPO',
                        value: widget.project.team.join('\n'),
                        glowColor: AppColors.neonPink,
                      ),
                      const SizedBox(height: 12),
                      InfoBlock(
                        icon: Icons.code_outlined,
                        label: 'TECNOLOGÍAS',
                        value: widget.project.technologies.join('\n'),
                        glowColor: AppColors.cyberBlue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 60,
            child: PageView.builder(
              controller: _titlePageController,
              itemCount: 10000, // Infinito
              onPageChanged: (int index) {
                final int realIndex = index % _columnTitles.length;
                if (realIndex != _currentPageIndex) {
                  setState(() {
                    _currentPageIndex = realIndex;
                  });
                }
              },
              itemBuilder: (context, index) {
                final int realIndex = index % _columnTitles.length;
                final bool isSelected = _currentPageIndex == realIndex;
                final title = _columnTitles[realIndex];
                final color = _getBorderColor(title);

                return InkWell(
                  onTap: () {
                    _scrollToPage(index);
                  },
                  child: Center(
                    child: AnimatedScale(
                      scale: isSelected ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? color : AppColors.grey,
                          fontSize: 15,
                          shadows: isSelected
                              ? [
                                  Shadow(
                                    color: color.withAlpha((255 * 0.7).round()),
                                    blurRadius: 8,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // --- INICIO DE CAMBIOS: Añadimos la GlobalKey ---
          SizedBox(
            key: _kanbanKey, // <-- La Key para el auto-scroll
            height: 450, // Tamaño fijo del Kanban
            child: KanbanBoard(
              projectId: widget.project.id,
              controller: _boardPageController,
              milestones: widget.project.milestones,
              // Pasamos el título a resaltar
              highlightMilestoneTitle: widget.highlightMilestoneTitle,
            ),
          ),
          // --- FIN DE CAMBIOS ---
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
