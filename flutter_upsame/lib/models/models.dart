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
        computedFullName = json['name'] ?? json['username'] ?? json['nombres'];
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
    );
  }

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    if (firstName != null && lastName != null) return '$firstName $lastName';
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
  final String userId;
  final String? subjectId;
  final int role; // 1=ayudante, 2=estudiante, 3=comentario
  final int? capacity;
  final int? maxCapacity;
  final String? calendlyUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final Subject? subject;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    this.subjectId,
    required this.role,
    this.capacity,
    this.maxCapacity,
    this.calendlyUrl,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.subject,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Manejar subject que puede venir como String o como Map
    Subject? subjectObj;
    if (json['subject'] != null) {
      if (json['subject'] is Map<String, dynamic>) {
        subjectObj = Subject.fromJson(json['subject']);
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
      userObj = User.fromJson(json['user']);
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

    return Post(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      userId: json['userId'] ?? json['authorId'] ?? '',
      subjectId: json['subjectId'],
      role: json['role'] ?? 1,
      capacity: json['capacity'],
      maxCapacity: json['maxCapacity'],
      calendlyUrl: json['calendlyUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['createdAtUtc'] != null 
              ? DateTime.parse(json['createdAtUtc']) 
              : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
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
      userObj = User.fromJson(json['user']);
    } else if (json['authorId'] != null || json['author'] != null) {
      // Construir usuario desde campos aplanados
      userObj = User(
        id: json['authorId'] ?? json['userId'] ?? '',
        email: '', // No viene en el formato aplanado
        fullName: json['author'],
        avatarId: json['authorAvatarId'], // Asumiendo que podría venir
        profilePhotoUrl: json['authorProfilePhotoUrl'], // Asumiendo que podría venir
        semester: 1, // Default
      );
    }

    return Reply(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? json['authorId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['createdAtUtc'] != null 
              ? DateTime.parse(json['createdAtUtc']) 
              : DateTime.now()),
      user: userObj,
    );
  }
}
