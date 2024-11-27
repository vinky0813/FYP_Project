import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Accesstokencontroller extends GetxController {
  final _token = ''.obs;

  String? get token => _token.value;

  @override
  void onInit() {
    super.onInit();
    _initializeToken();
  }

  Future<void> _initializeToken() async {
    final session = Supabase.instance.client.auth.currentSession;
    _updateToken(session);

    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      _updateToken(event.session);
    });
  }

  void _updateToken(Session? session) {
    if (session != null) {
      _token.value = session.accessToken ?? '';
    } else {
      _token.value = '';
    }
  }
}