/// AI Image Recognition Extraction Result Entity
///
/// Represents the result of AI-powered image text extraction and task parsing.
/// This is the flagship feature that differentiates DingDong from competitors.

/// AI extraction result containing parsed tasks from image
class AiExtractionResult {
  /// Unique identifier for this extraction
  final String id;

  /// Original image path
  final String imagePath;

  /// Raw extracted text from OCR
  final String extractedText;

  /// Parsed tasks from the extracted text
  final List<ParsedTask> parsedTasks;

  /// Overall confidence score (0.0 - 1.0)
  final double confidenceScore;

  /// Timestamp of extraction
  final DateTime extractedAt;

  /// Extraction mode used
  final ExtractionMode mode;

  /// Additional metadata
  final Map<String, dynamic> metadata;

  const AiExtractionResult({
    required this.id,
    required this.imagePath,
    required this.extractedText,
    required this.parsedTasks,
    required this.confidenceScore,
    required this.extractedAt,
    required this.mode,
    this.metadata = const {},
  });

  /// Copy with method
  AiExtractionResult copyWith({
    String? id,
    String? imagePath,
    String? extractedText,
    List<ParsedTask>? parsedTasks,
    double? confidenceScore,
    DateTime? extractedAt,
    ExtractionMode? mode,
    Map<String, dynamic>? metadata,
  }) {
    return AiExtractionResult(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      extractedText: extractedText ?? this.extractedText,
      parsedTasks: parsedTasks ?? this.parsedTasks,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      extractedAt: extractedAt ?? this.extractedAt,
      mode: mode ?? this.mode,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Has tasks
  bool get hasTasks => parsedTasks.isNotEmpty;

  /// Number of tasks found
  int get taskCount => parsedTasks.length;

  /// High confidence extraction
  bool get isHighConfidence => confidenceScore >= 0.8;

  /// Medium confidence extraction
  bool get isMediumConfidence => confidenceScore >= 0.5 && confidenceScore < 0.8;

  /// Low confidence extraction
  bool get isLowConfidence => confidenceScore < 0.5;
}

/// Parsed task from AI extraction
class ParsedTask {
  /// Task title
  final String title;

  /// Task description (optional)
  final String? description;

  /// Due date (if detected)
  final DateTime? dueDate;

  /// Priority (1-4, if detected)
  final int priority;

  /// Tags (if detected)
  final List<String> tags;

  /// Confidence score for this task (0.0 - 1.0)
  final double confidence;

  /// Original text that was parsed
  final String originalText;

  /// Position in the original text (line number or index)
  final int position;

  const ParsedTask({
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 0,
    this.tags = const [],
    required this.confidence,
    required this.originalText,
    required this.position,
  });

  /// Copy with method
  ParsedTask copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    List<String>? tags,
    double? confidence,
    String? originalText,
    int? position,
  }) {
    return ParsedTask(
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      confidence: confidence ?? this.confidence,
      originalText: originalText ?? this.originalText,
      position: position ?? this.position,
    );
  }

  /// High confidence task
  bool get isHighConfidence => confidence >= 0.8;

  /// Has due date
  bool get hasDueDate => dueDate != null;

  /// Has priority
  bool get hasPriority => priority > 0;

  /// Has tags
  bool get hasTags => tags.isNotEmpty;
}

/// AI extraction modes for different use cases
enum ExtractionMode {
  /// General notes/todo items
  note,

  /// Whiteboard or meeting notes
  whiteboard,

  /// Receipts with amounts and dates
  receipt,

  /// Business card with contact info
  businessCard,

  /// Book page with reading tasks
  book,

  /// Product with shopping reminders
  product,

  /// Automatic mode detection
  auto,
}

/// Extension for extraction mode
extension ExtractionModeX on ExtractionMode {
  /// Display name
  String get displayName {
    switch (this) {
      case ExtractionMode.note:
        return 'Note';
      case ExtractionMode.whiteboard:
        return 'Whiteboard';
      case ExtractionMode.receipt:
        return 'Receipt';
      case ExtractionMode.businessCard:
        return 'Business Card';
      case ExtractionMode.book:
        return 'Book';
      case ExtractionMode.product:
        return 'Product';
      case ExtractionMode.auto:
        return 'Auto';
    }
  }

  /// Description
  String get description {
    switch (this) {
      case ExtractionMode.note:
        return 'Extract todo items from handwritten or printed notes';
      case ExtractionMode.whiteboard:
        return 'Extract multiple tasks from whiteboard photos';
      case ExtractionMode.receipt:
        return 'Extract amount, merchant, and date from receipts';
      case ExtractionMode.businessCard:
        return 'Extract contact information for follow-up tasks';
      case ExtractionMode.book:
        return 'Create reading tasks from book pages';
      case ExtractionMode.product:
        return 'Create shopping reminders from product images';
      case ExtractionMode.auto:
        return 'Automatically detect the best extraction mode';
    }
  }
}
