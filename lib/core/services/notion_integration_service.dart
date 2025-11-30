import '../../domain/entities/productivity_integration.dart';
import '../../domain/entities/task_entity.dart';
import '../utils/logger.dart';

/// Notion Integration Service
///
/// Handles integration with Notion API for two-way task sync
/// NOTE: This is a skeleton implementation. In a real app, you would:
/// 1. Add notion_api or http package to pubspec.yaml
/// 2. Implement Notion OAuth 2.0 authentication
/// 3. Implement Notion API v1 endpoints
/// 4. Handle rate limiting (3 requests per second)
/// 5. Implement proper error handling
/// 6. Support rich text formatting conversion
class NotionIntegrationService {
  final _logger = Logger();

  // Notion API endpoints
  static const _baseUrl = 'https://api.notion.com/v1';
  static const _authUrl = 'https://api.notion.com/v1/oauth/authorize';
  static const _tokenUrl = 'https://api.notion.com/v1/oauth/token';
  static const _databasesEndpoint = '/databases';
  static const _pagesEndpoint = '/pages';
  static const _searchEndpoint = '/search';
  static const _usersEndpoint = '/users/me';

  // In a real implementation:
  // final http.Client _httpClient;
  // final NotionClient _notionClient;

  /// Authenticate with Notion OAuth 2.0
  ///
  /// Returns access token for API calls
  Future<Map<String, String>> authenticate({
    required String clientId,
    required String clientSecret,
    required String redirectUri,
  }) async {
    try {
      _logger.info('Starting Notion OAuth authentication');

      // In a real implementation:
      // 1. Open OAuth authorization URL in browser
      // 2. User grants permissions
      // 3. Handle redirect with authorization code
      // 4. Exchange code for access token
      //
      // final authUrl = Uri.parse(_authUrl).replace(queryParameters: {
      //   'client_id': clientId,
      //   'redirect_uri': redirectUri,
      //   'response_type': 'code',
      // });
      //
      // // After user authorization, exchange code for token:
      // final response = await _httpClient.post(
      //   Uri.parse(_tokenUrl),
      //   headers: {
      //     'Authorization': 'Basic ${base64.encode(utf8.encode('$clientId:$clientSecret'))}',
      //     'Content-Type': 'application/json',
      //   },
      //   body: json.encode({
      //     'grant_type': 'authorization_code',
      //     'code': authorizationCode,
      //     'redirect_uri': redirectUri,
      //   }),
      // );
      //
      // final data = json.decode(response.body);
      // return {
      //   'access_token': data['access_token'],
      //   'bot_id': data['bot_id'],
      //   'workspace_id': data['workspace_id'],
      //   'workspace_name': data['workspace_name'],
      // };

      throw UnimplementedError(
        'Notion authentication requires notion_api or http package. '
        'Add to pubspec.yaml and implement OAuth 2.0 flow',
      );
    } catch (e, stackTrace) {
      _logger.error('Notion authentication failed',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Disconnect Notion integration
  Future<void> disconnect() async {
    try {
      _logger.info('Disconnecting Notion integration');
      // In a real implementation: Clear stored tokens
      _logger.info('Notion disconnected');
    } catch (e, stackTrace) {
      _logger.error('Failed to disconnect Notion',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Search for databases in Notion workspace
  Future<List<NotionDatabase>> searchDatabases({
    required String accessToken,
    String? query,
  }) async {
    try {
      _logger.info('Searching Notion databases');

      // In a real implementation:
      // final response = await _httpClient.post(
      //   Uri.parse('$_baseUrl$_searchEndpoint'),
      //   headers: {
      //     'Authorization': 'Bearer $accessToken',
      //     'Notion-Version': '2022-06-28',
      //     'Content-Type': 'application/json',
      //   },
      //   body: json.encode({
      //     'filter': {'property': 'object', 'value': 'database'},
      //     if (query != null) 'query': query,
      //   }),
      // );
      //
      // final data = json.decode(response.body);
      // return (data['results'] as List)
      //     .map((db) => _parseDatabaseFromJson(db))
      //     .toList();

      // Skeleton return
      return [
        const NotionDatabase(
          id: 'db1',
          title: 'Tasks Database',
          description: 'Main tasks database',
          properties: [
            NotionProperty(
              id: 'title',
              name: 'Name',
              type: NotionPropertyType.title,
            ),
            NotionProperty(
              id: 'status',
              name: 'Status',
              type: NotionPropertyType.select,
            ),
            NotionProperty(
              id: 'due',
              name: 'Due Date',
              type: NotionPropertyType.date,
            ),
          ],
        ),
      ];
    } catch (e, stackTrace) {
      _logger.error('Failed to search databases',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Fetch pages from a Notion database
  Future<List<ProductivityItem>> fetchPagesFromDatabase({
    required String accessToken,
    required String databaseId,
    int? limit,
  }) async {
    try {
      _logger.info('Fetching pages from database: $databaseId');

      // In a real implementation:
      // Query database with filter and sorts
      // final response = await _httpClient.post(
      //   Uri.parse('$_baseUrl$_databasesEndpoint/$databaseId/query'),
      //   headers: {
      //     'Authorization': 'Bearer $accessToken',
      //     'Notion-Version': '2022-06-28',
      //     'Content-Type': 'application/json',
      //   },
      //   body: json.encode({
      //     if (limit != null) 'page_size': limit,
      //     // Add filters, sorts as needed
      //   }),
      // );
      //
      // final data = json.decode(response.body);
      // return (data['results'] as List)
      //     .map((page) => _parsePageToProductivityItem(page, databaseId))
      //     .toList();

      _logger.info('Fetched pages from database');
      return []; // Skeleton
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch pages', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Create a page in Notion database from task
  Future<ProductivityItem> createPageFromTask({
    required String accessToken,
    required String databaseId,
    required TaskEntity task,
  }) async {
    try {
      _logger.info('Creating Notion page from task: ${task.title}');

      // In a real implementation:
      // Build Notion page properties from task
      // final properties = {
      //   'Name': {
      //     'title': [
      //       {'text': {'content': task.title}}
      //     ]
      //   },
      //   if (task.description != null)
      //     'Description': {
      //       'rich_text': [
      //         {'text': {'content': task.description}}
      //       ]
      //     },
      //   if (task.dueDate != null)
      //     'Due Date': {
      //       'date': {'start': task.dueDate!.toIso8601String()}
      //     },
      //   'Status': {
      //     'select': {'name': _mapTaskStatusToNotion(task.status)}
      //   },
      //   'Priority': {
      //     'select': {'name': task.priority.toString()}
      //   },
      // };
      //
      // final response = await _httpClient.post(
      //   Uri.parse('$_baseUrl$_pagesEndpoint'),
      //   headers: {
      //     'Authorization': 'Bearer $accessToken',
      //     'Notion-Version': '2022-06-28',
      //     'Content-Type': 'application/json',
      //   },
      //   body: json.encode({
      //     'parent': {'database_id': databaseId},
      //     'properties': properties,
      //   }),
      // );
      //
      // final data = json.decode(response.body);
      // return _parsePageToProductivityItem(data, databaseId);

      // Skeleton return
      final itemId = DateTime.now().millisecondsSinceEpoch.toString();
      return ProductivityItem(
        id: itemId,
        integrationId: 'notion-integration',
        provider: ProductivityProvider.notion,
        title: task.title,
        content: task.description,
        databaseId: databaseId,
        url: 'https://notion.so/$itemId',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        linkedTaskId: task.id,
        isSynced: true,
      );
    } catch (e, stackTrace) {
      _logger.error('Failed to create page', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update a Notion page from task changes
  Future<ProductivityItem> updatePage({
    required String accessToken,
    required String pageId,
    required TaskEntity task,
  }) async {
    try {
      _logger.info('Updating Notion page: $pageId');

      // In a real implementation:
      // PATCH request to update page properties
      // final response = await _httpClient.patch(
      //   Uri.parse('$_baseUrl$_pagesEndpoint/$pageId'),
      //   headers: {
      //     'Authorization': 'Bearer $accessToken',
      //     'Notion-Version': '2022-06-28',
      //     'Content-Type': 'application/json',
      //   },
      //   body: json.encode({
      //     'properties': _buildPropertiesFromTask(task),
      //   }),
      // );
      //
      // final data = json.decode(response.body);
      // return _parsePageToProductivityItem(data, null);

      throw UnimplementedError('Update page requires Notion API implementation');
    } catch (e, stackTrace) {
      _logger.error('Failed to update page', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Delete a page from Notion
  Future<void> deletePage({
    required String accessToken,
    required String pageId,
  }) async {
    try {
      _logger.info('Deleting Notion page: $pageId');

      // In a real implementation:
      // Archive the page (Notion doesn't have true delete)
      // await _httpClient.patch(
      //   Uri.parse('$_baseUrl$_pagesEndpoint/$pageId'),
      //   headers: {
      //     'Authorization': 'Bearer $accessToken',
      //     'Notion-Version': '2022-06-28',
      //     'Content-Type': 'application/json',
      //   },
      //   body: json.encode({'archived': true}),
      // );

      _logger.info('Page archived successfully');
    } catch (e, stackTrace) {
      _logger.error('Failed to delete page', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Create task from Notion page
  TaskEntity createTaskFromPage({
    required ProductivityItem page,
    required String userId,
    String? listId,
  }) {
    _logger.info('Creating task from Notion page: ${page.title}');

    // Convert Notion page to task
    return TaskEntity(
      id: '', // Will be generated
      userId: userId,
      listId: listId,
      title: page.title,
      description: page.content,
      status: TaskStatus.todo, // Parse from page properties
      priority: TaskPriority.medium, // Parse from page properties
      createdAt: page.createdAt ?? DateTime.now(),
      updatedAt: page.updatedAt ?? DateTime.now(),
      tags: page.tags,
      // Link back to Notion
      metadata: {
        'notion_page_id': page.id,
        'notion_url': page.url,
        'notion_database_id': page.databaseId,
      },
    );
  }

  /// Check if database is accessible
  Future<bool> checkDatabaseAccess({
    required String accessToken,
    required String databaseId,
  }) async {
    try {
      // In a real implementation:
      // Try to retrieve database metadata
      // final response = await _httpClient.get(
      //   Uri.parse('$_baseUrl$_databasesEndpoint/$databaseId'),
      //   headers: {
      //     'Authorization': 'Bearer $accessToken',
      //     'Notion-Version': '2022-06-28',
      //   },
      // );
      // return response.statusCode == 200;

      return true; // Skeleton
    } catch (e) {
      _logger.warning('Database access check failed: $e');
      return false;
    }
  }

  // Private helper methods

  /// Parse Notion database from JSON
  NotionDatabase _parseDatabaseFromJson(Map<String, dynamic> json) {
    // In real implementation:
    // Extract database properties schema
    // final properties = (json['properties'] as Map<String, dynamic>)
    //     .entries
    //     .map((e) => NotionProperty(
    //           id: e.key,
    //           name: e.value['name'],
    //           type: _parsePropertyType(e.value['type']),
    //         ))
    //     .toList();

    throw UnimplementedError();
  }

  /// Parse Notion page to ProductivityItem
  ProductivityItem _parsePageToProductivityItem(
    Map<String, dynamic> json,
    String? databaseId,
  ) {
    // In real implementation:
    // Extract page properties and content
    // final title = _extractTitle(json['properties']);
    // final content = _extractRichText(json['properties']);
    // final url = json['url'];
    // final createdAt = DateTime.parse(json['created_time']);
    // final updatedAt = DateTime.parse(json['last_edited_time']);

    throw UnimplementedError();
  }

  /// Map task status to Notion select option
  String _mapTaskStatusToNotion(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Done';
      case TaskStatus.cancelled:
        return 'Cancelled';
      default:
        return 'To Do';
    }
  }

  /// Map Notion status to task status
  TaskStatus _mapNotionStatusToTask(String notionStatus) {
    switch (notionStatus.toLowerCase()) {
      case 'to do':
      case 'not started':
        return TaskStatus.todo;
      case 'in progress':
      case 'doing':
        return TaskStatus.inProgress;
      case 'done':
      case 'completed':
        return TaskStatus.completed;
      case 'cancelled':
      case 'archived':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.todo;
    }
  }

  /// Extract title from Notion properties
  String _extractTitle(Map<String, dynamic> properties) {
    // Find the title property
    // final titleProp = properties.values.firstWhere(
    //   (prop) => prop['type'] == 'title',
    //   orElse: () => null,
    // );
    // if (titleProp != null && titleProp['title'] != null) {
    //   final titleArray = titleProp['title'] as List;
    //   if (titleArray.isNotEmpty) {
    //     return titleArray.map((t) => t['plain_text']).join('');
    //   }
    // }
    return '';
  }

  /// Extract rich text content
  String? _extractRichText(Map<String, dynamic> properties, String propName) {
    // Similar to title extraction but for rich_text type
    // Look for property with name and extract text
    return null;
  }
}
