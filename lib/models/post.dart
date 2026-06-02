class PostModel {
  final int idPost;
  final String content;
  final String? image;
  final int artisanId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? likesCount;
  final int? commentsCount;

  PostModel({
    required this.idPost,
    required this.content,
    this.image,
    required this.artisanId,
    required this.createdAt,
    required this.updatedAt,
    this.likesCount,
    this.commentsCount,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      idPost: json['ID'] ?? json['id'] ?? json['idPost'] ?? 0,
      content: json['Content'] ?? json['content'] ?? '',
      image: json['Image'] ?? json['image'],
      artisanId: json['ArtisanID'] ?? json['artisanId'] ?? json['artisan_id'] ?? 0,
      createdAt: DateTime.tryParse(json['CreatedAt'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['UpdatedAt'] ?? json['updatedAt'] ?? '') ?? DateTime.now(),
      likesCount: json['LikesCount'] ?? json['likesCount'] ?? json['likes_count'] ?? 0,
      commentsCount: json['CommentsCount'] ?? json['commentsCount'] ?? json['comments_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'image': image,
      'artisanId': artisanId,
    };
  }
}