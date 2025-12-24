class PageResponse<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final bool last;
  final int size;
  final int number;

  PageResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.last,
    required this.size,
    required this.number,
  });

  factory PageResponse.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return PageResponse<T>(
      content: (json['content'] as List<dynamic>).map(fromJsonT).toList(),
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      last: json['last'] as bool,
      size: json['size'] as int,
      number: json['number'] as int,
    );
  }
}
