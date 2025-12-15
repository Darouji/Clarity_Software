// lib/screens/client/project_details_screen.dart
import 'dart:ui';
import 'package:clarity_software/models/project.dart';
import 'package:clarity_software/theme/app_colors.dart';
import 'package:clarity_software/widgets/info_block.dart';
import 'package:clarity_software/widgets/kanban_board.dart';
import 'package:clarity_software/widgets/neon_card.dart';
import 'package:flutter/material.dart';
import 'package:clarity_software/widgets/global_menu.dart';
import 'package:clarity_software/models/milestone.dart';
import 'package:clarity_software/services/project_service.dart';
// --- NUEVO IMPORT ---
import 'package:clarity_software/screens/client/documents_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String? highlightMilestoneTitle;
  final Project project;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
    this.highlightMilestoneTitle,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final ProjectService _projectService = ProjectService();

  late PageController _titlePageController;
  late PageController _boardPageController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _kanbanKey = GlobalKey();

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

    _currentPageIndex = _kanbanInitialPage % _columnTitles.length;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleHighlight();
    });
  }

  @override
  void dispose() {
    _titlePageController.dispose();
    _boardPageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleHighlight() {
    if (widget.highlightMilestoneTitle == null) return;
    try {
      final milestoneToFind = widget.project.milestones.firstWhere(
        (m) => m.title == widget.highlightMilestoneTitle,
      );
      final faseName = getFaseName(milestoneToFind.fase);
      int targetRealIndex = _columnTitles.indexOf(faseName);
      if (targetRealIndex == -1) return;
      _scrollToPage(targetRealIndex);
      final kanbanContext = _kanbanKey.currentContext;
      if (kanbanContext != null) {
        Scrollable.ensureVisible(
          kanbanContext,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      // Ignorar si no encuentra hito
    }
  }

  void _scrollToPage(int pageIndex) {
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
      body: StreamBuilder<Project>(
        stream: _projectService.getProjectStream(widget.project.id),
        initialData: widget.project,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final project = snapshot.data ?? widget.project;

          return ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
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
                        project.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cyberBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        project.description,
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
                                '${project.status} (${(project.overallProgress * 100).toStringAsFixed(0)}%)',
                            glowColor: AppColors.neonYellow,
                          ),
                          const SizedBox(height: 12),
                          InfoBlock(
                            icon: Icons.attach_money_outlined,
                            label: 'PRESUPUESTO',
                            value: '\$${project.budget}',
                            glowColor: AppColors.neonMoneyGreen,
                          ),
                          const SizedBox(height: 12),
                          InfoBlock(
                            icon: Icons.people_outline,
                            label: 'EQUIPO',
                            value: project.team.join('\n'),
                            glowColor: AppColors.neonPink,
                          ),
                          const SizedBox(height: 12),
                          InfoBlock(
                            icon: Icons.code_outlined,
                            label: 'TECNOLOGÍAS',
                            value: project.technologies.join('\n'),
                            glowColor: AppColors.cyberBlue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // --- NUEVO: Acceso al Centro de Documentación ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20.0,
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentsScreen(project: project),
                      ),
                    );
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.solidFolderOpen,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'CENTRO DE DOCUMENTACIÓN',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // -----------------------------------------------
              SizedBox(
                height: 60,
                child: PageView.builder(
                  controller: _titlePageController,
                  itemCount: 10000,
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
                                        color: color.withAlpha(
                                          (255 * 0.7).round(),
                                        ),
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

              SizedBox(
                key: _kanbanKey,
                height: 450,
                child: KanbanBoard(
                  project: project,
                  controller: _boardPageController,
                  highlightMilestoneTitle: widget.highlightMilestoneTitle,
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
