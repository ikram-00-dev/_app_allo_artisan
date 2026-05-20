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
      idPost: json['IDPost'] ?? json['idPost'] ?? 0,
      content: json['Content'] ?? json['content'] ?? '',
      approvalStatus: json['ApprovalStatus'] ?? json['approvalStatus'] ?? 'pending',
      createdAt: DateTime.tryParse(json['CreatedAt'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      image: json['Image'] ?? json['image'] ?? '',
      artisanId: json['ArtisanID'] ?? json['artisanId'] ?? 0,
      artisan: json['Artisan'] != null ? Artisan.fromJson(json['Artisan']) : null,
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