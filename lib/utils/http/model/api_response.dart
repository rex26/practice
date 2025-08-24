class ApiResponse {
  bool success;
  dynamic data;
  String? message;
  String? error;
  String? errorId;
  Map<String, dynamic>? meta;
  dynamic channels;
  Map<String, dynamic>? originalData;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.errorId,
    this.meta,
    this.channels,
    this.originalData,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'],
      message: json['message'] as String?,
      error: json['error'] as String?,
      errorId: json['error_id'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
      channels: json['channels'],
      originalData: json,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, data: $data, message: $message, error: $error, errorId: $errorId, meta: $meta}';
  }
}