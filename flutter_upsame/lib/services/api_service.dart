import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'https://upsameapi.azurewebsites.net';
  static String? _accessToken;
  static String? _refreshToken;

  // --------------------------
  // AUTH
  // --------------------------
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String careerId,
    required int semester,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'careerId': careerId,
        'semester': semester,
        'phone': phone,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
        json.decode(response.body)['message'] ?? 'Error al registrar',
      );
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['accessToken'];
      _refreshToken = data['refreshToken'];
      return data;
    } else {
      throw Exception(
        json.decode(response.body)['message'] ?? 'Error al iniciar sesión',
      );
    }
  }

  static Future<Map<String, dynamic>> refreshToken() async {
    if (_refreshToken == null) {
      throw Exception('No hay refresh token disponible');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refreshToken': _refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['accessToken'];
      _refreshToken = data['refreshToken'];
      return data;
    } else {
      throw Exception('Error al refrescar token');
    }
  }

  // --------------------------
  // AVATARS
  // --------------------------
  static Future<List<Avatar>> getAvatars() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/avatars'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Avatar.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar avatares');
    }
  }

  // --------------------------
  // FACULTIES / CAREERS
  // --------------------------
  static Future<List<Faculty>> getFaculties() async {
    final response = await http.get(
      Uri.parse('$baseUrl/directory/faculties'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Faculty.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar facultades');
    }
  }

  static Future<List<Career>> getCareersByFaculty(String facultyId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/directory/faculties/$facultyId/careers'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Career.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar carreras');
    }
  }

  static Future<List<User>> getUsersByCareer(String careerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/directory/careers/$careerId/users'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar usuarios');
    }
  }

  // --------------------------
  // SUBJECTS
  // --------------------------
  static Future<List<Subject>> getAllSubjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/directory/subjects'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Subject.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar materias');
    }
  }

  static Future<List<Subject>> searchSubjects(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/directory/subjects/search?q=$query'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final subjects = data.map((json) => Subject.fromJson(json)).toList();

      // Eliminar duplicados por nombre
      final seen = <String>{};
      return subjects.where((subject) => seen.add(subject.name)).toList();
    } else {
      throw Exception('Error al buscar materias');
    }
  }

  // --------------------------
  // POSTS
  // --------------------------
  static Future<List<Post>> getPosts({int? role}) async {
    String url = '$baseUrl/posts';
    if (role != null) url += '?role=$role';

    final response = await http.get(Uri.parse(url), headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar posts');
    }
  }

  static Future<Post> createHelperPost({
    required String title,
    required String content,
    required String subjectId,
    required int capacity,
    required int maxCapacity,
    required String calendlyUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/helper'),
      headers: _getHeaders(),
      body: json.encode({
        'title': title,
        'content': content,
        'subjectId': subjectId,
        'capacity': capacity,
        'maxCapacity': maxCapacity,
        'calendlyUrl': calendlyUrl,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear post de ayudante');
    }
  }

  static Future<Post> createStudentPost({
    required String title,
    required String content,
    required String subjectId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/student'),
      headers: _getHeaders(),
      body: json.encode({
        'title': title,
        'content': content,
        'subjectId': subjectId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear post de estudiante');
    }
  }

  static Future<Post> createCommentPost({
    required String title,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/comment'),
      headers: _getHeaders(),
      body: json.encode({'title': title, 'content': content}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear comentario');
    }
  }

  static Future<Post> updatePost(
    String postId,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$postId'),
      headers: _getHeaders(),
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar post');
    }
  }

  static Future<void> deletePost(String postId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar post');
    }
  }

  static Future<List<Post>> getMyPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/mine'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar mis posts');
    }
  }

  // --------------------------
  // SEARCH POSTS BY SUBJECT (por NOMBRE, usando /posts/search-by-subject)
  // --------------------------
  static Future<List<Post>> searchPostsBySubject(
    String subjectName, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/posts/search-by-subject').replace(
      queryParameters: {
        'q': subjectName,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    final response = await http.get(uri, headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al buscar posts por materia: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // --------------------------
  // REPLIES
  // --------------------------
  static Future<List<Reply>> getReplies(String postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/replies'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Reply.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar respuestas');
    }
  }

  static Future<Reply> createReply({
    required String postId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/replies'),
      headers: _getHeaders(),
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 200) {
      return Reply.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear respuesta');
    }
  }

  // --------------------------
  // PUBLIC USERS
  // --------------------------
  static Future<User> getPublicUser(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/public-users/$userId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar usuario público');
    }
  }

  // --------------------------
  // CURRENT USER
  // --------------------------
  static Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar perfil');
    }
  }

  static Future<Map<String, dynamic>> updateUser({
    required String firstName,
    required String lastName,
    String? phone,
    required int semester,
    required String careerId,
    String? avatarId,
    String? calendlyUrl,
  }) async {
    final body = {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'semester': semester,
      'careerId': careerId,
    };

    if (avatarId != null) body['avatarId'] = avatarId;
    if (calendlyUrl != null) body['calendlyUrl'] = calendlyUrl;

    final response = await http.put(
      Uri.parse('$baseUrl/users/me'),
      headers: _getHeaders(),
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al actualizar perfil');
    }
  }

  static Future<Map<String, dynamic>> getUserById(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar usuario');
    }
  }

  static Future<List<Avatar>> getAvatarOptions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/avatars/options'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Avatar.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar opciones de avatar');
    }
  }

  // --------------------------
  // TOKEN HEADERS
  // --------------------------
  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  static String? get accessToken => _accessToken;
  static String? get getRefreshToken => _refreshToken;

  static void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }
}