import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:secure_app_switcher/secure_app_switcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '/ui/utils/toast_notification.dart';
import '/ui/widgets/alert_dialog.dart';
import '/ui/widgets/options_switch.dart';
import '/utils/global_vars.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.primary),
          title: const Text("隐私"),
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                    child: Column(
                  children: <Widget>[
                    FutureBuilder<bool?>(
                        future:
                            sharedStorage.getBool("privacy_hide_app_preview"),
                        builder: (context, snapshot) {
                          return OptionsSwitch(
                              title: "隐藏应用预览",
                              subTitle: "在多任务切换器中隐藏应用预览",
                              switchState: snapshot.data ?? true,
                              onToggled: (value) async {
                                await sharedStorage.setBool(
                                    "privacy_hide_app_preview", value);
                                // Force an immediate update
                                if (Platform.isAndroid || Platform.isIOS) {
                                  if (!value) {
                                    SecureAppSwitcher.off();
                                  } else {
                                    SecureAppSwitcher.on();
                                  }
                                }
                                // the hidePreview var is from main.dart
                                setState(() => hidePreview = value);
                              });
                        }),
                    FutureBuilder<bool?>(
                        future: sharedStorage
                            .getBool("privacy_keyboard_incognito_mode"),
                        builder: (context, snapshot) {
                          return OptionsSwitch(
                              title: "启用键盘无痕模式",
                              subTitle:
                                  "指示键盘应用启用无痕模式（例如关闭自动建议、不学习新词等）",
                              switchState: snapshot.data ?? true,
                              onToggled: (value) async =>
                                  await sharedStorage.setBool(
                                      "privacy_keyboard_incognito_mode",
                                      value));
                        }),
                    FutureBuilder<bool?>(
                        future: sharedStorage
                            .getBool("privacy_show_external_link_warning"),
                        builder: (context, snapshot) {
                          return OptionsSwitch(
                              title: "显示外部链接警告",
                              subTitle:
                                  "在默认浏览器中打开外部链接时显示警告",
                              switchState: snapshot.data ?? true,
                              onToggled: (value) async =>
                                  await sharedStorage.setBool(
                                      "privacy_show_external_link_warning",
                                      value));
                        }),
                    ListTile(
                        trailing: Icon(Icons.arrow_forward),
                        title: const Text("代理设置"),
                        subtitle:
                            const Text("启用/禁用代理，选择代理"),
                        onTap: () {
                          showToast("代理支持尚未完全实现",
                              context);
                          return;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  settings:
                                      RouteSettings(name: "/settings_proxy"),
                                  builder: (context) => const ProxyScreen()));
                        }),
                    ...buildAnalyticsOptions()
                  ],
                )))));
  }
}

List<Widget> buildAnalyticsOptions({bool reduceBorders = false}) {
  return [
    FutureBuilder<bool?>(
        future: sharedStorage.getBool("analytics_enable_usage_ping"),
        builder: (context, snapshot) {
          String description = "在应用启动时发送一个小型匿名 ping，"
              "包含应用信息"
              "（版本、构建、安装来源）"
              "和系统信息"
              "（类型、版本、架构）。"
              "用于估算用户数量和平台"
              "分布情况。"
              "\nRead more: https://docs.hedon-haven.top/analytics.md";
          return OptionsSwitch(
              title: "启用使用统计 ping",
              subTitle: "启动时发送匿名 ping",
              maxSubTitleLines: 2,
              trailingWidget: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => ThemedDialog(
                          title: "匿名 Ping",
                          primaryText: "确定",
                          onPrimary: () => Navigator.pop(context),
                          content: GestureDetector(
                              onTap: () => launchUrl(Uri.parse(
                                  "https://docs.hedon-haven.top/analytics.md")),
                              child: Text(description,
                                  style:
                                      Theme.of(context).textTheme.bodyLarge)),
                        )),
              ),
              switchState: snapshot.data ?? false,
              reduceBorders: reduceBorders,
              onToggled: (value) =>
                  sharedStorage.setBool("analytics_enable_usage_ping", value));
        }),
    FutureBuilder<bool?>(
        future: sharedStorage.getBool("analytics_enable_automatic_bug_reports"),
        builder: (context, snapshot) {
          String description = "自动提交匿名"
              "错误报告（在生成时自动提交）。其中包含"
              "应用信息（版本、构建、"
              "安装来源）、系统信息"
              "（类型、版本、架构）以及错误消息、"
              "堆栈跟踪、屏幕路径、插件名称和"
              "调试信息。\n第三方插件的错误报告将"
              "不会被自动提交。"
              "\nRead more: https://docs.hedon-haven.top/analytics.md";
          return OptionsSwitch(
              title: "启用自动错误报告",
              subTitle: "自动提交匿名错误报告",
              maxSubTitleLines: 2,
              trailingWidget: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => ThemedDialog(
                          title: "匿名 Ping",
                          primaryText: "确定",
                          onPrimary: () => Navigator.pop(context),
                          content: GestureDetector(
                              onTap: () => launchUrl(Uri.parse(
                                  "https://docs.hedon-haven.top/analytics.md")),
                              child: Text(description,
                                  style:
                                      Theme.of(context).textTheme.bodyLarge)),
                        )),
              ),
              switchState: snapshot.data ?? false,
              reduceBorders: reduceBorders,
              onToggled: (value) => sharedStorage.setBool(
                  "analytics_enable_automatic_bug_reports", value));
        })
  ];
}

class ProxyScreen extends StatefulWidget {
  const ProxyScreen({super.key});

  @override
  State<ProxyScreen> createState() => _ProxyScreenState();
}

class _ProxyScreenState extends State<ProxyScreen> {
  void setCustomProxy(String proxy) async {
    TextEditingController textController = TextEditingController(text: proxy);

    String? newValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return ThemedDialog(
            title: "设置自定义代理服务器（ip:端口）",
            primaryText: "应用",
            onPrimary: () => Navigator.of(context).pop(textController.text),
            secondaryText: "取消",
            onSecondary: () => Navigator.of(context).pop(null),
            content: TextField(
                controller: textController,
                decoration:
                    InputDecoration(hintText: "e.g. 256.256.256.256:8080")));
      },
    );

    if (newValue != null) {
      await sharedStorage.setString("privacy_proxy_address", newValue);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.primary),
          title: const Text("隐私"),
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: FutureBuilder<bool?>(
                    future: sharedStorage.getBool("privacy_proxy_enabled"),
                    builder: (context, proxyEnabled) {
                      return SingleChildScrollView(
                          child: Column(children: <Widget>[
                        OptionsSwitch(
                            title: "启用代理",
                            subTitle: "强制所有网络请求经过"
                                "代理",
                            switchState: proxyEnabled.data ?? false,
                            onToggled: (value) async {
                              await sharedStorage.setBool(
                                  "privacy_proxy_enabled", value);
                              setState(() {});
                            }),
                        FutureBuilder<String?>(
                            future: sharedStorage
                                .getString("privacy_proxy_address"),
                            builder: (context, snapshot) {
                              return ListTile(
                                enabled: proxyEnabled.data ?? false,
                                title: Text("当前代理服务器"),
                                subtitle: Text(snapshot.data?.isEmpty ?? true
                                    ? "未设置"
                                    : snapshot.data!),
                                trailing: Icon(Icons.edit),
                                onTap: () => setCustomProxy(snapshot.data!),
                              );
                            }),
                        ListTile(
                            enabled: proxyEnabled.data ?? false,
                            trailing: const Icon(Icons.bolt),
                            title: const Text("查找最快代理"),
                            onTap: () {
                              showToast("尚未实现", context);
                            }),
                        ListTile(
                            enabled: proxyEnabled.data ?? false,
                            trailing: const Icon(Icons.shuffle),
                            title: const Text("随机查找代理"),
                            onTap: () {
                              showToast("尚未实现", context);
                            })
                      ]));
                    }))));
  }
}
