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
                      return GestureDetector(
                          child: ListTile(
                        title: Text("Group ID: ${_groupIds[index]}"),
                        onTap: () {
                          Get.to(
                              () => ChatPage(
                                    groupId: _groupIds[index],
                                  ),
                              transition: Transition.circularReveal,
                              duration: const Duration(seconds: 1));
                        },
                      ));
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
