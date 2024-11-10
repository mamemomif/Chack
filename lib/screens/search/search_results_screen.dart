import 'package:flutter/material.dart';
import '../../components/custom_search_bar.dart';
import '../../constants/colors.dart';
import 'search_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  final String searchText;

  const SearchResultsScreen({
    super.key,
    required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomSearchBar(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
            ),
            Expanded(
              child: Center(
                child: Text(
                  '검색 결과: $searchText',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
