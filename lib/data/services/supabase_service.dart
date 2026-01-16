import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io' as java_io;
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_service.dart';
import '../models/user_profile.dart';
import '../models/tip_model.dart';
import '../models/hama_model.dart';
import '../models/video_model.dart';
import '../models/forum_post_model.dart';
import '../models/forum_comment_model.dart';
import '../models/calendar_event_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  // --- Auth ---
  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String nama,
    required String username,
    required String kota,
    required String noHp,
    required String provinsi,
    required String kecamatan,
    required String jenisTanaman,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'nama': nama,
        'username': username,
        'kabupaten': kota, // Map to DB column
        'telepon': noHp,
        'provinsi': provinsi,
        'kecamatan': kecamatan,
        'jenis_tanaman': jenisTanaman,
        'full_name': nama, // Redundant fallback
      },
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> updatePassword(String newPassword) async {
    await client.auth.updateUser(UserAttributes(password: newPassword));
  }

  // --- Data Fetching ---

  Future<UserProfile?> getUserProfile() async {
    const cacheKey = 'cached_user_profile';
    final user = currentUser;
    if (user == null) return null;

    try {
      final data = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) return null;

      // Cache data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(data));

      return UserProfile.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      // Load cache on error
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(cacheKey);
        if (cached != null) {
          final data = jsonDecode(cached);
          // Verify if cached ID matches current user to avoid showing wrong profile
          if (data['id'] == user.id) {
            return UserProfile.fromJson(data);
          }
        }
      } catch (_) {}
      return null;
    }
  }

  Future<List<Tip>> getTips() async {
    const cacheKey = 'cached_tips';
    try {
      final response = await client
          .from('tips')
          .select()
          .order('created_at', ascending: false);
      final data = response as List;

      // Cache data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(data));

      return data.map((e) => Tip.fromJson(e)).toList();
    } catch (e) {
      // Load cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(cacheKey);
        if (cached != null) {
          final data = jsonDecode(cached) as List;
          return data.map((e) => Tip.fromJson(e)).toList();
        }
      } catch (_) {}
      debugPrint('Error fetching tips: $e');
      return [];
    }
  }

  Future<List<Hama>> getHama() async {
    const cacheKey = 'cached_hama';
    try {
      debugPrint("DEBUG: Fetching Hama from 'hama_penyakit'...");
      final response = await client
          .from('hama_penyakit') // Corrected table name
          .select()
          .order('created_at', ascending: false);

      debugPrint("DEBUG: Hama response length: ${(response as List).length}");
      final data = response as List;

      // Cache data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(data));

      return data.map((e) => Hama.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching hama: $e');
      // Load cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(cacheKey);
        if (cached != null) {
          final data = jsonDecode(cached) as List;
          return data.map((e) => Hama.fromJson(e)).toList();
        }
      } catch (_) {}
      return [];
    }
  }

  Future<List<Video>> getVideos() async {
    const cacheKey = 'cached_videos';
    try {
      final response = await client
          .from('videos')
          .select()
          .order('created_at', ascending: false);
      final data = response as List;

      // Cache data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(data));

      return data.map((e) => Video.fromJson(e)).toList();
    } catch (e) {
      // Load cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(cacheKey);
        if (cached != null) {
          final data = jsonDecode(cached) as List;
          return data.map((e) => Video.fromJson(e)).toList();
        }
      } catch (_) {}
      debugPrint('Error fetching videos: $e');
      return [];
    }
  }

  // --- Forum ---

  Future<List<ForumPost>> getForumPosts({bool useCache = true}) async {
    const cacheKey = 'cached_forum';

    try {
      debugPrint("DEBUG: Fetching Forum Posts...");
      final response = await client
          .from('forum_posts')
          .select(
              '*, profiles!forum_posts_user_id_fkey(nama, avatar_url, kabupaten, provinsi)')
          .order('created_at', ascending: false);

      final data = response as List;

      // Update cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(data));

      return data.map((e) => ForumPost.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching forum posts: $e");

      if (!useCache)
        rethrow; // Let caller handle error (e.g. show Offline message)

      // Load from cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(cacheKey);
        if (cached != null) {
          final data = jsonDecode(cached) as List;
          return data.map((e) => ForumPost.fromJson(e)).toList();
        }
      } catch (_) {}
      return [];
    }
  }

  Future<void> createForumPost(String title, String content, String category,
      {String? imageUrl}) async {
    final user = currentUser;
    if (user == null) throw Exception("User not logged in");

    await client.from('forum_posts').insert({
      'user_id': user.id,
      'title': title,
      'content': content,
      'category': category,
      'image_url': imageUrl,
      'likes_count': 0,
    });
  }

  Future<void> deleteForumPost(int postId) async {
    final user = currentUser;
    if (user == null) throw Exception("User not logged in");

    try {
      // 1. Get image_url first
      final response = await client
          .from('forum_posts')
          .select('image_url')
          .eq('id', postId)
          .eq('user_id', user.id)
          .single();

      final imageUrl = response['image_url'] as String?;

      // 2. Delete from Storage if exists
      if (imageUrl != null) {
        // Parse filename from URL usually: .../forum_images/userId/filename.ext
        // Url format: .../storage/v1/object/public/forum_images/USER_ID/FILENAME
        // We need path: USER_ID/FILENAME
        try {
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          // pathSegments usually: [storage, v1, object, public, forum_images, userId, filename]
          // We want everything after 'forum_images'
          final bucketIndex = pathSegments.indexOf('forum_images');
          if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
            final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');
            debugPrint("DEBUG: Deleting image at $storagePath");
            await client.storage.from('forum_images').remove([storagePath]);
          }
        } catch (e) {
          debugPrint("Error parsing/deleting image: $e");
          // Continue to delete post even if image delete fails
        }
      }

      // 3. Delete Post
      await client
          .from('forum_posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', user.id);
    } catch (e) {
      debugPrint("Error deleting post: $e");
      rethrow;
    }
  }

  Future<String?> uploadForumImage(java_io.File file) async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final fileExt = file.path.split('.').last;
      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      debugPrint("DEBUG: Uploading $fileName to forum_images...");

      // Upload to 'forum_images' bucket
      await client.storage.from('forum_images').upload(fileName, file);

      // Get Public URL
      final imageUrl =
          client.storage.from('forum_images').getPublicUrl(fileName);
      debugPrint("DEBUG: Upload success. URL: $imageUrl");
      return imageUrl;
    } catch (e) {
      debugPrint("Error uploading image: $e");
      rethrow; // Rethrow to let UI handle it
    }
  }

  // --- Forum Comments ---

  Future<List<ForumComment>> getForumComments(int postId) async {
    try {
      final response = await client
          .from('forum_comments')
          .select('*, profiles(nama, avatar_url)')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      final data = response as List;
      return data.map((e) => ForumComment.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching comments: $e");
      return [];
    }
  }

  Future<void> addForumComment(int postId, String content) async {
    final user = currentUser;
    if (user == null) throw Exception("User not logged in");

    await client.from('forum_comments').insert({
      'post_id': postId,
      'user_id': user.id,
      'content': content,
    });

    // Optional: Manually increment comment count if not handled by trigger
    // But usually we rely on triggers or just fetch count again.
  }

  // --- Forum Likes ---

  Future<bool> hasLikedPost(int postId) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      // Use limit(1) to be safe even if duplicates exist
      final data = await client
          .from('forum_likes')
          .select()
          .eq('user_id', user.id)
          .eq('post_id', postId)
          .limit(1)
          .maybeSingle();
      return data != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleLikePost(int postId) async {
    final user = currentUser;
    if (user == null) return;

    // debugPrint("DEBUG: Toggling like for Post $postId"); // Cleaned up
    final hasLiked = await hasLikedPost(postId);

    try {
      if (hasLiked) {
        // Unlike
        await client
            .from('forum_likes')
            .delete()
            .eq('user_id', user.id)
            .eq('post_id', postId);

        // No manual RPC needed - Trigger handles it
      } else {
        // Like
        await client.from('forum_likes').insert({
          'user_id': user.id,
          'post_id': postId,
        });
        // No manual RPC needed
      }
    } catch (e) {
      debugPrint("ERROR Toggling Like: $e");
      rethrow;
    }
  }

  // --- Calendar ---

  Future<List<CalendarEvent>> getCalendarEvents() async {
    const cacheKey = 'cached_calendar';
    try {
      final user = currentUser;
      if (user == null) return [];

      final response = await client
          .from('calendar_events')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: true);

      final data = response as List;

      // Cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(data));

      return data.map((e) => CalendarEvent.fromJson(e)).toList();
    } catch (e) {
      // Load cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(cacheKey);
        if (cached != null) {
          final data = jsonDecode(cached) as List;
          return data.map((e) => CalendarEvent.fromJson(e)).toList();
        }
      } catch (_) {}
      return [];
    }
  }

  Future<void> createCalendarEvent({
    required String title,
    required DateTime date,
    required String type,
    String? notes,
    TimeOfDay? notificationTime,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception("User not logged in");

    // Append Time Tag to notes to persist time even if DB is date-only
    final timeTag =
        "[TIME:${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}]";
    final notesToSave = notes == null ? timeTag : "$notes $timeTag";

    // Insert and get ID
    final data = await client
        .from('calendar_events')
        .insert({
          'user_id': user.id,
          'title': title,
          'date': date.toIso8601String(),
          'type': type,
          'notes': notesToSave,
          'completed': false,
        })
        .select()
        .single();

    // Schedule Notification
    // Schedule Notification
    try {
      final prefs = await SharedPreferences.getInstance();

      // Strict check: If global notifications are disabled, DO NOT schedule anything.
      final globalEnabled = prefs.getBool('notifications_enabled') ?? false;

      if (!globalEnabled) {
        debugPrint(
            "DEBUG: Notifications disabled globally. Skipping schedule.");
        return;
      }

      // If enabled, proceed
      bool shouldSchedule = notificationTime != null;
      TimeOfDay targetTime =
          notificationTime ?? const TimeOfDay(hour: 7, minute: 0);

      if (notificationTime == null) {
        // Use default preference time
        shouldSchedule = true;
        final hour = prefs.getInt('notif_hour') ?? 7;
        final minute = prefs.getInt('notif_minute') ?? 0;
        targetTime = TimeOfDay(hour: hour, minute: minute);
      }

      if (shouldSchedule) {
        final id = data['id'] as int;
        // Improved Notification Content
        await NotificationService().scheduleDailyNotification(
          id: id,
          title: "Pengingat Jadwal Tani 🌱",
          body:
              "Saatnya melakukan kegiatan '$type' - $title. Semangat bertani!",
          date: date,
          time: targetTime,
        );
      }
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  Future<void> deleteCalendarEvent(int id) async {
    // Cancel notification first
    try {
      await NotificationService().cancelType(id);
    } catch (_) {}

    await client.from('calendar_events').delete().eq('id', id);
  }

  Future<void> updateCalendarEvent({
    required int id,
    required String title,
    required String type,
    String? notes,
    // Add date for rescheduling if needed, currently UI might not allow date edit easily or uses create for new dates
  }) async {
    final user = currentUser;
    if (user == null) throw Exception("User not logged in");

    await client.from('calendar_events').update({
      'title': title,
      'type': type,
      'notes': notes,
    }).eq('id', id);

    // Note: If we supported date update, we should reschedule here.
    // For now assuming date is constant or user deletes and creates new.
  }

  // --- Bookmarks ---

  Future<void> toggleBookmark(int itemId, String itemType) async {
    final user = currentUser;
    if (user == null) return;

    final isBookmarked = await _isBookmarked(itemId, itemType);

    if (isBookmarked) {
      await client
          .from('user_bookmarks')
          .delete()
          .eq('user_id', user.id)
          .eq('item_id', itemId)
          .eq('item_type', itemType);
    } else {
      await client.from('user_bookmarks').insert({
        'user_id': user.id,
        'item_id': itemId,
        'item_type': itemType,
      });
    }
  }

  Future<bool> _isBookmarked(int itemId, String itemType) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final response = await client
          .from('user_bookmarks')
          .select()
          .eq('user_id', user.id)
          .eq('item_id', itemId)
          .eq('item_type', itemType)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isItemBookmarked(int itemId, String itemType) async {
    return _isBookmarked(itemId, itemType);
  }

  Future<Map<String, List<dynamic>>> getSavedItems() async {
    final user = currentUser;
    if (user == null) return {'tips': [], 'videos': [], 'hama': []};

    try {
      final response =
          await client.from('user_bookmarks').select().eq('user_id', user.id);

      final bookmarks = response as List;

      final List<int> tipIds = [];
      final List<int> videoIds = [];
      final List<int> hamaIds = [];

      for (var b in bookmarks) {
        if (b['item_type'] == 'tip') tipIds.add(b['item_id']);
        if (b['item_type'] == 'video') videoIds.add(b['item_id']);
        if (b['item_type'] == 'hama') hamaIds.add(b['item_id']);
      }

      final List<Tip> tips = [];
      if (tipIds.isNotEmpty) {
        final res = await client
            .from('tips')
            .select()
            .filter('id', 'in', tipIds); // Fixed in_ to filter
        tips.addAll((res as List).map((e) => Tip.fromJson(e)));
      }

      final List<Video> videos = [];
      if (videoIds.isNotEmpty) {
        final res = await client
            .from('videos')
            .select()
            .filter('id', 'in', videoIds); // Fixed in_ to filter
        videos.addAll((res as List).map((e) => Video.fromJson(e)));
      }

      final List<Hama> hama = [];
      if (hamaIds.isNotEmpty) {
        final res = await client
            .from('hama_penyakit')
            .select()
            .filter('id', 'in', hamaIds); // Fixed in_ to filter
        hama.addAll((res as List).map((e) => Hama.fromJson(e)));
      }

      return {
        'tips': tips,
        'videos': videos,
        'hama': hama,
      };
    } catch (e) {
      print("Error fetching saved items: $e");
      return {'tips': [], 'videos': [], 'hama': []};
    }
  }

  // --- Profile Update ---
  Future<void> updateUserProfile({
    required String nama,
    required String kota,
    String? noHp,
    String? provinsi,
    String? kecamatan,
    String? jenisTanaman,
  }) async {
    print("DEBUG: Updating Profile for $nama (No Alamat)");
    final user = currentUser;
    if (user == null) return;

    final updates = {
      'nama': nama,
      // 'kota': kota, // Removed: Database only uses 'kabupaten'
      'kabupaten': kota, // Maps UI 'kota' to DB 'kabupaten'
      'telepon': noHp, // Maps UI 'noHp' to DB 'telepon'
      'provinsi': provinsi,
      'kecamatan': kecamatan,
      'jenis_tanaman': jenisTanaman,
    };

    await client.from('profiles').update(updates).eq('id', user.id);
  }
}
