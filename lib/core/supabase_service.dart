import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/package.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  // Authentication
  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  static User? get currentUser => client.auth.currentUser;

  // Profile
  static Future<OperatorProfile?> getProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    return OperatorProfile(
      id: response['id'] as String,
      name: response['name'] as String,
      zone: response['zone'] as String? ?? 'N/A',
      vehicle: response['vehicle'] as String? ?? 'N/A',
      role: response['role'] as String == 'dispatcher'
          ? UserRole.dispatcher
          : UserRole.courier,
    );
  }

  // Packages
  static Future<List<DeliveryPackage>> getPackages({int limit = 20, int offset = 0}) async {
    final response = await client.from('packages')
        .select()
        .range(offset, offset + limit - 1)
        .order('id', ascending: true); // Assuming ordering by id, you can change this to created_at if exists

    return (response as List).map((p) => DeliveryPackage(
      id: p['id'] as String,
      recipient: p['recipient'] as String,
      address: p['address'] as String,
      status: _parseStatus(p['status'] as String),
      priority: p['priority'] as String,
      eta: p['eta'] as String,
      confidence: p['confidence'] as int,
      cluster: p['cluster'] as String,
      phone: p['phone'] as String?,
    )).toList();
  }
  
  static Future<void> createPackage(Map<String, dynamic> data) async {
    await client.from('packages').insert(data);
  }

  static Future<void> updatePackageStatus(String id, String status) async {
    await client.from('packages').update({'status': status}).eq('id', id);
  }

  static Future<bool> deletePackage(String id) async {
    try {
      final response = await client.from('packages').delete().eq('id', id).select();
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('Delete error: $e');
      return false;
    }
  }

  static Future<void> updatePackage(String id, Map<String, dynamic> data) async {
    await client.from('packages').update(data).eq('id', id);
  }

  static Future<String?> uploadPodImage(String packageId, String filePath) async {
    try {
      final fileName = '$packageId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);
      
      await client.storage.from('pod_images').upload(
        fileName,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      
      return client.storage.from('pod_images').getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }

  static PackageStatus _parseStatus(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'pending':
        return PackageStatus.pending;
      case 'clarification':
        return PackageStatus.clarification;
      case 'delivered':
        return PackageStatus.delivered;
      default:
        return PackageStatus.pending;
    }
  }

  // Chat Messages
  static Stream<List<ChatMessage>> getChatMessages(String packageId) {
    return client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('package_id', packageId)
        .order('time', ascending: true)
        .map((list) => list.map((msg) => ChatMessage(
              sender: msg['sender'] as String,
              text: msg['text'] as String,
              time: msg['time'] as String,
            )).toList());
  }
}
