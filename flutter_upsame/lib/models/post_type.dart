// ==============================
// PostType Enum (para FAB y CreatePostPage)
// ==============================
enum PostType {
  helper,   // Ayudante
  student,  // Estudiante
  comment,  // Comentario 
}

extension PostTypeExtension on PostType {
  int get roleId {
    switch (this) {
      case PostType.helper:
        return 1;
      case PostType.student:
        return 2;
      case PostType.comment:
        return 3;
    }
  }

  String get displayName {
    switch (this) {
      case PostType.helper:
        return 'Ayudante';
      case PostType.student:
        return 'Estudiante';
      case PostType.comment:
        return 'Comentario';
    }
  }

  static PostType fromRoleId(int roleId) {
    switch (roleId) {
      case 1:
        return PostType.helper;
      case 2:
        return PostType.student;
      case 3:
        return PostType.comment;
      default:
        return PostType.student;
    }
  }
}
