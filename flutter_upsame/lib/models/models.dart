class Career {
  final String id;
  final String name;
  final String facultyId;

  Career({
    required this.id,
    required this.name,
    required this.facultyId,
  });

  factory Career.fromJson(Map<String, dynamic> json) {
    return Career(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      facultyId: json['facultyId'] ?? '',
    );
  }
}

class Faculty {
  final String id;
  final String name;

  Faculty({
    required this.id,
    required this.name,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class Avatar {
  final String id;
  final String label;
  final String url;

  Avatar({
    required this.id,
    required this.label,
    required this.url,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      id: json['id'] ?? '',
      label: json['label'] ?? json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? avatarUrl;
  final String? avatarId;
  final String? profilePhotoUrl;
  final String? careerId;
  final String? career;
  final int semester;
  final String? phone;
  final String? calendlyUrl;
  final List<Post>? posts;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.avatarUrl,
    this.avatarId,
    this.profilePhotoUrl,
    this.careerId,
    this.career,
    required this.semester,
    this.phone,
    this.calendlyUrl,
    this.posts,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Construir fullName si no viene en el JSON
    String? computedFullName = json['fullName'] ?? json['full_name'];

    if (computedFullName == null || computedFullName.isEmpty) {
      // Intentar con firstName/lastName (camelCase)
      String? firstName = json['firstName'];
      String? lastName = json['lastName'];

      // Intentar con first_name/last_name (snake_case)
      firstName ??= json['first_name'];
      lastName ??= json['last_name'];

      // Intentar con name/username
      if (firstName == null && lastName == null) {
        computedFullName =
            json['name'] ?? json['username'] ?? json['nombres'];
      } else if (firstName != null && lastName != null) {
        computedFullName = '$firstName $lastName';
      } else if (firstName != null) {
        computedFullName = firstName;
      }
    }

    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? json['first_name'],
      lastName: json['lastName'] ?? json['last_name'],
      fullName: computedFullName,
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
      avatarId: json['avatarId'] ?? json['avatar_id'],
      profilePhotoUrl: json['profilePhotoUrl'] ?? json['profile_photo_url'],
      careerId: json['careerId'] ?? json['career_id'],
      career: json['career'],
      semester: json['semester'] ?? 1,
      phone: json['phone'],
      calendlyUrl: json['calendlyUrl'] ?? json['calendly_url'],
      posts: json['posts'] != null
          ? (json['posts'] as List)
              .map((p) => Post.fromJson(p as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return email;
  }

  String get photoUrl {
    if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty) {
      return profilePhotoUrl!;
    }
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return avatarUrl!;
    }
    if (avatarId != null && avatarId!.isNotEmpty) {
      return '/avatars/$avatarId'; // Path para avatares predefinidos
    }
    return '';
  }
}

class Subject {
  final String id;
  final String name;
  final String slug;
  final String careerId;

  Subject({
    required this.id,
    required this.name,
    required this.slug,
    required this.careerId,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      careerId: json['careerId'] ?? '',
    );
  }
}

class Post {
  final String id;
  final String title;
  final String content;
  final String? contentPreview;
  final String? userId;
  final String? subjectId;
  final String? subjectName;
  final int role; // 1=ayudante, 2=estudiante, 3=recomendación
  final int? status; // 0=activo, 1=en progreso, 2=completado
  final int? capacity;
  final int? maxCapacity;
  final String? calendlyUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final User? user;
  final Subject? subject;

  Post({
    required this.id,
    required this.title,
    required this.content,
    this.contentPreview,
    this.userId,
    this.subjectId,
    this.subjectName,
    required this.role,
    this.status,
    this.capacity,
    this.maxCapacity,
    this.calendlyUrl,
    required this.createdAt,
    this.updatedAt,
    this.user,
    this.subject,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Manejar subject que puede venir como String o como Map
    Subject? subjectObj;
    if (json['subject'] != null) {
      if (json['subject'] is Map<String, dynamic>) {
        subjectObj =
            Subject.fromJson(json['subject'] as Map<String, dynamic>);
      } else if (json['subject'] is String) {
        // Si viene como String, crear un Subject mínimo con solo el nombre
        subjectObj = Subject(
          id: json['subjectId'] ?? '',
          name: json['subject'] as String,
          slug: '',
          careerId: '',
        );
      }
    }

    // Manejar usuario: puede venir anidado en 'user' o aplanado como 'author...'
    User? userObj;
    if (json['user'] != null) {
      userObj = User.fromJson(json['user'] as Map<String, dynamic>);
    } else if (json['authorId'] != null || json['author'] != null) {
      // Construir usuario desde campos aplanados
      userObj = User(
        id: json['authorId'] ?? json['userId'] ?? '',
        email: '', // No viene en el formato aplanado
        fullName: json['author'],
        avatarId: json['authorAvatarId'],
        profilePhotoUrl: json['authorProfilePhotoUrl'],
        career: json['authorCareer'],
        semester: 1, // Default
      );
    }

    // Manejar la fecha de creación (sin ternarios raros)
    DateTime createdAtDate;
    if (json['createdAt'] != null) {
      createdAtDate = DateTime.parse(json['createdAt']);
    } else if (json['createdAtUtc'] != null) {
      createdAtDate = DateTime.parse(json['createdAtUtc']);
    } else {
      createdAtDate = DateTime.now();
    }

    return Post(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? json['contentPreview'] ?? '',
      contentPreview: json['contentPreview'],
      userId: json['userId'] ?? json['authorId'] ?? '',
      subjectId: json['subjectId'],
      subjectName: json['subjectName'] ??
          (json['subject'] is String ? json['subject'] as String : null),
      role: json['role'] ?? 1,
      status: json['status'],
      capacity: json['capacity'],
      maxCapacity: json['maxCapacity'],
      calendlyUrl: json['calendlyUrl'] ?? json['calendly_url'],
      createdAt: createdAtDate,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      user: userObj,
      subject: subjectObj,
    );
  }

  String get roleText {
    switch (role) {
      case 1:
        return 'Ayudante';
      case 2:
        return 'Estudiante';
      case 3:
        return 'Comentario';
      default:
        return 'Desconocido';
    }
  }
}

class Reply {
  final String id;
  final String content;
  final String postId;
  final String userId;
  final DateTime createdAt;
  final User? user;

  Reply({
    required this.id,
    required this.content,
    required this.postId,
    required this.userId,
    required this.createdAt,
    this.user,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    // Manejar usuario: puede venir anidado en 'user' o aplanado como 'author...'
    User? userObj;
    if (json['user'] != null) {
      userObj = User.fromJson(json['user'] as Map<String, dynamic>);
    } else if (json['authorId'] != null || json['author'] != null) {
      // Construir usuario desde campos aplanados
      userObj = User(
        id: json['authorId'] ?? json['userId'] ?? '',
        email: '', // No viene en el formato aplanado
        fullName: json['author'],
        avatarId: json['authorAvatarId'],
        profilePhotoUrl: json['authorProfilePhotoUrl'],
        semester: 1, // Default
      );
    }

    // Manejar la fecha de creación
    DateTime createdAtDate;
    if (json['createdAt'] != null) {
      createdAtDate = DateTime.parse(json['createdAt']);
    } else if (json['createdAtUtc'] != null) {
      createdAtDate = DateTime.parse(json['createdAtUtc']);
    } else {
      createdAtDate = DateTime.now();
    }

    return Reply(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? json['authorId'] ?? '',
      createdAt: createdAtDate,
      user: userObj,
    );
  }
}

class FavoriteUserDto {
  final String id;
  final String fullName;
  final String? email;
  final String? profilePhotoUrl;
  final String? career;
  final int? semester;

  FavoriteUserDto({
    required this.id,
    required this.fullName,
    this.email,
    this.profilePhotoUrl,
    this.career,
    this.semester,
  });

  factory FavoriteUserDto.fromJson(Map<String, dynamic> json) {
    return FavoriteUserDto(
      id: json['id'] ?? json['userId'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      email: json['email'],
      profilePhotoUrl: json['profilePhotoUrl'] ?? json['profile_photo_url'],
      career: json['career'],
      semester: json['semester'],
    );
  }

  String get photoUrl {
    if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty) {
      return profilePhotoUrl!;
    }
    return '';
  }
}
