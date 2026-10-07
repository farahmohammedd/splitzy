/// Paths to the bundled image assets in `assets/images/`.
///
/// Reference these constants instead of raw path strings so a renamed or
/// missing asset is caught in one place (see `app_images_test.dart`).
abstract final class AppImages {
  static const String splitzyIcon = 'assets/images/splitzy_icon.png';
  static const String splashFriends = 'assets/images/splash_friends.png';
  static const String loginFriends = 'assets/images/login_friends.png';

  static const List<String> all = [splitzyIcon, splashFriends, loginFriends];
}
