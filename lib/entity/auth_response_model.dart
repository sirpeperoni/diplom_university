class AuthResponseModel {
  final bool isSuccessful;
  final String? errorMessage;
  final String? uid;
  final String? email;

  AuthResponseModel({
    required this.isSuccessful,
    this.errorMessage,
    this.uid,
    this.email,
  });
}