import 'package:dio/dio.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/models/yes_no_model.dart';

class YesNoException implements Exception {
  final String message;

  const YesNoException(this.message);

  @override
  String toString() => message;
}

class GetYesNoAnswer {
  GetYesNoAnswer({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = 'https://yesno.wtf'
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10)
      ..sendTimeout = const Duration(seconds: 10);
  }

  final Dio _dio;

  /// Consulta la API y devuelve la respuesta tal cual, con su imagen.
  ///
  /// Lanza [YesNoException] ante cualquier fallo de red o de formato,
  /// para que la capa de presentación nunca reciba una excepción cruda.
  Future<Message> getAnswer() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/api');
      final data = response.data;

      if (data == null) {
        throw const YesNoException('Bb farias no recibió respuesta.');
      }

      return YesNoModel.fromJsonMap(data).toMessageEntity();
    } on YesNoException {
      rethrow;
    } on DioException catch (e) {
      throw YesNoException(_describeDioError(e));
    } on FormatException catch (e) {
      throw YesNoException('La respuesta tiene un formato inesperado (${e.message}).');
    } catch (e) {
      throw YesNoException('Ocurrió un error inesperado al responder: $e');
    }
  }

  String _describeDioError(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'Bb farias está pensando... pero se acabó el tiempo de espera.',
        DioExceptionType.transformTimeout =>
          'La respuesta tardó demasiado en procesarse.',
        DioExceptionType.badCertificate =>
          'No se pudo verificar la seguridad de la conexión.',
        DioExceptionType.cancel => 'La petición fue cancelada.',
        DioExceptionType.connectionError =>
          'No hay conexión a internet, no pude responderte.',
        DioExceptionType.badResponse =>
          'El servidor respondió con error (${e.response?.statusCode}).',
        DioExceptionType.unknown => 'No pude conectarme para responderte.',
      };
}
