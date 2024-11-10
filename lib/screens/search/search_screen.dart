import 'package:flutter/material.dart';
import '../../components/search_input_bar.dart';
import 'search_results_screen.dart';
import '../../constants/colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: SearchInputBar(
          controller: searchController,
          onSearch: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchResultsScreen(
                  searchText: searchController.text,
                ),
              ),
            );
          },
        ),
      ),
      body: const Center(
        child: Text(
          '검색 페이지',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
