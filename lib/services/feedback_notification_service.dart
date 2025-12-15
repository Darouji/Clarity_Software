// lib/services/feedback_notification_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:clarity_software/models/feedback_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackNotificationService {
  static final FeedbackNotificationService _instance =
      FeedbackNotificationService._internal();
  factory FeedbackNotificationService() => _instance;

  late List<FeedbackMessage> _feedbackMessages;
  late SharedPreferences _prefs;

  static const String _feedbackKey = 'clarity_feedback_data';

  FeedbackNotificationService._internal() {
    _feedbackMessages = [];
  }

  // Debe llamarse en main.dart ANTES de runApp()
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFeedbackFromPrefs();
  }

  // Cargar feedback guardado
  Future<void> _loadFeedbackFromPrefs() async {
    final String? feedbackString = _prefs.getString(_feedbackKey);
    if (feedbackString != null) {
      try {
        final List<dynamic> feedbackJson = jsonDecode(feedbackString);
        _feedbackMessages = feedbackJson
            .map((json) => FeedbackMessage.fromJson(json))
            .toList();
      } catch (e) {
        _feedbackMessages = []; // Iniciar vacío si hay error
      }
    } else {
      _feedbackMessages = []; // Iniciar vacío si no hay nada
    }
  }

  // Guardar feedback
  Future<void> _saveFeedbackToPrefs() async {
    final List<Map<String, dynamic>> feedbackJson = _feedbackMessages
        .map((f) => f.toJson())
        .toList();
    final String feedbackString = jsonEncode(feedbackJson);
    await _prefs.setString(_feedbackKey, feedbackString);
  }

  // --- MÉTODOS PÚBLICOS ---

  /// Añade un nuevo mensaje de feedback y lo guarda
  Future<void> addFeedback({
    required String projectId,
    required String milestoneTitle,
    required String message,
    required FeedbackType type,
    required String author,
  }) async {
    final newMessage = FeedbackMessage(
      id: 'f_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
      projectId: projectId,
      milestoneTitle: milestoneTitle,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      author: author,
      isRead: false, // El feedback nuevo nunca está leído
    );

    _feedbackMessages.add(newMessage);
    await _saveFeedbackToPrefs();
  }

  /// Obtiene todos los mensajes para un hito específico
  List<FeedbackMessage> getFeedbackForMilestone(
    String projectId,
    String milestoneTitle,
  ) {
    return _feedbackMessages
        .where(
          (f) => f.projectId == projectId && f.milestoneTitle == milestoneTitle,
        )
        .toList()
      ..sort(
        (a, b) => b.timestamp.compareTo(a.timestamp),
      ); // Más nuevos primero
  }

  /// Obtiene los mensajes NO LEÍDOS por el cliente para un proyecto
  List<FeedbackMessage> getUnreadFeedbackForProject(String projectId) {
    return _feedbackMessages
        .where(
          (f) => f.projectId == projectId && !f.isRead && f.author != 'Cliente',
        ) // Asumimos que el cliente no lee sus propios msjs
        .toList();
  }

  /// Marca todos los mensajes de un hito como leídos
  Future<void> markMilestoneFeedbackAsRead(
    String projectId,
    String milestoneTitle,
  ) async {
    bool changed = false;
    for (var msg in _feedbackMessages) {
      if (msg.projectId == projectId &&
          msg.milestoneTitle == milestoneTitle &&
          !msg.isRead) {
        msg.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      await _saveFeedbackToPrefs();
    }
  }
}
