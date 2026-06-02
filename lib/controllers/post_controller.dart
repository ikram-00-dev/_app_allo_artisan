// lib/controllers/post_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:allo_artisan_gpt/services/api_service.dart';
import '../models/post.dart';

class PostController extends GetxController {
  var isLoading = false.obs;
  var isCreating = false.obs;
  var posts = <PostModel>[].obs;

  // For new post
  var postContent = ''.obs;
  var postImage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchAllPosts();
  }

  // Fetch all posts for client home screen
  Future<void> fetchAllPosts() async {
    isLoading.value = true;
    try {
      final response = await ApiService.get('/posts');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        posts.value = data.map((json) => PostModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch posts by artisan (for private profile)
  Future<List<PostModel>> fetchArtisanPosts(int artisanId) async {
    try {
      final response = await ApiService.get('/artisans/$artisanId/posts');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => PostModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching artisan posts: $e');
    }
    return [];
  }

  // Create a new post
  Future<bool> createPost(String content, String? imageUrl) async {
    isCreating.value = true;
    try {
      final response = await ApiService.post('/posts', {
        'content': content,
        'image': imageUrl,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Refresh posts list
        await fetchAllPosts();
        return true;
      }
    } catch (e) {
      print('Error creating post: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de créer la publication',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreating.value = false;
    }
    return false;
  }

  // Update post
  Future<bool> updatePost(int postId, String content, String? imageUrl) async {
    try {
      final response = await ApiService.put('/posts/$postId', {
        'content': content,
        'image': imageUrl,
      });

      if (response.statusCode == 200) {
        await fetchAllPosts();
        return true;
      }
    } catch (e) {
      print('Error updating post: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de modifier la publication',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  // Delete post
  Future<bool> deletePost(int postId) async {
    try {
      final response = await ApiService.delete('/posts/$postId');
      if (response.statusCode == 200) {
        posts.removeWhere((post) => post.idPost == postId);
        return true;
      }
    } catch (e) {
      print('Error deleting post: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer la publication',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  // Like/unlike post
  Future<void> toggleLike(int postId) async {
    try {
      final response = await ApiService.post('/posts/$postId/like', {});
      if (response.statusCode == 200) {
        final index = posts.indexWhere((p) => p.idPost == postId);
        if (index != -1) {
          final currentLikes = posts[index].likesCount ?? 0;
          final isLiked = response.data['liked'] ?? false;
          posts[index] = PostModel(
            idPost: posts[index].idPost,
            content: posts[index].content,
            image: posts[index].image,
            artisanId: posts[index].artisanId,
            createdAt: posts[index].createdAt,
            updatedAt: posts[index].updatedAt,
            likesCount: isLiked ? currentLikes + 1 : currentLikes - 1,
            commentsCount: posts[index].commentsCount,
          );
        }
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  void clearNewPost() {
    postContent.value = '';
    postImage.value = null;
  }
}