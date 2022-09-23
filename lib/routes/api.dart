import 'package:mados_group/models/user.dart';

import '../models/idea.dart';

class Api {
  Future<Map?> register_user(Map map) async {
    final resp = await User.register(map);
    return resp;
  }

  Future<Map?> login_user(map) async {
    final resp = await User.login(map);
    return resp;
  }

  Future<Map?> logout_user() async {
    // TOdo:
  }

  Future<Map?> delete_idea(map) async {
    final resp = await Idea.deleteIdea(int.parse(map["index"] ?? "99999999"));
    return resp;
  }

  Future<Map?> like_idea(map) async {
    final resp = await Idea.likeIdea(
        int.parse(map["index"] ?? "9999999"), map["like_status"]);
    return resp;
  }

  Future<Map?> comment_idea(map) async {
    final resp = await Idea.commentIdea(
        int.parse(map["index"] ?? "9999999"), map["comment"]);
    return resp;
  }

  Future<List<Map>?> search_ideas(map) async {
    final resp = await Idea.searchByTags(map["tags"] ?? "");
    return resp;
  }

  Future<List<Map>> get_feed(map) async {
    final resp = await Idea.getIdeasFeed(
        int.parse(map["index_min"] ?? "0"), int.parse(map["count"] ?? "0"));
    return resp;
  }

  Future<Map?> update_profile(map) async {
    final resp = await Idea.updateIdea(map["user_index"],
        newTags: map["new_tags"], newtitle: map["new_title"]);
    return resp;
  }

  Future<Map?> post_ideas(map) async {
    final resp = await Idea.createIdea(map);
    return resp;
  }
}
