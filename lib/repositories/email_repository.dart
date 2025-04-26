import 'package:chat_app_diplom/entity/email_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailRepository {
  final Dio _dio;

  EmailRepository(this._dio);

  Future<void> sendOtpCode(EmailData emailData) async {
    final response = await _dio.post(
      "https://go2.unisender.ru/ru/transactional/api/v1/email/send.json",
      data: emailData.toJson(),
      options: Options(headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': dotenv.env['API_KEY_EMAIL']!
      }),
    );

    if (response.statusCode != 200) throw Exception('Email sending failed');
  }
}