import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '/ui/utils/toast_notification.dart';
import '/ui/widgets/alert_dialog.dart';
import '/utils/global_vars.dart';

Future<void> openExternalLinkWithWarningDialog(
    BuildContext context, Uri link) async {
  if (!(await sharedStorage.getBool("privacy_show_external_link_warning") ??
      true)) {
    logger.i("Skipping privacy warning popup and opening link directly");
    try {
      launchUrl(link);
    } catch (e, stacktrace) {
      logger.e("Failed to open link in browser: $e\n$stacktrace");
      showToast("在浏览器中打开链接失败：$e", context);
    }
    return;
  }
  bool checkBoxValue = false;
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) =>
                ThemedDialog(
                    title: "隐私警告",
                    primaryText: "继续",
                    onPrimary: () async {
                      if (checkBoxValue) {
                        logger.i(
                            "Setting privacy_show_external_link_warning to false");
                        await sharedStorage.setBool(
                            "privacy_show_external_link_warning", false);
                      }
                      try {
                        launchUrl(link);
                      } catch (e, stacktrace) {
                        logger.e(
                            "Failed to open link in browser: $e\n$stacktrace");
                        showToast(
                            "在浏览器中打开链接失败：$e", context);
                      }
                      // close popup
                      Navigator.pop(context);
                    },
                    secondaryText: "取消",
                    onSecondary: Navigator.of(context).pop,
                    content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "这将在您的默认浏览器中打开以下链接。您的"
                              "默认浏览器的隐私设置可能与"
                              "Hedon Haven 不同。确定要继续吗？",
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 10),
                          Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(link.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall))),
                          const SizedBox(height: 10),
                          Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "不再显示此提示",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Checkbox(
                                    visualDensity: VisualDensity.compact,
                                    value: checkBoxValue,
                                    onChanged: (value) =>
                                        setState(() => checkBoxValue = value!)),
                                Spacer()
                              ]),
                        ])));
      });
}
