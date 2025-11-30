import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5034';
  static String? _accessToken;
  static String? _refreshToken;

  // Helper para construir URLs de imagen correctamente
  // Si la URL ya es completa (Azure Blob), la devuelve tal cual
  // Si es relativa, la concatena con baseUrl
  static String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl; // URL completa de Azure Blob
    }
    return '$baseUrl$imageUrl'; // URL relativa
  }

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
    String? avatarId,
    File? profilePhoto,
    Uint8List? profilePhotoBytes,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/auth/register'),
    );

    request.fields['Email'] = email;
    request.fields['Password'] = password;
    request.fields['FirstName'] = firstName;
    request.fields['LastName'] = lastName;
    request.fields['CareerId'] = careerId;
    request.fields['Semester'] = semester.toString();
    if (phone != null) request.fields['Phone'] = phone;
    if (avatarId != null && avatarId.isNotEmpty)
      request.fields['AvatarId'] = avatarId;

    if (profilePhoto != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profilePhoto', profilePhoto.path),
      );
    } else if (profilePhotoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'profilePhoto',
          profilePhotoBytes,
          filename: 'profile.jpg',
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

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
  static Future<List<Post>> getPosts({
    int? role,
    int page = 1,
    int pageSize = 10,
  }) async {
    String url = '$baseUrl/posts?page=$page&pageSize=$pageSize';
    if (role != null) url += '&role=$role';

    print('🔍 Fetching posts from: $url');

    final response = await http.get(Uri.parse(url), headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('✅ Received ${data.length} posts from API (page $page)');

      final posts = data.map((json) => Post.fromJson(json)).toList();

      // Debug: contar posts por rol
      final role1Count = posts.where((p) => p.role == 1).length;
      final role2Count = posts.where((p) => p.role == 2).length;
      final role3Count = posts.where((p) => p.role == 3).length;
      print(
        '📊 Posts by role - Ayudantes: $role1Count, Estudiantes: $role2Count, Comentarios: $role3Count',
      );

      return posts;
    } else {
      print('❌ Error response: ${response.body}');
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
    File? image,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/posts/student'),
    );

    if (_accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }

    request.fields['Title'] = title;
    request.fields['Content'] = content;
    request.fields['SubjectId'] = subjectId;

    print('========================================');
    print('CREAR POST ESTUDIANTE - REQUEST');
    print('========================================');
    print('Title: $title');
    print('Content: $content');
    print('SubjectId: $subjectId');
    print('Has image (file): ${image != null}');
    print('Has imageBytes: ${imageBytes != null}');
    if (imageBytes != null) {
      print('ImageBytes length: ${imageBytes.length}');
    }
    print('========================================');

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    } else if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename:
              imageFileName ??
              'image.png', // Use original filename or default to PNG
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('========================================');
    print('CREAR POST ESTUDIANTE - RESPUESTA');
    print('========================================');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('Response Headers: ${response.headers}');
    print('========================================');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    } else {
      // El servidor puede devolver texto plano en caso de error
      String errorMsg;
      try {
        final errorJson = json.decode(response.body);
        errorMsg = errorJson['message'] ?? errorJson.toString();
      } catch (e) {
        // Si no es JSON, usar el texto plano
        errorMsg = response.body;
      }
      throw Exception(
        'Error al crear post de estudiante (${response.statusCode}): $errorMsg',
      );
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
    print('========================================');
    print('ELIMINANDO POST');
    print('========================================');
    print('Post ID: $postId');
    print('URL: $baseUrl/posts/$postId');

    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId'),
      headers: _getHeaders(),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('========================================');

    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorMsg =
          'Error al eliminar post (${response.statusCode}): ${response.body}';
      print('ERROR: $errorMsg');
      throw Exception(errorMsg);
    }

    print('Post eliminado exitosamente');
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
  // SEARCH POSTS
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
    File? image,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/posts/$postId/replies'),
    );

    if (_accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }

    request.fields['Content'] = content;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    } else if (imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageFileName ?? 'reply_image.png',
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

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

  // 🔥🔥🔥 FIX IMPORTANTE PARA QUE SE GUARDEN LOS CAMBIOS 🔥🔥🔥
  static Future<Map<String, dynamic>> updateUser({
    required String firstName,
    required String lastName,
    String? phone,
    required int semester,
    required String careerId,
    String? avatarId,
    String? calendlyUrl,
    File? profilePhoto,
    Uint8List? profilePhotoBytes,
  }) async {
    // IMPORTANTE: El backend espera multipart/form-data, NO JSON
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/users/me'));

    // Add authorization header
    if (_accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }

    // Add form fields
    request.fields['FirstName'] = firstName;
    request.fields['LastName'] = lastName;
    request.fields['Semester'] = semester.toString();
    request.fields['CareerId'] = careerId;

    if (phone != null && phone.isNotEmpty) {
      request.fields['Phone'] = phone;
    }

    if (avatarId != null && avatarId.isNotEmpty) {
      request.fields['AvatarId'] = avatarId;
    }

    if (calendlyUrl != null && calendlyUrl.isNotEmpty) {
      request.fields['CalendlyUrl'] = calendlyUrl;
    }

    if (profilePhoto != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profilePhoto', profilePhoto.path),
      );
    } else if (profilePhotoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'profilePhoto',
          profilePhotoBytes,
          filename: 'profile.jpg',
        ),
      );
    }

    // Debug logging
    print('========================================');
    print('ENVIANDO ACTUALIZACION DE PERFIL');
    print('========================================');
    print('URL: $baseUrl/users/me');
    print('Campos (multipart/form-data):');
    request.fields.forEach((key, value) {
      print('  $key: $value');
    });
    print('========================================');

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('========================================');
      print('RESPUESTA DEL SERVIDOR');
      print('========================================');
      print('Status Code: ${response.statusCode}');
      print('Response Body:');
      print(response.body);
      print('========================================');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          print('PERFIL ACTUALIZADO EXITOSAMENTE');
          print('Datos recibidos del servidor:');
          print(json.encode(responseData));
          print('========================================');
          return responseData;
        } catch (e) {
          print('ERROR AL PARSEAR RESPUESTA: $e');
          print('========================================');
          throw Exception('Error al parsear respuesta del servidor');
        }
      } else {
        print('ERROR DEL SERVIDOR (Status ${response.statusCode})');
        print('Mensaje: ${response.body}');
        print('========================================');

        // Try to parse error message
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['message'] ?? errorData['error'] ?? response.body;
          throw Exception('Error del backend: $errorMessage');
        } catch (e) {
          throw Exception(
            'Error al actualizar perfil (${response.statusCode}): ${response.body}',
          );
        }
      }
    } catch (e) {
      print('========================================');
      print('EXCEPCION EN LA PETICION HTTP');
      print('Error: $e');
      print('========================================');
      rethrow;
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
  // FAVORITES
  // --------------------------
  static Future<void> addFavorite(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites/$userId'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception(
        'Error al agregar favorito (${response.statusCode}): ${response.body}',
      );
    }
  }

  static Future<void> removeFavorite(String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/favorites/$userId'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Error al eliminar favorito (${response.statusCode}): ${response.body}',
      );
    }
  }

  static Future<List<FavoriteUserDto>> getFavorites() async {
    final response = await http.get(
      Uri.parse('$baseUrl/favorites'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => FavoriteUserDto.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar favoritos');
    }
  }

  static Future<bool> isFavorite(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/favorites/is-favorite/$userId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as bool;
    } else {
      throw Exception('Error al verificar favorito');
    }
  }

  // --------------------------
  // CALENDLY
  // --------------------------
  static Future<Map<String, dynamic>> syncCalendlyEvents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/calendly/events/sync'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al sincronizar eventos de Calendly');
    }
  }

  static Future<List<dynamic>> getUpcomingCalendlyEvents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/calendly/events/upcoming'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Error al obtener eventos próximos de Calendly');
    }
  }

  // --------------------------
  // MY REPLIES & USER REPLIES
  // --------------------------
  static Future<List<MyReplyDto>> getMyReplies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/replies/mine'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => MyReplyDto.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar mis respuestas');
    }
  }

  static Future<List<MyReplyDto>> getUserReplies(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/replies/user/$userId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => MyReplyDto.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar respuestas del usuario');
    }
  }

  // --------------------------
  // USER ONLINE STATUS
  // --------------------------
  static Future<Map<String, dynamic>> getUserOnlineStatus(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/online-status'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener estado en línea del usuario');
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
