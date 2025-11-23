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
  final String? profilePhotoUrl;
  final String careerId;
  final String? career;
  final int semester;
  final String? phone;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.avatarUrl,
    this.profilePhotoUrl,
    required this.careerId,
    this.career,
    required this.semester,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      fullName: json['fullName'],
      avatarUrl: json['avatarUrl'],
      profilePhotoUrl: json['profilePhotoUrl'],
      careerId: json['careerId'] ?? '',
      career: json['career'],
      semester: json['semester'] ?? 1,
      phone: json['phone'],
    );
  }

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    if (firstName != null && lastName != null) return '$firstName $lastName';
    return email;
  }

  String get photoUrl {
    if (profilePhotoUrl != null) return profilePhotoUrl!;
    if (avatarUrl != null) return avatarUrl!;
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

    return Post(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      userId: json['userId'] ?? '',
      subjectId: json['subjectId'],
      role: json['role'] ?? 1,
      capacity: json['capacity'],
      maxCapacity: json['maxCapacity'],
      calendlyUrl: json['calendlyUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
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
    return Reply(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
