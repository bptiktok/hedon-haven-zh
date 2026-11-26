import 'package:material_ui/material_ui.dart';

import '/services/database_manager.dart';
import '/ui/utils/toast_notification.dart';
import '/ui/widgets/options_switch.dart';
import '/utils/global_vars.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.primary),
          title: const Text("历史记录"),
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    FutureBuilder<bool?>(
                        future: sharedStorage.getBool("history_watch"),
                        builder: (context, snapshot) {
                          return OptionsSwitch(
                              title: "启用观看历史",
                              subTitle: "记录已观看的视频",
                              switchState: snapshot.data ?? true,
                              onToggled: (value) => sharedStorage.setBool(
                                  "history_watch", value));
                        }),
                    ListTile(
                        trailing: const Icon(Icons.clear),
                        title: const Text("清除观看历史"),
                        onTap: () {
                          deleteAllFrom("watch_history");
                          showToast("观看历史已清除", context);
                        }),
                    FutureBuilder<bool?>(
                        future: sharedStorage.getBool("history_search"),
                        builder: (context, snapshot) {
                          return OptionsSwitch(
                              title: "启用搜索历史",
                              subTitle: "记录搜索查询",
                              switchState: snapshot.data ?? true,
                              onToggled: (value) async => await sharedStorage
                                  .setBool("history_search", value));
                        }),
                    ListTile(
                        trailing: const Icon(Icons.clear),
                        title: const Text("清除搜索历史"),
                        onTap: () {
                          deleteAllFrom("search_history");
                          showToast("搜索历史已清除", context);
                        }),
                    ListTile(
                        trailing: const Icon(Icons.clear),
                        title: const Text("删除所有收藏"),
                        onTap: () {
                          deleteAllFrom("favorites");
                          showToast("所有收藏已删除", context);
                        }),
                  ],
                ))));
  }
}
