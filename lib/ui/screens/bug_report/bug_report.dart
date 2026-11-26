import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hedon_haven/utils/exceptions.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '/services/analytics_manager.dart' as analytics;
import '/services/bug_report_manager.dart';
import '/services/plugin_manager.dart';
import '/ui/utils/toast_notification.dart';
import '/ui/widgets/alert_dialog.dart';
import '/utils/global_vars.dart';
import '/utils/plugin_interface/plugin_interface.dart';
import 'bug_reports_list.dart';

class BugReportScreen extends StatefulWidget {
  final List<BugReport> bugReportsList;
  final SubmissionType submissionType;
  final bool unexpectedError;

  const BugReportScreen(
      {super.key,
      required this.bugReportsList,
      required this.submissionType,
      bool? unexpectedError})
      : unexpectedError = unexpectedError ?? false;

  @override
  State<BugReportScreen> createState() => _BugReportScreenState();
}

class _BugReportScreenState extends State<BugReportScreen>
    with WidgetsBindingObserver {
  TextEditingController appInfoController = TextEditingController();
  TextEditingController userInputController = TextEditingController();
  bool allowPop = false;
  late List<BugReport> bugReportsList;
  List<BugReport> submittedBugReports = [];

  Completer<void>? _appResumedCompleter;

  late ({
    List<BugReport>? appReports,
    Map<String, List<BugReport>>? bundledPluginGroups,
    Map<String, List<BugReport>>? thirdPartyPluginGroups
  }) groupedBugReports;

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // Remove all CustomException BugReports
    bugReportsList = widget.bugReportsList
        .where((report) => report.error is! CustomException)
        .toList();
    groupedBugReports = groupBugReports(bugReportsList);
    if (bugReportsList.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showEmptyWarning();
      });
    }
    if (widget.unexpectedError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showUnexpectedErrorWarning();
      });
    }
    appInfoController.text = getAppAndDeviceInfo()
        .entries
        .map((e) => "${e.key}: ${e.value}")
        .join("\n")
        .trim();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _appResumedCompleter?.complete();
    }
  }

  void showEmptyWarning() {
    showDialog(
        context: context,
        builder: (BuildContext context) => ThemedDialog(
            title: "创建空的错误报告？",
            primaryText: "继续",
            onPrimary: () => Navigator.of(context).pop(),
            secondaryText: "取消报告",
            onSecondary: () {
              // Close dialog
              Navigator.of(context).pop();
              // Go back a screen
              Navigator.of(context).pop(<BugReport>[]);
            },
            content: const Text(
                "长按应用内任意内容可创建更具体的"
                "错误报告。\n\n"
                "如果您想提交建议，请忽略此消息。")));
  }

  void showUnexpectedErrorWarning() {
    showDialog(
        context: context,
        builder: (BuildContext context) => ThemedDialog(
            title: "发生了意外错误",
            primaryText: "继续",
            onPrimary: () => Navigator.of(context).pop(),
            secondaryText: "取消报告",
            onSecondary: () {
              // Close dialog
              Navigator.of(context).pop();
              // Go back a screen
              Navigator.of(context).pop(<BugReport>[]);
            },
            content: const Text(
                "应用内发生了意外错误。请提交"
                "此错误报告以帮助我们修复。查看"
                "「应用错误报告」部分了解更多详情。")));
  }

  void handlePop(bool goingToPop) {
    if (!goingToPop) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return ThemedDialog(
              title: "取消错误报告？",
              primaryText: "留在当前页",
              onPrimary: () => Navigator.of(context).pop(),
              secondaryText: "取消错误报告",
              onSecondary: () {
                allowPop = true;
                // close popup
                Navigator.of(context).pop();
                // Go back a screen
                Navigator.of(context).pop(<BugReport>[]);
              },
            );
          });
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  String combinedReport({bool includeThirdParty = false}) {
    return JsonEncoder.withIndent("  ")
        .convert(combinedReportMap(includeThirdParty: includeThirdParty));
  }

  Map<String, dynamic> combinedReportMap({bool includeThirdParty = false}) {
    return {
      "appInfo": getAppAndDeviceInfo(),
      "userMessage": userInputController.text,
      "submissionType": widget.submissionType,
      "bugReports": {
        if (groupedBugReports.appReports?.isNotEmpty ?? false)
          "appReports": groupedBugReports.appReports,
        if (groupedBugReports.bundledPluginGroups?.isNotEmpty ?? false)
          "bundledPluginBugReports": groupedBugReports
              .bundledPluginGroups?.values
              .expand((e) => e)
              .toList(),
        if (includeThirdParty &&
            (groupedBugReports.thirdPartyPluginGroups?.isNotEmpty ?? false))
          "thirdPartyPluginBugReports": groupedBugReports
              .thirdPartyPluginGroups?.values
              .expand((e) => e)
              .toList(),
      }
    };
  }

  Future<void> copyCombinedReport() async {
    await Clipboard.setData(
        ClipboardData(text: combinedReport(includeThirdParty: true)));
    showToast("已将完整错误报告以 JSON 形式复制到剪贴板", context);
  }

  void showRawDialog() async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ThemedDialog(
            title: "JSON 格式的错误报告",
            primaryText: "关闭",
            onPrimary: () => Navigator.pop(context),
            secondaryText: "复制",
            onSecondary: () => copyCombinedReport(),
            content: SingleChildScrollView(
                child: Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: SelectableText(
                        combinedReport(includeThirdParty: true),
                        style: Theme.of(context).textTheme.bodyMedium),
                  )
                ]))));
  }

  Future<bool> showSubmitOptionsDialog() async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) => ThemedDialog(
            title: "提交给 Hedon Haven 开发者",
            primaryText: "取消",
            onPrimary: () => Navigator.pop(context, false),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                title: Text("匿名提交"),
                subtitle: Text("https://eu.posthog.com"),
                leading: Icon(Icons.person_off),
                onTap: () async {
                  bool submitted =
                      await analytics.submitBugReport(combinedReportMap());
                  if (context.mounted) Navigator.pop(context, submitted);
                },
              ),
              ListTile(
                title: Text("通过电子邮件提交"),
                subtitle: Text("contact@hedon-haven.top"),
                leading: Icon(Icons.email),
                onTap: () async {
                  _appResumedCompleter = Completer<void>();
                  bool submittedReport = await launchUrl(Uri(
                      scheme: "mailto",
                      path: "contact@hedon-haven.top",
                      query: _encodeQueryParameters(<String, String>{
                        "subject": "错误报告",
                        "body": combinedReport()
                      })));
                  if (submittedReport) {
                    // wait for user to return
                    await _appResumedCompleter!.future;
                    _appResumedCompleter = null;
                  }
                  if (context.mounted) Navigator.pop(context, submittedReport);
                },
              ),
              ListTile(
                title: Text("在问题追踪器中创建议题"),
                subtitle: Text("https://issues.hedon-haven.top"),
                leading: Icon(Icons.bug_report),
                onTap: () async {
                  await copyCombinedReport();
                  _appResumedCompleter = Completer<void>();
                  bool submittedReport = await launchUrl(
                      Uri.parse("https://issues.hedon-haven.top"));
                  if (submittedReport) {
                    // wait for user to return
                    await _appResumedCompleter!.future;
                    _appResumedCompleter = null;
                  }
                  if (context.mounted) Navigator.pop(context, submittedReport);
                },
              )
            ])));
  }

  Future<bool> showThirdPartySubmitOptionsDialog(
      List<BugReport> bugReports) async {
    // Get Plugin from the first bug report
    String pluginCodeName =
        (bugReports.first as PluginBugReport).pluginCodeName;
    PluginInterface? plugin =
        await PluginManager.getPluginByCodeName(pluginCodeName);
    if (plugin == null && mounted) {
      await showDialog(
          context: context,
          builder: (BuildContext context) => ThemedDialog(
              title: "未找到插件",
              primaryText: "确定",
              onPrimary: () => Navigator.pop(context, false),
              content: Text("找不到代号为"
                  " $pluginCodeName 的第三方插件，它可能"
                  "已卸载，无法提交错误报告！")));
      return false;
    }
    return await showDialog(
        context: context,
        builder: (BuildContext context) => ThemedDialog(
            title: "提交给第三方开发者",
            primaryText: "取消",
            onPrimary: () => Navigator.pop(context, false),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("Submit ${bugReports.length} "
                  "${bugReports.length == 1 ? "bug report" : "bug reports"} "
                  "提交给 ${plugin!.prettyName} "
                  "developer ${plugin.developer}:"),
              const SizedBox(height: 10),
              ListTile(
                title: Text("通过电子邮件提交"),
                subtitle: Text(plugin.contactEmail ?? "未提供邮箱"),
                leading: Icon(Icons.email),
                onTap: () async {
                  if (plugin.contactEmail == null) {
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) => ThemedDialog(
                            title: "无联系邮箱",
                            primaryText: "确定",
                            onPrimary: () => Navigator.pop(context),
                            content: Text(""
                                "${plugin.prettyName} 未提供联系"
                                "邮箱。${plugin.issueTrackerUrl == null ? "" : " 请改通过问题追踪器提交错误报告。"}")));
                    return;
                  }
                  _appResumedCompleter = Completer<void>();
                  bool submittedReport = await launchUrl(Uri(
                      scheme: "mailto",
                      path: plugin.contactEmail,
                      query: _encodeQueryParameters(<String, String>{
                        "subject": "${plugin.prettyName} Hedon Haven "
                            "插件错误报告",
                        "body": combinedReport(includeThirdParty: true)
                      })));
                  if (submittedReport) {
                    // wait for user to return
                    await _appResumedCompleter!.future;
                    _appResumedCompleter = null;
                  }
                  if (context.mounted) Navigator.pop(context, submittedReport);
                },
              ),
              ListTile(
                title: Text("在第三方追踪器中创建议题"),
                subtitle: Text(plugin.issueTrackerUrl ?? "未提供网址"),
                leading: Icon(Icons.bug_report),
                onTap: () async {
                  if (plugin.issueTrackerUrl == null) {
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) => ThemedDialog(
                            title: "无问题追踪器",
                            primaryText: "确定",
                            onPrimary: () => Navigator.pop(context),
                            content: Text(""
                                "${plugin.prettyName} 未提供问题"
                                "追踪器网址。${plugin.contactEmail == null ? "" : " 请改通过电子邮件提交错误报告。"}")));
                    return;
                  }
                  await copyCombinedReport();
                  _appResumedCompleter = Completer<void>();
                  bool submittedReport =
                      await launchUrl(Uri.parse(plugin.issueTrackerUrl!));
                  if (submittedReport) {
                    // wait for user to return
                    await _appResumedCompleter!.future;
                    _appResumedCompleter = null;
                  }
                  if (context.mounted) Navigator.pop(context, submittedReport);
                },
              )
            ])));
  }

  void submitReports() async {
    if ((groupedBugReports.appReports?.isNotEmpty ?? false) ||
        (groupedBugReports.bundledPluginGroups?.isNotEmpty ?? false)) {
      if (await showSubmitOptionsDialog()) {
        submittedBugReports.addAll(groupedBugReports.appReports ?? []);
        submittedBugReports.addAll(groupedBugReports.bundledPluginGroups?.values
                .expand((x) => x)
                .toList() ??
            []);
        // Remove submitted reports from UI
        setState(() => groupedBugReports = (
              appReports: [],
              bundledPluginGroups: {},
              thirdPartyPluginGroups: groupedBugReports.thirdPartyPluginGroups
            ));
      }
    }

    if (groupedBugReports.thirdPartyPluginGroups?.isNotEmpty ?? false) {
      for (var reportGroup
          in groupedBugReports.thirdPartyPluginGroups!.values) {
        if (await showThirdPartySubmitOptionsDialog(reportGroup)) {
          submittedBugReports.addAll(reportGroup);
          // Remove submitted reports from UI
          setState(() => groupedBugReports = (
                appReports: groupedBugReports.appReports,
                bundledPluginGroups: groupedBugReports.bundledPluginGroups,
                thirdPartyPluginGroups: {}
              ));
        }
      }
    }

    if (submittedBugReports.isNotEmpty && mounted) {
      logger.i("Returning ${submittedBugReports.length} submitted 错误报告s");
      showToast("感谢您提交错误报告！", context);
      Navigator.of(context).pop(submittedBugReports);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalAppReports = groupedBugReports.appReports?.length ?? 0;
    int totalBundledPluginReports = groupedBugReports
            .bundledPluginGroups?.values
            .fold<int>(0, (sum, list) => sum + list.length) ??
        0;
    int totalThirdPartyPluginReports = groupedBugReports
            .thirdPartyPluginGroups?.values
            .fold<int>(0, (sum, list) => sum + list.length) ??
        0;
    return PopScope(
        canPop: allowPop,
        onPopInvokedWithResult: (goingToPop, _) => handlePop(goingToPop),
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(widget.unexpectedError
                  ? "意外错误报告"
                  : "错误报告"),
            ),
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: SingleChildScrollView(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                Text("应用信息：",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const SizedBox(height: 5),
                                buildAppInfoField(),
                                const SizedBox(height: 15),
                                if (totalAppReports > 0)
                                  ListTile(
                                      title: Text(
                                          "应用错误报告（$totalAppReports）"),
                                      trailing: const Icon(Icons.arrow_forward),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 0),
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              settings: RouteSettings(
                                                  name: "/bug_reports_list"),
                                              builder: (context) =>
                                                  BugReportsListScreen(
                                                    bugReportsList:
                                                        groupedBugReports
                                                            .appReports!,
                                                  )))),
                                if (totalBundledPluginReports > 0)
                                  ListTile(
                                      title: Text(
                                          "内置插件错误报告（$totalBundledPluginReports）"),
                                      trailing: const Icon(Icons.arrow_forward),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 0),
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              settings: RouteSettings(
                                                  name: "/bug_reports_list"),
                                              builder: (context) =>
                                                  BugReportsListScreen(
                                                    bugReportsList:
                                                        groupedBugReports
                                                            .bundledPluginGroups!
                                                            .values
                                                            .expand(
                                                                (list) => list)
                                                            .toList(),
                                                  )))),
                                if (totalThirdPartyPluginReports > 0)
                                  ListTile(
                                      title: Text(
                                          "第三方插件错误报告（$totalThirdPartyPluginReports）"),
                                      trailing: const Icon(Icons.arrow_forward),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 0),
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              settings: RouteSettings(
                                                  name: "/bug_reports_list"),
                                              builder: (context) =>
                                                  BugReportsListScreen(
                                                    bugReportsList:
                                                        groupedBugReports
                                                            .thirdPartyPluginGroups!
                                                            .values
                                                            .expand(
                                                                (list) => list)
                                                            .toList(),
                                                  )))),
                                const SizedBox(height: 10),
                                Text("补充详情：",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                buildUserMessageField(),
                              ]))),
                          Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: buildActionButtons())
                        ])))));
  }

  Widget buildAppInfoField() {
    return TextFormField(
        controller: appInfoController,
        readOnly: true,
        maxLines: null,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
        ),
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.onSurface)),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.onSurface)),
            border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface))));
  }

  Widget buildUserMessageField() {
    return TextField(
        controller: userInputController,
        maxLines: null,
        minLines: 3,
        textAlignVertical: TextAlignVertical.top,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
          contentPadding: const EdgeInsets.all(5),
          hintText: "问题相关的其他背景信息：",
          border: const OutlineInputBorder(),
          disabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        ));
  }

  Widget buildActionButtons() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(
          style: IconButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.secondaryContainer),
          icon: Icon(Icons.raw_on,
              color: Theme.of(context).colorScheme.onSecondaryContainer),
          onPressed: () => showRawDialog()),
      ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          onPressed: () => submitReports(),
          child: Text(
              bugReportsList.length > 1
                  ? "提交错误报告"
                  : "提交错误报告",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).colorScheme.onPrimary))),
      IconButton(
          style: IconButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.secondaryContainer),
          icon: Icon(Icons.copy_all,
              color: Theme.of(context).colorScheme.onSecondaryContainer),
          onPressed: () => copyCombinedReport())
    ]);
  }
}
