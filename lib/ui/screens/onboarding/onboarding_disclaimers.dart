import 'package:material_ui/material_ui.dart';
import 'package:page_transition/page_transition.dart';

import 'onboarding_analytics.dart';
import 'onboarding_welcome.dart';

class DisclaimersScreen extends StatelessWidget {
  const DisclaimersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Center(child: Text("免责声明")),
            // Don't show back button
            automaticallyImplyLeading: false),
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                            Container(
                                width: double.infinity,
                                // Make the box slightly bigger than the Text
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                    "本应用由一位开发者独立开发和维护，"
                                    "按\"现状\"提供，无任何"
                                    "明示或暗示的保证。开发者"
                                    "对因使用本应用而产生的任何问题、损害或"
                                    "损失概不负责。",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium)),
                            // this is padding around the entire widget
                            Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Container(
                                    width: double.infinity,
                                    // Make the box slightly bigger than the Text
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                        "本应用与任何外部平台均无关联、背书"
                                        "或隶属关系，无论通过内置插件还是用户安装的"
                                        "插件访问。"
                                        "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium))),
                            // this is padding around the entire widget
                            Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Container(
                                    width: double.infinity,
                                    // Make the box slightly bigger than the Text
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                        "本应用聚合来自外部提供方的内容，"
                                        "其中部分提供方可能有禁止抓取或自动访问的服务条款"
                                        "（TOS）。默认情况下，"
                                        "未经用户同意不会访问任何内容。"
                                        "用户有责任在启用相应插件前查看每个网站的服务条款，"
                                        "因为这些条款因国家和"
                                        "司法辖区而异。"
                                        "用户有责任"
                                        "确保遵守相关法律法规和服务条款。",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium))),
                          ]))),
                      Row(children: [
                        Align(
                            alignment: Alignment.bottomLeft,
                            child: ElevatedButton(
                                style: TextButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant),
                                onPressed: () => Navigator.push(
                                    context,
                                    PageTransition(
                                        settings: RouteSettings(
                                            name: "/onboarding_welcome"),
                                        type: PageTransitionType
                                            .leftToRightJoined,
                                        childCurrent: this,
                                        child: WelcomeScreen())),
                                child: Text("返回",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant)))),
                        Spacer(),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                                style: TextButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary),
                                onPressed: () => Navigator.push(
                                    context,
                                    PageTransition(
                                        settings: RouteSettings(
                                            name: "/onboarding_analytics"),
                                        type: PageTransitionType
                                            .rightToLeftJoined,
                                        childCurrent: this,
                                        child: AnalyticsScreen())),
                                child: Text("确认",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary))))
                      ])
                    ]))));
  }
}
