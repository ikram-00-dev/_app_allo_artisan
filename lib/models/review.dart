class Review {
  final int idReview;
  final String comment;
  final DateTime createdAt;
  final int ratingScore;
  final int clientId;
  final int artisanId;
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? artisan;

  Review({
    required this.idReview,
    required this.comment,
    required this.createdAt,
    required this.ratingScore,
    required this.clientId,
    required this.artisanId,
    this.client,
    this.artisan,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      idReview: json['id_review'] ?? json['IDReview'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      ratingScore: json['rating_score'] ?? 0,
      clientId: json['client_id'] ?? 0,
      artisanId: json['artisan_id'] ?? 0,
      client: json['client'],
      artisan: json['artisan'],
    );
  }

  String get clientName => client?['username'] ?? 'Client';
}