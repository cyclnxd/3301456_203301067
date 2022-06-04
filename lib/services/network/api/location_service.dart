import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsocial/constants/api.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  final _dio = Dio();

  return LocationService(_dio);
});

class LocationService {
  final Dio _dio;
  LocationService(this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  Future<String> getGeocoding(
      {required String longitude, required String latitude}) async {
    Response response = await _dio.get(
      '/$longitude,$latitude.json',
      queryParameters: {
        "access_token": ApiConstants.accessToken,
        "limit": 1,
      },
    );

    return response.data["features"][0]["place_name"];
  }
}
