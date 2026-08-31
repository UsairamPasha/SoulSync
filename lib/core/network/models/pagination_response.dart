import 'package:flutter/foundation.dart';

@immutable
class PaginationResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginationResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory PaginationResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    final list = (json['items'] as List<dynamic>? ?? [])
        .map((item) => fromJsonT(item))
        .toList();
    final total = json['total'] as int? ?? list.length;
    final page = json['page'] as int? ?? 1;
    final pageSize = json['pageSize'] as int? ?? 20;

    return PaginationResponse<T>(
      items: list,
      total: total,
      page: page,
      pageSize: pageSize,
      hasMore: json['hasMore'] as bool? ?? (page * pageSize < total),
    );
  }
}
