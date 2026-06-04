// lib/routes/app_routes.dart
class AppRoutes {
  static const splash = "/";
  static const login = "/login";
  static const registerClient = "/register-client";
  static const registerArtisan = "/register-artisan";
  static const clientHome = "/client-home";
  static const String clientRequests = '/client-requests';   // ← NEW
  static const artisanHome = "/artisan-home";
  static const artisanPrivateProfile = "/artisan-private-profile"; // ADD THIS
  static const artisanProfile = "/artisan-profile";
  static const profile = "/profile";
  static const messages = "/messages";
  static const notifications = "/notifications";
  static const search = "/search";
  static const reservations = "/reservations";
  static const settings = "/settings";
  static const qrScan = "/qr-scan";
  static const String clientPublicProfile = '/client-public-profile';
  static const adminPanel = "/admin-panel";           // ← NEW
  static const pendingArtisans = "/pending-artisans"; // ← NEW
  static const addModerator = "/add-moderator";       // ← NEW
  static const chat = "/chat";                    // ← ADD THIS
  // Helper method to get login route with redirect
  static String getLoginWithRedirect(String redirectRoute) {
    return '$login?redirect=$redirectRoute';
  }
}