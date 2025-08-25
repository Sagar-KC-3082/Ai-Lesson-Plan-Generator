import 'package:dio/dio.dart';

/// @author: Sagar K.C.
/// @email: sagar.kc@fonepay.com
/// @created_at: 11/29/2023, Wednesday

class FailureResponse {
  final String errorMessage;
  final String? statusCode;
  final CustomExceptionType? exceptionType;

  FailureResponse(
    this.errorMessage, {
    this.statusCode,
    this.exceptionType,
  });

  static FailureResponse getErrorMessage(Object error) {
    try {
      if (error is DioException) {
        if (error.response?.statusCode == 401) {
          return FailureResponse(
            error.response?.data?["message"],
            statusCode: '401',
          );
        }
        if (error.type == DioExceptionType.connectionError) {
          return FailureResponse(
            'Connection Error',
            exceptionType: CustomExceptionType.connectionError,
          );
        } else if (error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionTimeout) {
          return FailureResponse(
            'Connection Timeout',
            exceptionType: CustomExceptionType.timeout,
          );
        } else if (error.response?.statusCode == 500) {
          return FailureResponse(
            'We faced some issue while processing the request',
            statusCode: '500',
          );
        } else if (error.response?.data is Map<String, dynamic> &&
            error.response?.data['message'] != null) {
          return FailureResponse(
            error.response?.data['message'] ?? '',
            exceptionType: CustomExceptionType.other,
            statusCode: error.response?.statusCode?.toString()
          );
        } else {
          return FailureResponse(
            'We faced some issue while processing the request',
            exceptionType: CustomExceptionType.other,
          );
        }
      } else {
        return FailureResponse(
          'We faced some issue while processing the request',
          exceptionType: CustomExceptionType.other,
        );
      }
    } catch (e) {
      return FailureResponse(
        'We faced some issue while processing the request',
        exceptionType: CustomExceptionType.other,
      );
    }
  }

/*  static FailureResponse getErrorMessage(Object error) {
    try {
      if (error is DioException) {
        if (error.type == DioExceptionType.connectionError) {
          return FailureResponse(
            tr('network_issue'),
            exceptionType: CustomExceptionType.connectionError,
          );
        }
        if (error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionTimeout) {
          return FailureResponse(
            tr('connection_timeout'),
            exceptionType: CustomExceptionType.timeout,
          );
        }
        if (error.response?.statusCode == 500) {
          return FailureResponse(
            tr('generic_error_message'),
            statusCode: '500',
          );
        }
        if (error.response != null &&
            error.response!.data != null &&
            error.response!.statusCode != null &&
            error.response!.statusCode! >= 400 &&
            error.response!.statusCode! < 500 &&
            error.response?.data is Map<String, dynamic>) {
          var message =
              (error.response!.data as Map<String, dynamic>)['error'] ==
                      "invalid_token"
                  ? tr('session_expired')
                  : (error.response!.data as Map<String, dynamic>)['message'];

          return FailureResponse(
            message ?? tr('generic_error_message'),
            statusCode: error.response?.statusCode?.toString(),
            captcha: _getCaptchaIfPresent(error),
            captchaToken: _getCaptchaTokenIfPresent(error),
          );
        }
        if (error.response != null &&
            (error.response!.data.toString().contains('PA') ||
                error.response!.data.toString().contains(
                      'OA',
                    ))) {
          return FailureResponse(
            error.message ?? tr('generic_error_message'),
            statusCode: error.response?.statusCode?.toString(),
          );
        }
      }

      return FailureResponse(tr('generic_error_message'));
    } catch (e) {
      return FailureResponse(tr('generic_error_message'));
    }
  }

  static _getCaptchaIfPresent(DioException error) {
    return (error.response!.data as Map<String, dynamic>).containsKey('captcha')
        ? (error.response!.data as Map<String, dynamic>)['captcha']
        : null;
  }

  static _getCaptchaTokenIfPresent(DioException error) {
    return (error.response!.data as Map<String, dynamic>)
            .containsKey('captchaToken')
        ? (error.response!.data as Map<String, dynamic>)['captchaToken']
        : null;
  }*/
}

enum CustomExceptionType {
  timeout,
  connectionError,
  invalidTransactionPin,
  transactionPinBlocked,
  badRequest,
  badResponse,
  other,
  userCancelled
}
