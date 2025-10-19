import 'dart:async';
import 'package:flutter/material.dart';
import 'package:general_insurance_management_system/page/head_office.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _carouselIndex = 0;
  int _hoverIndex = -1;
  int _selectedBottomIndex = 1; // Default to Home
  late PageController _pageController;
  Timer? _timer;

  static const List<String> _images = [
    'https://t3.ftcdn.net/jpg/13/71/18/42/240_F_1371184254_OEF4g1JYdSWwUQqRFxRDVIgFBGXmNcPe.jpg',
    'https://www.shutterstock.com/image-photo/insurer-protecting-family-house-car-260nw-1295560780.jpg',
    'https://png.pngtree.com/template/20220516/ourmid/pngtree-insurance-policy-banner-template-flat-design-illustration-editable-of-square-background-image_1571396.jpg',
  ];

  static const List<String> _texts = [
    'Everyone has their future right in front of their eyes',
    'It just needs to be organized according to a plan',
    'It can be very useful in life',
  ];

  final List<Map<String, String>> _items = [
    {"img": "https://cdn-icons-png.flaticon.com/128/7901/7901731.png", "title": "Fire Policy"},
    {"img": "https://cdn-icons-png.flaticon.com/128/10503/10503975.png", "title": "Fire Bill"},
    {"img": "https://cdn-icons-png.flaticon.com/128/3705/3705833.png", "title": "Fire Money\nReceipt"},
    {"img": "https://cdn-icons-png.flaticon.com/128/7562/7562243.png", "title": "Car Policy"},
    {"img": "https://cdn-icons-png.flaticon.com/128/1854/1854832.png", "title": "Car Bill"},
    {"img": "https://cdn-icons-png.flaticon.com/128/2595/2595934.png", "title": "Car Money\nReceipt"},
    {"img": "https://cdn-icons-png.flaticon.com/128/12245/12245214.png", "title": "Fire Policy\nReports"},
    {"img": "https://cdn-icons-png.flaticon.com/128/9621/9621072.png", "title": "Fire Bill\nReports"},
    {"img": "https://cdn-icons-png.flaticon.com/128/1055/1055644.png", "title": "Fire Money\nReceipt Reports"},
    {"img": "https://cdn-icons-png.flaticon.com/128/438/438036.png", "title": "Car Policy\nReports"},
    {"img": "https://cdn-icons-png.flaticon.com/128/2783/2783924.png", "title": "Car Bill\nReports"},
    {"img": "https://cdn-icons-png.flaticon.com/128/3270/3270753.png", "title": "Car Money\nReceipt Reports"},
  ];

  final List<String> _routes = [
    '/viewfirepolicy',
    '/viewfirebill',
    '/viewfiremoneyreceipt',
    '/viewcarpolicy',
    '/viewcarbill',
    '/viewcarmoneyreceipt',
    '/viewpolicyreport',
    '/viewfirereports',
    '/viewfiremoneyreceiptreports',
    '/viewcarreport',
    '/viewcarreports',
    '/viewcarmoneyreceiptreports',
  ];

  final List<Color> _cardColors = [
    Colors.orangeAccent.shade100,
    Colors.blueAccent.shade100,
    Colors.greenAccent.shade100,
    Colors.purpleAccent.shade100,
  ];

  @override
  void initState() {
    super.initState();
    // 💡 Added viewportFraction for a modern "peek" effect
    _pageController = PageController(viewportFraction: 0.9);
    _autoChangeCarousel();
  }

  void _autoChangeCarousel() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _carouselIndex = (_carouselIndex + 1) % _images.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _carouselIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // 📱 Responsive font/icon scaling (Your function is good!)
  double responsiveSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseSize * 0.8;
    if (screenWidth < 480) return baseSize * 0.9;
    if (screenWidth < 600) return baseSize * 1.0;
    return baseSize * 1.1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildSmartAppBar(context),
      drawer: _buildSmartDrawer(context),
      body: SafeArea(child: _buildSmartBody(context)),
      bottomNavigationBar: _buildSmartBottomNav(context),
    );
  }

  AppBar _buildSmartAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Green General Insurance Company LTD',
        style: TextStyle(
          fontSize: responsiveSize(context, 18),
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      // 💡 Simplified: Removed AnimatedContainer as no animation was triggered
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.teal, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Drawer _buildSmartDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 💡 Replaced UserAccountsDrawerHeader with a more flexible DrawerHeader
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(responsiveSize(context, 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('asset/images/avatar.jpg'),
                  radius: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  "Head Office",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: responsiveSize(context, 16),
                    shadows: const [Shadow(blurRadius: 2, color: Colors.black26)],
                  ),
                ),
                Text(
                  "sadiar.rahman970@gmail.com",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: responsiveSize(context, 12),
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(context, Icons.person, 'Profile', '/profile'),
          _drawerItem(context, Icons.contact_mail, 'Contact Us', '/contact'),
          // _drawerItem(context, Icons.business, 'Head Office', '/headOffice'),
          // _drawerItem(context, Icons.location_city, 'Local Office', '/localOffice'),
          const Divider(),
          _drawerItem(context, Icons.login, 'Login', '/login'),
          _drawerItem(context, Icons.logout, 'Logout', '/login'),
        ],
      ),
    );
  }

  ListTile _drawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal, size: responsiveSize(context, 22)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: responsiveSize(context, 14),
        ),
      ),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }

  Widget _buildSmartBody(BuildContext context) {
    return Container(
      // 💡 Cleaner background color
      color: Colors.grey.shade50,
      child: ListView(
        // Removed global padding, applying to children instead
        children: [
          Padding(
            padding: EdgeInsets.only(top: responsiveSize(context, 16)),
            child: _buildSmartCarousel(context),
          ),
          SizedBox(height: responsiveSize(context, 24)),
          // 💡 Added a section title for better visual hierarchy
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsiveSize(context, 16)),
            child: Text(
              "Our Services",
              style: TextStyle(
                fontSize: responsiveSize(context, 20),
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
          ),
          SizedBox(height: responsiveSize(context, 12)),
          Padding(
            padding: EdgeInsets.all(responsiveSize(context, 16)),
            child: _buildSmartGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartCarousel(BuildContext context) {
    return Column(
      children: [
        // 💡 Added a Container with shadow to "lift" the carousel
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SizedBox(
            height: responsiveSize(context, 180),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => _carouselIndex = i),
              itemBuilder: (context, index) {
                // 💡 Simplified AnimatedContainer to Container
                return Container(
                  // Added margin to space out "peek" cards
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(_images[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(responsiveSize(context, 12)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      // 💡 Darker gradient with stops for better readability
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0.0, 0.6],
                      ),
                    ),
                    child: Text(
                      _texts[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsiveSize(context, 14),
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        // 💡 Added text shadow for clarity
                        shadows: const [Shadow(blurRadius: 2, color: Colors.black54)],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12), // Increased space for dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_images.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _carouselIndex == i ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _carouselIndex == i ? Colors.teal : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSmartGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return MouseRegion(
          onEnter: (_) => setState(() => _hoverIndex = index),
          onExit: (_) => setState(() => _hoverIndex = -1),
          child: AnimatedScale(
            scale: _hoverIndex == index ? 1.05 : 1.0, // Slightly reduced scale for subtlety
            duration: const Duration(milliseconds: 200),
            child: Card(
              color: _cardColors[index % _cardColors.length],
              elevation: _hoverIndex == index ? 8 : 2,
              shadowColor: Colors.tealAccent.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                // 💡 Added custom splash color
                splashColor: Colors.teal.withOpacity(0.2),
                onTap: () {
                  if (index < _routes.length) {
                    Navigator.pushNamed(context, _routes[index]);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(responsiveSize(context, 8)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(item["img"]!, height: responsiveSize(context, 40)),
                      SizedBox(height: responsiveSize(context, 8)),
                      Text(
                        item["title"]!,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: responsiveSize(context, 12),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Slightly softer than pure black
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmartBottomNav(BuildContext context) {
    final items = [
      {'icon': Icons.location_city_rounded, 'label': 'Head Office'},
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.notifications, 'label': 'Notifications'},
    ];

    return BottomNavigationBar(
      currentIndex: _selectedBottomIndex,
      onTap: (index) {
        setState(() => _selectedBottomIndex = index);
        if (index == 0) {
          // Ensure HeadOffice() is imported
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HeadOffice()));
        }
        // Add navigation for other items if needed
      },
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      selectedFontSize: responsiveSize(context, 12),
      unselectedFontSize: responsiveSize(context, 11),
      iconSize: responsiveSize(context, 22),
      type: BottomNavigationBarType.fixed, // Good practice for consistency
      items: items
          .map(
            (e) => BottomNavigationBarItem(
          icon: Icon(e['icon'] as IconData),
          label: e['label'] as String,
        ),
      )
          .toList(),
    );
  }
}