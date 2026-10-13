/// Route paths of the app. Navigate with these constants, never raw strings.
abstract final class AppRoutes {
  static const String launch = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String groups = '/groups';
  static const String activity = '/activity';
  static const String profile = '/profile';
  static const String newGroup = '/new-group';
  static const String addExpense = '/add-expense';

  /// Add Expense with the group [groupId] chosen at first.
  static String addExpenseTo(String groupId) =>
      Uri(path: addExpense, queryParameters: {'group': groupId}).toString();

  /// The route pattern of a group's page; open one with [groupDetails].
  static const String groupDetailsPattern = '/group/:groupId';

  /// The page of the group [groupId].
  static String groupDetails(String groupId) =>
      '/group/${Uri.encodeComponent(groupId)}';
}
