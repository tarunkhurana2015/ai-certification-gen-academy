import 'package:flutter/foundation.dart';

@immutable
class PlaidInstitution {
  final String id;
  final String name;
  final List<String> products;
  final List<String> countryCodes;
  final String? url;
  final String? primaryColor;
  final String? logo;
  final bool oauth;
  final List<String> routingNumbers;
  final List<String> dtcNumbers;
  final String connectionAvailability;

  const PlaidInstitution({
    required this.id,
    required this.name,
    this.products = const [],
    this.countryCodes = const ['US'],
    this.url,
    this.primaryColor,
    this.logo,
    this.oauth = false,
    this.routingNumbers = const [],
    this.dtcNumbers = const [],
    this.connectionAvailability = 'SUPPORTED',
  });

  factory PlaidInstitution.fromJson(Map<String, dynamic> json) {
    return PlaidInstitution(
      id: json['institution_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      countryCodes: (json['country_codes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['US'],
      url: json['url']?.toString(),
      primaryColor: json['primary_color']?.toString(),
      logo: json['logo']?.toString(),
      oauth: json['oauth'] == true,
      routingNumbers: (json['routing_numbers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      dtcNumbers: (json['dtc_numbers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      connectionAvailability:
          json['connection_availability']?.toString() ?? 'SUPPORTED',
    );
  }

  Map<String, dynamic> toJson() => {
        'institution_id': id,
        'name': name,
        'products': products,
        'country_codes': countryCodes,
        if (url != null) 'url': url,
        if (primaryColor != null) 'primary_color': primaryColor,
        if (logo != null) 'logo': logo,
        'oauth': oauth,
        'routing_numbers': routingNumbers,
        'dtc_numbers': dtcNumbers,
        'connection_availability': connectionAvailability,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaidInstitution &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PlaidInstitution(id: $id, name: $name)';
}

@immutable
class PlaidInstitutionsResponse {
  final List<PlaidInstitution> institutions;
  final int total;
  final String requestId;

  const PlaidInstitutionsResponse({
    this.institutions = const [],
    this.total = 0,
    this.requestId = '',
  });

  factory PlaidInstitutionsResponse.fromJson(Map<String, dynamic> json) {
    final rawList = (json['institutions'] as List<dynamic>?) ?? [];
    return PlaidInstitutionsResponse(
      institutions: rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => PlaidInstitution.fromJson(item))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      requestId: json['request_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'institutions': institutions.map((i) => i.toJson()).toList(),
        'total': total,
        'request_id': requestId,
      };

  @override
  String toString() =>
      'PlaidInstitutionsResponse(total: $total, institutions: ${institutions.length}, requestId: $requestId)';
}
