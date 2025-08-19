import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  // Environment-based configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL', 
    defaultValue: 'https://walaaudescntzrmmmjpk.supabase.co'
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndhbGFhdWRlc2NudHpybW1tanBrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ2NzcyNjYsImV4cCI6MjA3MDI1MzI2Nn0.FsQKbKofdiE5A0WH7YzTRVI9wR3lZUA-byOP6hYhiDQ'
  );

  // Initialize Supabase - call this in main()
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: false,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );
      
      print('Supabase initialized successfully');
    } catch (e, stackTrace) {
      print('Error initializing Supabase: $e');
      print(stackTrace);
      rethrow;
    }
  }

  // Get Supabase client
  SupabaseClient get client => Supabase.instance.client;
}
