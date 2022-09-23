import 'package:hive/hive.dart';
import 'package:mados_group/models/idea.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String username;
  @HiveField(2)
  String fullName;
  @HiveField(3)
  List<Idea>? ideas;
  @HiveField(4)
  List<String>? refIdeas;
  @HiveField(5)
  String? password;
  @HiveField(6)
  String? telephone;
  @HiveField(7)
  String? address;

  User(
      {required this.id,
      required this.username,
      required this.fullName,
      this.password,
      this.refIdeas,
      this.address,
      this.telephone});

  Future<Map> toMap() async {
    return {
      "username": username,
      "id": id,
      "pwd": password,
      "ideas": (refIdeas ?? []).map((e) async => await Idea.getIdea(e)).toList()
    };
  }

  static Future<Map> updateUser(int userIndex,
      {String? newtelephone,
      String? newaddress,
      String? newfullName,
      String? newpassword}) async {
    final Box userBox = await Hive.openBox<User>('user');
    final User selectedUser = userBox.getAt(userIndex);
    selectedUser.telephone = newtelephone ?? selectedUser.telephone;
    selectedUser.password = newpassword ?? selectedUser.password;
    selectedUser.address = newaddress ?? selectedUser.address;
    selectedUser.fullName = newfullName ?? selectedUser.fullName;
    userBox.close();
    return selectedUser.toMap();
  }

  // Register a user
  static Future<Map?> register(Map registerInfos) async {
    final Box userBox = await Hive.openBox<User>("user");
    try {
      final userModel = User(
        id: Uuid().v1(),
        username: registerInfos["username"],
        fullName: registerInfos["full_name"],
        telephone: registerInfos["telephone"],
        password: registerInfos["password"],
        address: registerInfos["address"],
      );
      userBox.add(userModel);
      return userModel.toMap();
    } catch (e) {
      print(e.toString());
    }
    userBox.close();
    return null;
  }

  // login a user
  static Future<Map?> login(Map loginInfos) async {
    final Box<User> userBox = await Hive.openBox<User>("user");
    final rightUser = userBox.values.firstWhere(
        (element) =>
            element.password == loginInfos["password"] &&
            loginInfos["username"] == element.username,
        orElse: () => User(
            id: "0",
            password: "no found",
            fullName: "not fount",
            username: "not found"));
    if (rightUser.id == "0") {
      return null;
    }
    return rightUser.toMap();
  }
  // TODO: logout user

}
