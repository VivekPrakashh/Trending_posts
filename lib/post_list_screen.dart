import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:showtask/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  List<dynamic> posts = [];

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      final fetchedPosts = await ApiService.fetchPosts();
      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      print("Error loading posts: $e");
    }
  }

// Call api function
  // Future<void> fetchPosts() async {
  //   const url = 'https://api.hive.blog/';
  //   const body = {
  //     "id": 1,
  //     "jsonrpc": "2.0",
  //     "method": "bridge.get_ranked_posts",
  //     "params": {"sort": "trending", "tag": "", "observer": "hive.blog"}
  //   };

  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(body),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);

  //       if (data['result'] is List) {
  //         setState(() {
  //           posts = data['result'];
  //         });
  //       } else {
  //         print("Invalid format for posts data");
  //       }
  //     } else {
  //       throw Exception('Failed to load posts');
  //     }
  //   } catch (error) {
  //     print("Error fetching posts: $error");
  //   }
  // }

  String formatTime(String created) {
    final date = DateTime.parse(created);
    return DateFormat('yMMMd').format(date);
  }

// Function for Relative Time
  String getRelativeTime(String createdAt) {
    try {
      final DateTime postTime = DateTime.parse(createdAt);
      return timeago.format(postTime, locale: 'en');
    } catch (e) {
      return 'Unknown Time';
    }
  }

// Function for if image is in Map type
  String? getThumbnail(dynamic jsonMetadata) {
    if (jsonMetadata == null) return null;

    try {
      //  Check if already a Map
      if (jsonMetadata is Map<String, dynamic>) {
        if (jsonMetadata.containsKey('image')) {
          final images = jsonMetadata['image'];
          if (images is List && images.isNotEmpty && images[0] is String) {
            return images[0];
          } else if (images is String) {
            return images;
          }
        }
      }
    } catch (e) {
      print("Error parsing thumbnail: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trending Posts')),
      body: posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final String title = post['title'] ?? 'No Title';
                final String author = post['author'];
                final String community_title = post['community_title'];
                final String body = (post['body'] ?? '').toString();
                final String shortBody =
                    body.length > 300 ? body.substring(0, 300) : body;
                final String active_votes =
                    post['active_votes'].length.toString();
                final String comments = post['children'].toString();
                final String created = getRelativeTime(post['created']);

                final String? thumbnail = getThumbnail(post['json_metadata']);

                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$author in $community_title . $created',
                        style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      ListTile(
                        leading: thumbnail != null
                            ? Container(
                                height: 100,
                                width: 100,
                                child: Image.network(thumbnail,
                                    width: 100, height: 100, fit: BoxFit.cover),
                              )
                            : SizedBox(
                                width: 100,
                                height: 100,
                                child: Image.network(
                                    'https://th.bing.com/th?id=OIP.u2BsQpfuQzAtJfeComgn0wHaEM&w=332&h=188&c=8&rs=1&qlt=90&o=6&dpr=1.3&pid=3.1&rm=2',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover),
                              ),
                        title: Text(
                          title,
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(shortBody,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const WidgetSpan(
                                        child: Icon(
                                          Icons.thumb_up,
                                        ),
                                      ),
                                      TextSpan(
                                          text: ' $active_votes',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const WidgetSpan(
                                        child: Icon(
                                          Icons.forum,
                                        ),
                                      ),
                                      TextSpan(
                                          text: comments,
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
