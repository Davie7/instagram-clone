import '../barrel/export.dart';
import '/models/user.dart' as model;

class UserProvider with ChangeNotifier {
  model.User _user = const model.User(
    username: 'null',
    uid: 'null',
    photoUrl: 'null',
    email: 'null',
    bio: 'null',
    followers: [],
    following: [],
  );
  final AuthMethods _authMethods = AuthMethods();

  model.User? get getUser => _user;

  Future<void> refreshUser() async {
    model.User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
