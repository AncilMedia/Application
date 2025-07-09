import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/Home_Item.dart';
import '../Controller/Home_item_controller.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ListItemDetailsPage extends StatefulWidget {
  final Item parentItem;
  final Item? rootItem;

  const ListItemDetailsPage({super.key, required this.parentItem, this.rootItem});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentItem.title, style: GoogleFonts.poppins()),
      ),
      body: FutureBuilder<List<Item>>(
        future: futureSubItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading sublists: ${snapshot.error}'));
          }

          final subItems = snapshot.data!;
          if (subItems.isEmpty) {
            return Center(
              child: Text("No sublists found", style: GoogleFonts.poppins(fontSize: 16)),
            );
          }

          return ListView.builder(
            itemCount: subItems.length,
            itemBuilder: (context, index) {
              final item = subItems[index];
              final itemType = (item.type ?? '').toLowerCase();

              return GestureDetector(
                onTap: () async {
                  if (itemType == 'list') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListItemDetailsPage(
                          parentItem: item,
                          rootItem: widget.rootItem ?? widget.parentItem,
                        ),
                      ),
                    );
                  } else if (itemType == 'link') {
                    final trimmedUrl = item.url?.trim() ?? '';
                    if (await canLaunchUrlString(trimmedUrl)) {
                      await launchUrlString(trimmedUrl, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Cannot open URL: $trimmedUrl")),
                      );
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  height: 180,
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
              );
            },
          );
        },
      ),
    );
  }
}
