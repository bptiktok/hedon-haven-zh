import 'package:material_ui/material_ui.dart';

import '/ui/widgets/options_dialog.dart';
import '/ui/widgets/options_switch.dart';
import '/utils/global_vars.dart';
import 'settings_launcher_appearance.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.primary),
          title: const Text("外观"),
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    ListTile(
                        trailing: Icon(Icons.arrow_forward),
                        title: const Text("启动器外观"),
                        subtitle: const Text(
                            "在启动器中隐藏应用图标和名称"),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                settings:
                                    RouteSettings(name: "/launcher_appearance"),
                                builder: (context) =>
                                    const LauncherAppearance()))),
                    FutureBuilder<String?>(
                      future: sharedStorage.getString("appearance_theme_mode"),
                      builder: (context, snapshot) {
                        return OptionsTile(
                          title: "主题",
                          subtitle: snapshot.data ?? "",
                          options: const [
                            "Follow device theme",
                            "Light theme",
                            "Dark theme"
                          ],
                          selectedOption: snapshot.data ?? "",
                          onSelected: (value) async {
                            await sharedStorage.setString(
                                "appearance_theme_mode", value);
                            globalSetState();
                            setState(() {});
                          },
                        );
                      },
                    ),
                    FutureBuilder<String?>(
                        future: sharedStorage.getString("appearance_list_view"),
                        builder: (context, snapshot) {
                          return OptionsTile(
                              // TODO: Add visualization of the list modes
                              title: "列表视图模式",
                              subtitle: snapshot.data ?? "",
                              options: const ["Card", "Grid", "List"],
                              selectedOption: snapshot.data ?? "",
                              onSelected: (value) async {
                                await sharedStorage.setString(
                                    "appearance_list_view", value);
                                setState(() {});
                              });
                        }),
                    FutureBuilder<bool?>(
                        future:
                            sharedStorage.getBool("appearance_play_previews"),
                        builder: (context, snapshot) {
                          return OptionsSwitch(
                              title: "播放预览",
                              subTitle:
                                  "在首页/结果页播放预览",
                              switchState: snapshot.data ?? true,
                              onToggled: (value) async => await sharedStorage
                                  .setBool("appearance_play_previews", value));
                        }),
                    FutureBuilder<bool?>(
                        future: sharedStorage
                            .getBool("appearance_homepage_enabled"),
                        builder: (context, snapshot) {
                          return OptionsSwitch(
                              title: "启用首页",
                              subTitle: "应用启动时加载首页",
                              switchState: snapshot.data ?? true,
                              onToggled: (value) async {
                                await sharedStorage.setBool(
                                    "appearance_homepage_enabled", value);
                                reloadVideoListEvent.add(null);
                              });
                        })
                  ],
                ))));
  }
}
