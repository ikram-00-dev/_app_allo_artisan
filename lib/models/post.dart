import 'artisan.dart';

class PostModel {
  final int idPost;
  final String content;
  final String approvalStatus;
  final DateTime createdAt;
  final String image;
  final int artisanId;
  final Artisan? artisan;

  PostModel({
    required this.idPost,
    required this.content,
    required this.approvalStatus,
    required this.createdAt,
    required this.image,
    required this.artisanId,
    this.artisan,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      idPost: json['id_post'] ?? json['IDPost'] ?? 0,
      content: json['content'] ?? '',
      approvalStatus: json['approval_status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      image: json['image'] ?? '',
      artisanId: json['artisan_id'] ?? 0,
      artisan: json['artisan'] != null ? Artisan.fromJson(json['artisan']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'image': image,
    };
  }

  bool get isApproved => approvalStatus == 'approved';
  bool get isPending => approvalStatus == 'pending';

  PostModel copyWith({
    String? content,
    String? approvalStatus,
    String? image,
  }) {
    return PostModel(
      idPost: idPost,
      content: content ?? this.content,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      createdAt: createdAt,
      image: image ?? this.image,
      artisanId: artisanId,
      artisan: artisan,
    );
  }
}