import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../Controller/Home_item_controller.dart';
import '../model/Home_Item.dart';
import 'Responsive/Responsive_font.dart';
import 'Responsive/responsive_page.dart';
import 'detailpage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomTextScale(
          child: Text('FAOG Hawaii', style: GoogleFonts.poppins()),
        ),
        actions: [
          IconButton(
            onPressed: () => print("pressed search button in appbar"),
            icon: const Icon(Iconsax.search_normal),
          ),
          IconButton(
            onPressed: () => print("pressed profile button in appbar"),
            icon: const Icon(Iconsax.profile_circle),
          ),
        ],
      ),
      body: ResponsivePage(
        mobileContent: HomeMobileContent(),
        tabletContent: TabletContent(),
      ),
    );
  }
}

class HomeMobileContent extends StatefulWidget {
  @override
  _HomeMobileContentState createState() => _HomeMobileContentState();
}

class _HomeMobileContentState extends State<HomeMobileContent> {
  late Future<List<Item>> futureItems;

  @override
  void initState() {
    super.initState();
    futureItems = ApiService.fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Item>>(
      future: futureItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = snapshot.data!;
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
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
                  if (await canLaunchUrlString(trimmedUrl)) {
                    await launchUrlString(trimmedUrl, mode: LaunchMode.externalApplication);
                  } else {
                    debugPrint('❌ Cannot launch URL: $trimmedUrl');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Cannot open URL: $trimmedUrl")),
                    );
                  }
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
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
            );
          },
        );
      },
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
