import 'package:material_ui/material_ui.dart';

/// 显示层翻译：把英文选项值翻译成中文显示，但 value 仍是英文存储值，
/// 这样设置项的存储 key 与插件端收到的值保持不变。
const Map<String, String> optionDisplayZh = {
  // 主题
  "Follow device theme": "跟随系统主题",
  "Light theme": "浅色主题",
  "Dark theme": "深色主题",
  // 列表视图
  "Card": "卡片",
  "Grid": "网格",
  "List": "列表",
  // 排序方式
  "Relevance": "相关度",
  "Upload date": "上传日期",
  "Views": "观看数",
  "Rating": "评分",
  "Duration": "时长",
  // 跳转时长
  "5 seconds": "5 秒",
  "10 seconds": "10 秒",
  "15 seconds": "15 秒",
  "20 seconds": "20 秒",
  "25 seconds": "25 秒",
  "30 seconds": "30 秒",
  "60 seconds": "60 秒",
  "120 seconds": "120 秒",
  // 日期范围（筛选器）
  "All time": "全部时间",
  "Last year": "去年",
  "Last month": "上月",
  "Last week": "上周",
  "Last day/Last 3 days/Latest": "最近一天/最近三天/最新",
};

String translateOption(String value) {
  final exact = optionDisplayZh[value];
  if (exact != null) return exact;
  // 允许 "5 seconds" / "120 seconds" 这类由数字拼接出的字幕
  final match = RegExp(r'^(\d+) seconds$').firstMatch(value);
  if (match != null) return '${match.group(1)} 秒';
  return value;
}

class OptionsTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool removeHorizontalPadding;
  final List<String> options;
  final String selectedOption;
  final void Function(String) onSelected;

  const OptionsTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    bool? removeHorizontalPadding,
  }) : removeHorizontalPadding = removeHorizontalPadding ?? false;

  @override
  State<OptionsTile> createState() => _OptionsTileState();
}

class _OptionsTileState extends State<OptionsTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(widget.title),
        subtitle: Text(translateOption(widget.subtitle)),
        // remove extra padding
        visualDensity: widget.removeHorizontalPadding
            ? const VisualDensity(horizontal: 0, vertical: -4)
            : null,
        contentPadding: widget.removeHorizontalPadding ? EdgeInsets.zero : null,
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  title: Text(widget.title),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("取消"),
                    ),
                  ],
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var option in widget.options)
                        RadioListTile(
                          title: Text(translateOption(option)),
                          value: option,
                          groupValue: widget.selectedOption,
                          onChanged: (value) {
                            widget.onSelected(value!);
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                    ],
                  ),
                );
              });
        });
  }
}
