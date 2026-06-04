// lib/controllers/post_controller.dart
import 'package:get/get.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';

class PostController extends GetxController {
  var posts = <PostModel>[].obs;
  var isLoading = false.obs;
  var isCreating = false.obs;
  var postImage = Rxn<String>();

  // Track liked posts locally
  final Set<int> _likedPosts = {};

  // Use a simple map for like counts
  final Map<int, int> _localLikeCounts = {};

  @override
  void onInit() {
    super.onInit();
    fetchAllPosts();
  }

  Future<void> fetchAllPosts() async {
    try {
      isLoading.value = true;
      final response = await ApiService.getPosts();

      if (response is List) {
        posts.value = response.map((json) => PostModel.fromJson(json)).toList();
        debugPrint('✅ Loaded ${posts.length} posts');
      } else {
        posts.value = [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching posts: $e');
      posts.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createPost(String content, String? imageUrl) async {
    try {
      isCreating.value = true;
      isLoading.value = true;

      final data = {
        'content': content,
        'image': imageUrl ?? '',
      };

      final response = await ApiService.createPost(data);
      debugPrint('✅ Post created: $response');

      // Clear the post image after successful creation
      postImage.value = null;

      // Refresh posts list immediately
      await fetchAllPosts();

      return true;
    } catch (e) {
      debugPrint('❌ Error creating post: $e');
      return false;
    } finally {
      isCreating.value = false;
      isLoading.value = false;
    }
  }

  Future<bool> updatePost(int postId, String content, String? imageUrl) async {
    try {
      isLoading.value = true;

      final data = {
        'content': content,
        'image': imageUrl ?? '',
      };

      await ApiService.put('/posts/$postId', data);
      debugPrint('✅ Post updated');

      // Refresh posts list immediately
      await fetchAllPosts();

      return true;
    } catch (e) {
      debugPrint('❌ Error updating post: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deletePost(int postId) async {
    try {
      isLoading.value = true;

      await ApiService.delete('/posts/$postId');
      debugPrint('✅ Post deleted');

      // Remove from local list immediately
      posts.removeWhere((post) => post.idPost == postId);

      // Also remove from local tracking
      _likedPosts.remove(postId);
      _localLikeCounts.remove(postId);

      return true;
    } catch (e) {
      debugPrint('❌ Error deleting post: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleLike(int postId) {
    final index = posts.indexWhere((post) => post.idPost == postId);
    if (index != -1) {
      final post = posts[index];
      final currentLikes = post.likesCount ?? 0;

      final isLiked = _likedPosts.contains(postId);

      if (isLiked) {
        // Unlike
        _likedPosts.remove(postId);
        _localLikeCounts[postId] = currentLikes - 1;
      } else {
        // Like
        _likedPosts.add(postId);
        _localLikeCounts[postId] = currentLikes + 1;
      }

      // Update the post in the list
      final updatedPost = PostModel(
        idPost: post.idPost,
        artisanId: post.artisanId,
        content: post.content,
        image: post.image,
        likesCount: _localLikeCounts[postId] ?? currentLikes,
        commentsCount: post.commentsCount,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
      );

      posts[index] = updatedPost;

      // TODO: Send API request to like/unlike
      // await ApiService.likePost(postId);
    }
  }

  bool isPostLiked(int postId) {
    return _likedPosts.contains(postId);
  }

  int getLikesCount(int postId) {
    final index = posts.indexWhere((post) => post.idPost == postId);
    if (index != -1) {
      return posts[index].likesCount ?? 0;
    }
    return 0;
  }

  void setPostImage(String? imageUrl) {
    postImage.value = imageUrl;
  }

  void clearNewPost() {
    postImage.value = null;
  }
}