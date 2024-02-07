/// Holder for paged data
class Paged<T> {
  /// Number of page
  int pageNumber;

  /// Size of a page
  int pageSize;

  /// Total number of pages
  int totalPages;

  /// Total number of items
  int totalCount;

  /// List of items on page
  List<T> data;

  /// Number of items on page, can be less than [pageSize] on last page
  int dataSize;

  /// Whether this is the first page
  bool isFirst;

  /// Whether this is the last page
  bool isLast;

  Paged({
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalCount,
    int? dataSize,
    bool? isFirst,
    bool? isLast,
    required this.data,
  })  : dataSize = dataSize ?? data.length,
        isFirst = isFirst ?? pageNumber == 1,
        isLast = isLast ?? pageNumber == totalPages;

  factory Paged.fromJson(Map<String, dynamic> json) {
    return Paged(
      pageSize: json['page_size'] as int,
      pageNumber: json['page_number'] as int,
      totalPages: json['total_pages'] as int,
      totalCount: json['total_count'] as int,
      dataSize: json['data_size'] as int,
      data: (json['data'] as List).map((e) => e as T).toList(),
      isFirst: json['is_first'] as bool?,
      isLast: json['is_last'] as bool?,
    );
  }

  @override
  String toString() {
    return 'Paged{pageNumber: $pageNumber, pageSize: $pageSize, totalPages: $totalPages, totalCount: $totalCount, data: $data, dataSize: $dataSize, isFirst: $isFirst, isLast: $isLast}';
  }
}
