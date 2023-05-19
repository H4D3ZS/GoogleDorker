import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Dork App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GoogleDorkScreen(),
    );
  }
}

class GoogleDorkScreen extends StatefulWidget {
  @override
  _GoogleDorkScreenState createState() => _GoogleDorkScreenState();
}

class _GoogleDorkScreenState extends State<GoogleDorkScreen> {
  final TextEditingController _dorkController = TextEditingController();
  List<String> _pageUrls = [];
  bool _isLoading = false;

  void _searchGoogleDork() async {
    setState(() {
      _isLoading = true;
      _pageUrls.clear();
    });

    String dork = _dorkController.text.trim();
    if (dork.isEmpty) return;

    try {
      final response =
          await http.get(Uri.parse('https://www.google.com/search?q=$dork'));
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final elements = document.querySelectorAll('a');
        for (var element in elements) {
          final url = element.attributes['href'];
          if (url != null && url.startsWith('/url?q=')) {
            final parsedUrl = Uri.parse(url.substring(7));
            _pageUrls.add(parsedUrl.toString());
          }
        }
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Dork App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dorkController,
              decoration: InputDecoration(
                labelText: 'Enter Google Dork',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _searchGoogleDork,
              child: Text('Search'),
            ),
            SizedBox(height: 16.0),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _pageUrls.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_pageUrls[index]),
                          onTap: () {
                            // TODO: Handle URL selection
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: _pageUrls[index]));
                            },
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                var urls = _pageUrls.join('\n');
                File('urls.txt').writeAsStringSync(urls);
              },
              child: Text('Export URLs to txt'),
            ),
          ],
        ),
      ),
    );
  }
}
