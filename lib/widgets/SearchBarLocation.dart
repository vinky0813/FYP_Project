import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../pages/search_result.dart';
import '../pages/search_result_filter.dart';

class SearchBarLocation extends StatefulWidget {
  @override
  _SearchBarLocationState createState() => _SearchBarLocationState();
}

class _SearchBarLocationState extends State<SearchBarLocation> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> suggestions = [];

  void _onSearchChanged(String value) async {
    if (value.isNotEmpty) {
      final response = await http.get(Uri.parse(
          "https://nominatim.openstreetmap.org/search?q=$value&format=json&addressdetails=1"));
      if (response.statusCode == 200) {
        setState(() {
          suggestions = json.decode(response.body);
        });
      } else {
        setState(() {
          suggestions = [];
        });
      }
    } else {
      setState(() {
        suggestions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(30, 30, 30, 30),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xff000000),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            onSubmitted: (value) {
              Get.to(() => SearchResult(),
                  transition: Transition.circularReveal,
                  duration: const Duration(seconds: 1));
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter Location",
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.search),
              suffixIcon: Container(
                width: 100,
                child: Padding(
                  padding: EdgeInsets.only(right: 7),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const VerticalDivider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                        IconButton(
                          icon: const Icon(Icons.filter_alt),
                          onPressed: () => {
                            Get.to(() => SearchResultFilter(),
                                transition: Transition.circularReveal,
                                duration: const Duration(seconds: 1))
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Display Autocomplete Suggestions
          if (suggestions.isNotEmpty)
            Container(
              color: Colors.white,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(suggestions[index]["display_name"]),
                    onTap: () {
                      _controller.text = suggestions[index]["display_name"];
                      setState(() {
                        suggestions = [];
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
