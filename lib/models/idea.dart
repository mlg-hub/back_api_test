import 'package:hive/hive.dart';
import 'package:mados_group/models/user.dart';
import 'package:uuid/uuid.dart';
part 'idea.g.dart';

@HiveType(typeId: 2)
class Idea {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  List<String>? tags;
  @HiveField(3)
  List<String> comments;
  @HiveField(4)
  int likesStatus;
  Idea({required this.id, required this.title})
      : likesStatus = 0,
        comments = [];

  Map toMap() {
    return {
      "title": title,
      "id": id,
      "comments": comments,
      "likesStatus": likesStatus,
      "tags": (tags ?? []).join(",")
    };
  }

  static Future<List<Map>> getIdeasFeed(int startIndex, int mycount) async {
    final Box<Idea> ideaBox = await Hive.openBox<Idea>("idea");

    return ideaBox.values.skip(startIndex).take(mycount).map((e) {
      return e.toMap();
    }).toList();
  }

  static Future<List<Map>> getIdea(String ref) async {
    final Box<Idea> ideaBox = await Hive.openBox<Idea>("idea");
    return ideaBox.values
        .where((idea) => idea.id == ref)
        .map((e) => e.toMap())
        .toList();
  }

  static Future<List<Map>> searchByTags(String queryTags) async {
    final Box<Idea> ideaBox = await Hive.openBox<Idea>("idea");
    return ideaBox.values
        .where((singleIdea) {
          if (singleIdea.tags != null) {
            ideaBox.close();
            print(singleIdea.tags);
            return singleIdea.tags!.map((e) => (e).trim()).contains(queryTags);
          } else {
            ideaBox.close();
            return false;
          }
        })
        .map((e) => e.toMap())
        .toList();
  }

  static Future<Map> commentIdea(int ideaIndex, String commentText) async {
    final Box<Idea> ideaBox = await Hive.openBox<Idea>("idea");
    try {
      final selectedIdea = ideaBox.getAt(ideaIndex);
      selectedIdea?.comments.add(commentText);
      ideaBox.close();
      return {"success": true};
    } catch (_) {
      ideaBox.close();
      return {"success": false};
    }
  }

  static Future<Map> likeIdea(int ideaIndex, int newlikeStatus) async {
    final Box<Idea> ideaBox = await Hive.openBox<Idea>("idea");
    try {
      final selectedIdea = ideaBox.getAt(ideaIndex);
      selectedIdea?.likesStatus = newlikeStatus;
      ideaBox.close();
      return {"success": true};
    } catch (_) {
      ideaBox.close();
      return {"success": false};
    }
  }

  static Future<Map> updateIdea(int ideaIndex,
      {String? newtitle, List<String>? newTags}) async {
    final Box<Idea> ideaBox = await Hive.openBox<Idea>("idea");
    try {
      final selectedIdea = ideaBox.getAt(ideaIndex);
      selectedIdea!.title = newtitle ?? selectedIdea.title;
      ideaBox.close();
      return {"sucess": true, "message": "The idea was successfully updated"};
    } catch (_) {
      ideaBox.close();
      return {"sucess": false, "message": "The idea was not updated"};
    }
  }

  static Future<Map<String, dynamic>> deleteIdea(int ideaIndex) async {
    final Box ideaBox = await Hive.openBox<Idea>("idea");
    try {
      ideaBox.deleteAt(ideaIndex);
      ideaBox.close();
      return {
        "success": true,
        "message": "The idea at index $ideaIndex was deleted"
      };
    } catch (_) {
      ideaBox.close();
      return {
        "success": false,
        "message": "The idea at index could not be deleted"
      };
    }
  }

  static Future<Map> createIdea(Map ideaInfos) async {
    final Box ideaBox = await Hive.openBox<Idea>("idea");
    final refIdea = Uuid().v1();
    final ideaModel = Idea(id: refIdea, title: ideaInfos["title"]);
    if (ideaModel.tags == null) {
      ideaModel.tags = [];
    }
    ideaModel.tags!.addAll(ideaInfos["tags"].split(","));

    ideaBox.add(ideaModel);
    final Box<User> userBox = await Hive.openBox<User>("user");
    final getTheuser = userBox.values
        .firstWhere((element) => element.username == ideaInfos["username"]);
    if (getTheuser.refIdeas == null) {
      getTheuser.refIdeas = [];
    }
    getTheuser.refIdeas!.add(refIdea);
    ideaBox.close();
    userBox.close();
    return ideaModel.toMap();
  }
}
