import 'package:json_annotation/json_annotation.dart';

class UtcDateTimeConverter implements JsonConverter<DateTime, String> {
  const UtcDateTimeConverter();
  @override
  DateTime fromJson(String value) {
    if (!RegExp(r'(?:[zZ]|[+-][0-9]{2}:[0-9]{2})$').hasMatch(value))
      throw const FormatException('Expected an instant with a timezone');
    return DateTime.parse(value).toUtc();
  }

  @override
  String toJson(DateTime value) => value.toUtc().toIso8601String();
}

class SecureUriConverter implements JsonConverter<Uri, String> {
  const SecureUriConverter();
  Uri _validate(Uri value) {
    if (value.scheme != 'https' ||
        value.host.isEmpty ||
        value.userInfo.isNotEmpty ||
        value.port != 443)
      throw const FormatException('Expected an HTTPS resource URL');
    return value;
  }

  @override
  Uri fromJson(String value) => _validate(Uri.parse(value));
  @override
  String toJson(Uri value) => _validate(value).toString();
}
