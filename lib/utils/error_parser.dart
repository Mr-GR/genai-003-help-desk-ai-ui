String parseErrorMessage(dynamic responseBody) {
  if (responseBody is List && responseBody.isNotEmpty) {
    return responseBody
        .map((e) => e["msg"] ?? "")
        .whereType<String>()
        .join('\n');
  }

  if (responseBody is Map && responseBody.containsKey("detail")) {
    final detail = responseBody["detail"];
    if (detail is String) return detail;
    if (detail is List) {
      return detail
          .map((e) => e["msg"] ?? "")
          .whereType<String>()
          .join('\n');
    }
  }

  return "Something went wrong. Please try again.";
}
