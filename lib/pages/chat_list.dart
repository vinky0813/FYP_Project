import 'package:flutter/material.dart';
import 'package:fyp_project/pages/chat_page.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<String> _groupIds = [];
  String? userId;
  List<String?> chatThumbnailUrl = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      userId = user.id;
      await _loadGroupIds();
      await _loadChatPictures();
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadChatPictures() async {
    try {
      for (String groupId in _groupIds) {
        final response = await Supabase.instance.client
            .from('Group_Members')
            .select('user_id')
            .eq('group_id', groupId)
            .limit(1)
            .single();

        if (response != null) {
          String firstUserId = response['user_id'];

          final profileResponse = await Supabase.instance.client
              .from('profiles')
              .select('avatar_url')
              .eq('id', firstUserId)
              .single();

          if (profileResponse != null) {
            String? avatarUrl = profileResponse['avatar_url']?.trim();
            chatThumbnailUrl.add(avatarUrl);
          }
        }
      }
    } catch (error) {
      print('Error fetching user IDs or avatar URLs: $error');
    }
  }

  Future<void> _loadGroupIds() async {
    try{
      final response = await Supabase.instance.client
          .from('Group_Members')
          .select('group_id')
          .eq('user_id', userId!);

      setState(() {
        _groupIds = List<String>.from(response.map((item) => item['group_id']));
      });

    }catch (error) {
      print('Error fetching group IDs: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: appBar(),
      body: _groupIds.isEmpty
          ? Center(child: Text("No Chatrooms"))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "Chat",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                    child: SizedBox(
                  height: 16,
                )),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            backgroundImage: chatThumbnailUrl[index] != null
                                ? NetworkImage(chatThumbnailUrl[index]!)
                                : null,
                            child: chatThumbnailUrl[index] == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text("Group ID: ${_groupIds[index]}"),
                          trailing: const Icon(Icons.chat),
                          onTap: () {
                            Get.to(
                                  () => ChatPage(
                                groupId: _groupIds[index],
                              ),
                              transition: Transition.circularReveal,
                              duration: const Duration(seconds: 1),
                            );
                          },
                        ),
                      );
                    },
                    childCount: _groupIds.length,
                  ),
                ),
              ],
            ),
    );
  }

  AppBar appBar() {
    return AppBar(
      // App bar title
      title: const Text(
        "INTI Accommodation Finder",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }
}
