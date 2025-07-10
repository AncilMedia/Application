import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../Controller/Home_item_controller.dart';
import '../model/Home_Item.dart';
import 'Responsive/Responsive_font.dart';
import '../View_model/Web_view.dart';
import 'detailpage.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Future<List<Item>> futureItems;
  bool _isRefreshing = false;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureItems = ApiService.fetchItems();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    futureItems = ApiService.fetchItems();
    await futureItems;
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isRefreshing = false);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: FutureBuilder<List<Item>>(
        future: futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !_isRefreshing) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<Item> items = snapshot.data!;
          if (_isSearching && _searchQuery.isNotEmpty) {
            items = items
                .where((item) => item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();
          }

          return LiquidPullToRefresh(
            onRefresh: _handleRefresh,
            backgroundColor: Colors.white,
            color: const Color(0x00FF00CED1),
            showChildOpacityTransition: false,
            height: 120,
            animSpeedFactor: 2.0,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                if (!_isRefreshing)
                  SliverAppBar(
                    backgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    floating: true,
                    snap: true,
                    title: _isSearching
                        ? Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Search...',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: GoogleFonts.poppins(color: Colors.black),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                    )
                        : CustomTextScale(
                      child: Text('FAOG Hawaii', style: GoogleFonts.poppins()),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(_isSearching ? Iconsax.close_circle : Iconsax.search_normal),
                        onPressed: _toggleSearch,
                      ),
                      if (!_isSearching)
                        IconButton(
                          onPressed: () => print("pressed profile button in appbar"),
                          icon: const Icon(Iconsax.profile_circle),
                        ),
                    ],
                  ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final item = items[index];
                      final itemType = (item.type ?? '').toLowerCase();

                      return GestureDetector(
                        onTap: () async {
                          if (itemType == 'list') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ListItemDetailsPage(
                                  parentItem: item,
                                  rootItem: item,
                                ),
                              ),
                            );
                          } else if (itemType == 'link') {
                            final trimmedUrl = item.url?.trim() ?? '';
                            if (trimmedUrl.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WebViewPage(url: trimmedUrl),
                                ),
                              );
                            } else {
                              debugPrint('❌ Invalid or empty URL.');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Cannot open the link.")),
                              );
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * .3,
                              width: MediaQuery.of(context).size.width,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      item.image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.broken_image),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black54,
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        item.title,
                                        style: GoogleFonts.poppins(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: items.length,
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

class TabletContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "This is tablet view content",
        style: GoogleFonts.poppins(fontSize: 16),
      ),
    );
  }
}
