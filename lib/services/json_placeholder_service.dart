import 'package:dio/dio.dart';
import 'package:practice/constants/api_constants.dart';
import 'package:practice/models/json_placeholder_models.dart';
import 'package:practice/utils/http/api/network_manager.dart';
import 'package:practice/utils/http/model/api_response.dart';

class JsonPlaceholderService {
  /// Get all posts
  static Future<List<Post>> getPosts({CancelToken? cancelToken}) async {
    final ApiResponse response = await NetworkManager.request(
      url: APIConstants.posts,
      method: HttpMethod.get,
      cancelToken: cancelToken,
    );
    return (response.data as List)
        .map((json) => Post.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get all comments
  static Future<List<Comment>> getComments({CancelToken? cancelToken}) async {
    final ApiResponse response = await NetworkManager.request(
      url: APIConstants.comments,
      method: HttpMethod.get,
      cancelToken: cancelToken,
    );
    return (response.data as List)
        .map((json) => Comment.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get all albums
  static Future<List<Album>> getAlbums({CancelToken? cancelToken}) async {
    final ApiResponse response = await NetworkManager.request(
      url: APIConstants.albums,
      method: HttpMethod.get,
      cancelToken: cancelToken,
    );
    return (response.data as List)
        .map((json) => Album.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get all photos
  static Future<List<Photo>> getPhotos({CancelToken? cancelToken}) async {
    final ApiResponse response = await NetworkManager.request(
      url: APIConstants.photos,
      method: HttpMethod.get,
      cancelToken: cancelToken,
    );
    return (response.data as List)
        .map((json) => Photo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get all todos
  static Future<List<Todo>> getTodos({CancelToken? cancelToken}) async {
    final ApiResponse response = await NetworkManager.request(
      url: APIConstants.todos,
      method: HttpMethod.get,
      cancelToken: cancelToken,
    );
    return (response.data as List)
        .map((json) => Todo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get all users
  static Future<List<User>> getUsers({CancelToken? cancelToken}) async {
    final ApiResponse response = await NetworkManager.request(
      url: APIConstants.users,
      method: HttpMethod.get,
      cancelToken: cancelToken,
    );
    return (response.data as List)
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
