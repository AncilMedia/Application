import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../View_model/Custom_snackbar.dart';
import '../model/Home_Item.dart';
import '../Controller/Home_item_controller.dart';
import '../View_model/Web_view.dart';

class ListItemDetailsPage extends StatefulWidget {
  final Item parentItem;
  final Item? rootItem;

  const ListItemDetailsPage({
    super.key,
    required this.parentItem,
    this.rootItem,
  });

  @override
  State<ListItemDetailsPage> createState() => _ListItemDetailsPageState();
}

class _ListItemDetailsPageState extends State<ListItemDetailsPage> {
  late Future<List<Item>> futureSubItems;

  @override
  void initState() {
    super.initState();
    futureSubItems = ApiService.fetchSubItems(widget.parentItem.id);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      futureSubItems = ApiService.fetchSubItems(widget.parentItem.id);
    });
    await futureSubItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Item>>(
        future: futureSubItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading sublists: ${snapshot.error}'),
            );
          }

          final subItems = snapshot.data!;
          if (subItems.isEmpty) {
            return Center(
              child: Text(
                "No sublists found",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            );
          }

          return LiquidPullToRefresh(
            onRefresh: _handleRefresh,
            color: const Color(0xFF00CED1),
            backgroundColor: Colors.white,
            showChildOpacityTransition: false,
            height: 120,
            animSpeedFactor: 2.0,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  floating: true,
                  snap: true,
                  pinned: false,
                  leading: IconButton(onPressed: (){
                    Navigator.pop(context);
                  }, icon: Icon(Iconsax.arrow_left_2)),
                  title: Text(widget.parentItem.title, style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17
                    )
                  )),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final item = subItems[index];
                      final itemType = (item.type ?? '').toLowerCase();

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () async {
                              if (itemType == 'list') {
                                final subList = await ApiService.fetchSubItems(item.id);
                                if (subList.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ListItemDetailsPage(
                                        parentItem: item,
                                        rootItem: widget.rootItem ?? widget.parentItem,
                                      ),
                                    ),
                                  );
                                } else {
                                  showCustomSnackBar(context, "Empty List", false);
                                }
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
                                  showCustomSnackBar(context, "Invalid or empty URL.", false);
                                }
                              }
                            },
                            child: SizedBox(
                              height: 200,
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
                    childCount: subItems.length,
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
