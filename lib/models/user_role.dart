enum UserRole { admin, cajero, cocinero }

UserRole userRoleFromString(String s) {
  switch (s.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'cajero':
      return UserRole.cajero;
    case 'cocinero':
      return UserRole.cocinero;
    default:
      return UserRole.cajero;
  }
}

String userRoleToString(UserRole r) {
  switch (r) {
    case UserRole.admin:
      return 'admin';
    case UserRole.cajero:
      return 'cajero';
    case UserRole.cocinero:
      return 'cocinero';
  }
}
