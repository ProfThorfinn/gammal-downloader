import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final res = jsonDecode(File('./data/c-programming-res.json').readAsStringSync());
  final content = res['course']['objects'];
  final keys = content.keys.toList().reversed.take(100);
  final dir = '${Directory.current.path}/content';
  await Directory(dir).create(recursive: true);

  for (var key in keys) {
    final item = content[key];
    final type = item['objectType'];
    final name = item['title'];

    switch (type) {
      case 'pdf':
        final url = item['data']['pdf_full'];
        final response = await http.get(Uri.parse(url));
        File('${Directory.current.path}/content/$name.pdf')
            .writeAsBytes(response.bodyBytes);
        print('pdf downloaded $name');

        break;

      case 'embed':
        final embed = item['data']['embed'];
        RegExp regExp = RegExp(r'src="([^"]+)"');
        final url = regExp.firstMatch(embed)?.group(1);

        Process.runSync('python3', ['downloader.py', url!, name, dir]);
        print('Video downloaded $name');

        break;
    }
  }
}
