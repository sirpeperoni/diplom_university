import 'package:chat_app_diplom/email_api_key.dart';
import 'package:chat_app_diplom/entity/email_data.dart';
import 'package:dio/dio.dart';

class EmailRepository {
  final Dio _dio;

  EmailRepository(this._dio);

  Future<void> sendOtpCode(EmailData emailData) async {
    final response = await _dio.post(
      "https://go2.unisender.ru/ru/transactional/api/v1/email/send.json",
      data: emailData.toJson(),
      options: Options(headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': email_api_key
      }),
    );

    if (response.statusCode != 200) throw Exception('Email sending failed');
  }
}