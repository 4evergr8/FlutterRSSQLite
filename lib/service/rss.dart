import 'dart:io';

import 'package:xml/xml.dart';

/// 纯函数：解析 XML 文本，返回一个包含 title, siteUrl, iconUrl 的 Map 键值对
Map<String, String> parseRssXmlMetadata(String xmlString) {
  try {
    final document = XmlDocument.parse(xmlString);

    final channel = document.findAllElements('channel').firstOrNull;
    if (channel != null) {
      final title = channel.findElements('title').firstOrNull?.innerText ?? '未命名订阅源';
      final siteUrl = channel.findElements('link').firstOrNull?.innerText ?? '';
      final iconUrl = channel.findElements('image').firstOrNull?.findElements('url').firstOrNull?.innerText ?? '';

      return {
        'title': title.trim(),
        'siteUrl': siteUrl.trim(),
        'iconUrl': iconUrl.trim(),
      };
    }

    // 未找到 channel 标签时，抛出错误并附上收到的字符串内容
    throw '该订阅源不是标准的 RSS 2.0 格式（未找到 channel 标签）。\n收到的内容：\n$xmlString';

  } catch (e) {
    // 解析发生硬错误时（例如格式完全错乱无法解析成 XML），同样附上原字符串
    throw '解析 XML 发生错误: $e\n收到的内容：\n$xmlString';
  }
}

/// 纯函数：传入 XML 文本，解析出里面的文章列表数据（不建立类，返回 Map 数组）
List<Map<String, String>> parseRssArticles(String xmlString) {
  final List<Map<String, String>> articlesList = [];
  try {
    final document = XmlDocument.parse(xmlString);

    // 1. 尝试解析 RSS 2.0 规范 (<item>)
    final items = document.findAllElements('item');
    for (var item in items) {
      final guid = item.findElements('guid').firstOrNull?.innerText ?? '';
      final title = item.findElements('title').firstOrNull?.innerText ?? '无标题';
      final link = item.findElements('link').firstOrNull?.innerText ?? '';
      final description = item.findElements('description').firstOrNull?.innerText ?? '';
      final content = item.findElements('content:encoded').firstOrNull?.innerText ?? item.findElements('content').firstOrNull?.innerText ?? '';

      // 解析 enclosure 媒体链接
      final enclosureNode = item.findElements('enclosure').firstOrNull;
      final enclosure = enclosureNode?.getAttribute('url') ?? '';

      final author = item.findElements('dc:creator').firstOrNull?.innerText ?? item.findElements('author').firstOrNull?.innerText ?? '';

      // 调用时间戳洗涤逻辑
      final rawDate = item.findElements('pubDate').firstOrNull?.innerText;
      final dateTimestamp = _parseDateToTimestamp(rawDate);

      // 如果 guid 为空，用链接兜底，确保主键不为空
      final finalGuid = guid.isNotEmpty ? guid : link;

      articlesList.add({
        'guid': finalGuid.trim(),
        'title': title.trim(),
        'link': link.trim(),
        'description': description.trim(),
        'content': content.trim(),
        'enclosure': enclosure.trim(),
        'author': author.trim(),
        'date': dateTimestamp,
        'isRead': 'false', // 初始为未读
      });
    }


    return articlesList;
  } catch (e) {
    throw '解析文章失败: $e';
  }
}

/// 内部辅助函数：清洗时间戳为10位秒级字符串
String _parseDateToTimestamp(String? rawDate) {
  if (rawDate == null || rawDate.isEmpty) {
    return (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
  }
  try {
    return (DateTime.parse(rawDate).millisecondsSinceEpoch ~/ 1000).toString();
  } catch (_) {
    try {
      return (HttpDate.parse(rawDate).millisecondsSinceEpoch ~/ 1000).toString();
    } catch (_) {
      return (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    }
  }
}