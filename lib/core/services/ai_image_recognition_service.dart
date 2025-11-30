import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/entities/ai_extraction_result.dart';
import '../utils/logger.dart';

/// AI Image Recognition Service
///
/// Flagship feature that extracts tasks from images using ML Kit OCR
/// and intelligent task parsing.
class AiImageRecognitionService {
  final TextRecognizer _textRecognizer;
  final _logger = Logger();

  AiImageRecognitionService()
      : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Extract tasks from an image
  Future<AiExtractionResult> extractTasksFromImage({
    required String imagePath,
    ExtractionMode mode = ExtractionMode.auto,
  }) async {
    try {
      _logger.info('Starting AI extraction from image: $imagePath');
      _logger.info('Extraction mode: ${mode.displayName}');

      // Step 1: Extract text using ML Kit OCR
      final extractedText = await _extractTextFromImage(imagePath);
      _logger.info('Extracted ${extractedText.length} characters of text');

      // Step 2: Parse tasks from extracted text
      final parsedTasks = _parseTasksFromText(
        extractedText,
        mode: mode,
      );
      _logger.info('Parsed ${parsedTasks.length} tasks');

      // Step 3: Calculate overall confidence
      final confidence = _calculateOverallConfidence(parsedTasks);

      // Step 4: Create result
      final result = AiExtractionResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: imagePath,
        extractedText: extractedText,
        parsedTasks: parsedTasks,
        confidenceScore: confidence,
        extractedAt: DateTime.now(),
        mode: mode,
        metadata: {
          'textLength': extractedText.length,
          'taskCount': parsedTasks.length,
        },
      );

      _logger.info('AI extraction completed with ${result.taskCount} tasks');
      return result;
    } catch (e, stackTrace) {
      _logger.error('AI extraction failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Extract text from image using ML Kit
  Future<String> _extractTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      _logger.error('OCR extraction failed', error: e);
      rethrow;
    }
  }

  /// Parse tasks from extracted text using NLP and pattern matching
  List<ParsedTask> _parseTasksFromText(
    String text, {
    required ExtractionMode mode,
  }) {
    final tasks = <ParsedTask>[];
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Skip very short lines (likely noise)
      if (line.length < 3) continue;

      // Check if line looks like a task
      final isTask = _isTaskLine(line, mode);
      if (!isTask) continue;

      // Parse task details
      final task = _parseTaskLine(line, position: i);
      if (task != null) {
        tasks.add(task);
      }
    }

    return tasks;
  }

  /// Check if a line looks like a task
  bool _isTaskLine(String line, ExtractionMode mode) {
    final lowerLine = line.toLowerCase();

    // Task indicators
    final taskIndicators = [
      // Checkbox patterns
      RegExp(r'^\s*[\[\(][\sxX✓✗]\s*[\]\)]'),
      // Bullet points
      RegExp(r'^\s*[-•*]'),
      // Numbers
      RegExp(r'^\s*\d+[\.)]\s'),
      // Action verbs at start
      RegExp(r'^(call|email|buy|complete|finish|review|update|create|send|schedule|book|order|prepare|plan|write|read|check|fix|research|contact|meet|discuss|submit|follow|attend|organize)'),
    ];

    // Check for task indicators
    for (final pattern in taskIndicators) {
      if (pattern.hasMatch(lowerLine)) {
        return true;
      }
    }

    // Mode-specific checks
    switch (mode) {
      case ExtractionMode.receipt:
        // Look for amounts
        return RegExp(r'\$\d+|\d+\.\d+').hasMatch(line);
      case ExtractionMode.businessCard:
        // Look for contact info
        return RegExp(r'@|phone|email|tel:|mobile', caseSensitive: false).hasMatch(lowerLine);
      case ExtractionMode.whiteboard:
      case ExtractionMode.note:
      case ExtractionMode.book:
      case ExtractionMode.product:
      case ExtractionMode.auto:
        // Use general detection
        break;
    }

    // If it contains TODO, TASK, or action words anywhere
    final hasTaskWords = RegExp(
      r'todo|task|need to|must|should|remind|remember|don\'t forget',
      caseSensitive: false,
    ).hasMatch(lowerLine);

    return hasTaskWords;
  }

  /// Parse a single task line
  ParsedTask? _parseTaskLine(String line, {required int position}) {
    // Clean the line
    var cleanLine = line;

    // Remove checkbox markers
    cleanLine = cleanLine.replaceAll(RegExp(r'^\s*[\[\(][\sxX✓✗]\s*[\]\)]\s*'), '');
    // Remove bullet points
    cleanLine = cleanLine.replaceAll(RegExp(r'^\s*[-•*]\s*'), '');
    // Remove numbers
    cleanLine = cleanLine.replaceAll(RegExp(r'^\s*\d+[\.)]\s*'), '');

    cleanLine = cleanLine.trim();

    if (cleanLine.isEmpty) return null;

    // Extract due date
    final dueDate = _extractDueDate(cleanLine);

    // Extract priority
    final priority = _extractPriority(cleanLine);

    // Extract tags
    final tags = _extractTags(cleanLine);

    // Calculate confidence based on factors
    double confidence = 0.7; // Base confidence

    // Boost confidence if has clear task structure
    if (line.contains(RegExp(r'^\s*[\[\(]'))) confidence += 0.1;
    if (dueDate != null) confidence += 0.1;
    if (priority > 0) confidence += 0.05;
    if (tags.isNotEmpty) confidence += 0.05;

    // Cap at 1.0
    confidence = confidence.clamp(0.0, 1.0);

    return ParsedTask(
      title: cleanLine,
      confidence: confidence,
      originalText: line,
      position: position,
      dueDate: dueDate,
      priority: priority,
      tags: tags,
    );
  }

  /// Extract due date from text
  DateTime? _extractDueDate(String text) {
    final lowerText = text.toLowerCase();
    final now = DateTime.now();

    // Today
    if (lowerText.contains('today')) {
      return DateTime(now.year, now.month, now.day);
    }

    // Tomorrow
    if (lowerText.contains('tomorrow')) {
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    }

    // This week
    if (lowerText.contains('this week')) {
      final endOfWeek = now.add(Duration(days: 7 - now.weekday));
      return DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);
    }

    // Next week
    if (lowerText.contains('next week')) {
      final nextWeek = now.add(Duration(days: 7 + (7 - now.weekday)));
      return DateTime(nextWeek.year, nextWeek.month, nextWeek.day);
    }

    // Try to parse specific dates
    // Format: MM/DD, MM-DD, DD/MM, etc.
    final datePattern = RegExp(r'(\d{1,2})[\/\-](\d{1,2})');
    final match = datePattern.firstMatch(text);
    if (match != null) {
      try {
        final num1 = int.parse(match.group(1)!);
        final num2 = int.parse(match.group(2)!);

        // Assume MM/DD format (US)
        if (num1 <= 12 && num2 <= 31) {
          return DateTime(now.year, num1, num2);
        }
        // Try DD/MM format
        else if (num2 <= 12 && num1 <= 31) {
          return DateTime(now.year, num2, num1);
        }
      } catch (e) {
        // Invalid date, ignore
      }
    }

    return null;
  }

  /// Extract priority from text
  int _extractPriority(String text) {
    final lowerText = text.toLowerCase();

    // Explicit priority markers
    if (lowerText.contains('!!!') || lowerText.contains('urgent') || lowerText.contains('critical')) {
      return 4; // Critical
    }
    if (lowerText.contains('!!') || lowerText.contains('important') || lowerText.contains('high priority')) {
      return 3; // High
    }
    if (lowerText.contains('!') || lowerText.contains('medium')) {
      return 2; // Medium
    }
    if (lowerText.contains('low priority')) {
      return 1; // Low
    }

    // Infer from words
    if (lowerText.contains('asap') || lowerText.contains('immediately')) {
      return 4; // Critical
    }

    return 0; // No priority
  }

  /// Extract tags from text
  List<String> _extractTags(String text) {
    final tags = <String>[];

    // Extract hashtags
    final hashtagPattern = RegExp(r'#(\w+)');
    final matches = hashtagPattern.allMatches(text);
    for (final match in matches) {
      final tag = match.group(1);
      if (tag != null && !tags.contains(tag)) {
        tags.add(tag);
      }
    }

    // Extract common categories
    final lowerText = text.toLowerCase();
    if (lowerText.contains('work') || lowerText.contains('office')) tags.add('work');
    if (lowerText.contains('personal') || lowerText.contains('home')) tags.add('personal');
    if (lowerText.contains('shopping') || lowerText.contains('buy')) tags.add('shopping');
    if (lowerText.contains('health') || lowerText.contains('fitness')) tags.add('health');
    if (lowerText.contains('meeting') || lowerText.contains('call')) tags.add('meeting');

    return tags;
  }

  /// Calculate overall confidence from parsed tasks
  double _calculateOverallConfidence(List<ParsedTask> tasks) {
    if (tasks.isEmpty) return 0.0;

    final avgConfidence = tasks.map((t) => t.confidence).reduce((a, b) => a + b) / tasks.length;
    return avgConfidence;
  }

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}
