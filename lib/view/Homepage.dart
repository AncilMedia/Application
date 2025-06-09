import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
// import 'package:untitled2/view/Responsive/Responsive_font.dart';
// import 'package:untitled2/view/Responsive/Responsive_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Controller/Home_item_controller.dart';
import '../model/Home_Item.dart';
import 'Responsive/Responsive_font.dart';
import 'Responsive/responsive_page.dart';
import 'detailpagetwo.dart';

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
          child: Text(
            'FAOG Hawaii',
            style: GoogleFonts.poppins(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              print("pressed search button in appbar");
            },
            icon: Icon(Iconsax.search_normal),
          ),
          IconButton(
            onPressed: () {
              print("pressed profile button in appbar");
            },
            icon: Icon(Iconsax.profile_circle),
          ),
        ],
      ),

      /// Responsive layout starts here
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
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = snapshot.data!;
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
                onTap: () async {
                  // final String url = 'https://forms.firstaog.com/team/youth/graduate-submissions-2024-2025';

                  final trimmedUrl = item.url.trim();
                  final canLaunchIt = await canLaunchUrlString(trimmedUrl);
                  print('Can launch: $canLaunchIt');

                  final launched = await launchUrlString(
                    trimmedUrl,
                    mode: LaunchMode.externalApplication,
                  );

                  if (!launched) {
                    debugPrint('Failed to launch: $trimmedUrl');
                  }
                },
                child:    Container(
                    height: MediaQuery.of(context).size.height *.3,
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(item.image, fit: BoxFit.cover)),
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

