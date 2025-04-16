class EmailData {
  final String email;
  final String otp;

  const EmailData({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {
    "message": {
      "recipients": [{
        "email": email,
        "substitutions": {"to_name": "Dogechat", "otp_code": otp}
      }],
      "from_email": "noreply@dogechat.ru",
      "body": {
        "html": "<b>Добро пожаловать в {{to_name}}</b><p>Ваш код: <strong>{{otp_code}}</strong></p>",
        "plaintext": "Добро пожаловать в {{to_name}}",
        "amp": "<!doctype html><html amp4email><head> <meta charset=\"utf-8\"><script async src=\"https://cdn.ampproject.org/v0.js\"></script> <style amp4email-boilerplate>body{visibility:hidden}</style></head><body> Hello, AMP4EMAIL world.</body></html>"
      },
      "subject": "Добро пожаловать в Dogechat"
    }
  };
}