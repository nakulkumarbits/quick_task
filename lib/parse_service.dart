import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ParseService {
  static Future<void> initializeParse() async {
    const String appId = 'dfez78WbtKBIoJxDdPqiAS1JKK4DpV4qYQO4kMwB';
    const String clientKey = 'ZNB1bxCVb4RUSd05x1nIEW4hmllBoAsDwBJ3aAXZ';
    const String serverUrl = 'https://parseapi.back4app.com/';

    await Parse().initialize(appId, serverUrl,
        clientKey: clientKey, autoSendSessionId: true);
  }
}
