class LoginModel {
  final String identifier;
  final String password;
  final bool rememberMe;

  LoginModel({
    required this.identifier,
    required this.password,
    required this.rememberMe,
  });
}