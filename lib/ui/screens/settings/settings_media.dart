import 'package:material_ui/material_ui.dart';

import '/ui/widgets/options_dialog.dart';
import '/ui/widgets/options_switch.dart';
import '/utils/global_vars.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.primary),
          title: const Text("媒体"),
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    FutureBuilder<int?>(
                        future: sharedStorage
                            .getInt("media_preferred_video_quality"),
                        builder: (context, snapshot) {
                          return OptionsTile(
                              title: "默认分辨率",
                              subtitle: snapshot.data == null
                                  ? ""
                                  : "${snapshot.data}p",
                              options: const [
                                "144p",
                                "240p",
                                "360p",
                                "480p",
                                "720p",
                                "1080p",
                                "1440p",
                                "2160p"
                              ],
                              selectedOption: snapshot.data == null
                                  ? ""
                                  : "${snapshot.data}p",
                              onSelected: (value) async {
                                await sharedStorage.setInt(
                                    "media_preferred_video_quality",
                                    int.parse(
                                        value.substring(0, value.length - 1)));
                                setState(() {});
                              });
                        }),
                    FutureBuilder<int?>(
                        future: sharedStorage.getInt("media_seek_duration"),
                        builder: (context, snapshot) {
                          return OptionsTile(
                              title: "双击跳转时长",
                              subtitle: snapshot.data == null
                                  ? ""
                                  : "${snapshot.data} seconds",
                              options: const [
                                "5 seconds",
                                "10 seconds",
                                "15 seconds",
                                "20 seconds",
                                "25 seconds",
                                "30 seconds",
                                "60 seconds",
                                "120 seconds"
                              ],
                              selectedOption: snapshot.data == null
                                  ? ""
                                  : "${snapshot.data} seconds",
                              onSelected: (value) async {
                                await sharedStorage.setInt(
                                    "media_seek_duration",
                                    int.parse(
                                        value.substring(0, value.length - 8)));
                                setState(() {});
                              });
                        }),
                    FutureBuilder<bool?>(
                        future:
                            sharedStorage.getBool("media_start_in_fullscreen"),
                        builder: (context, snapshot) {
                          return OptionsSwitch(
                              title: "全屏启动",
                              subTitle: "始终以全屏播放视频",
                              switchState: snapshot.data ?? false,
                              onToggled: (value) => sharedStorage.setBool(
                                  "media_start_in_fullscreen", value));
                        }),
                    FutureBuilder<bool?>(
                        future: sharedStorage.getBool("media_auto_play"),
                        builder: (context, snapshot) {
                          return OptionsSwitch(
                              title: "自动播放",
                              subTitle:
                                  "视频加载后立即开始播放",
                              switchState: snapshot.data ?? false,
                              onToggled: (value) async => await sharedStorage
                                  .setBool("media_auto_play", value));
                        }),
                    FutureBuilder<bool?>(
                        future: sharedStorage
                            .getBool("media_show_progress_thumbnails"),
                        builder: (context, snapshot) {
                          return OptionsSwitch(
                              title: "显示视频进度缩略图",
                              subTitle:
                                  "在时间轴上方显示进度缩略图",
                              switchState: snapshot.data ?? true,
                              onToggled: (value) async =>
                                  await sharedStorage.setBool(
                                      "media_show_progress_thumbnails", value));
                        })
                  ],
                ))));
  }
}
