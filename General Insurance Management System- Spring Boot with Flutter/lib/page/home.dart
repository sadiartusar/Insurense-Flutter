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
    'https://www.shutterstock.com/image-photo/family-house-car-protected-by-260nw-1502368643.jpg',
    'https://www.shutterstock.com/image-photo/insurer-protecting-family-house-car-260nw-1295560780.jpg',
    'https://png.pngtree.com/template/20220516/ourmid/pngtree-insurance-policy-banner-template-flat-design-illustration-editable-of-square-background-image_1571396.jpg',
  ];

  static const List<String> _texts = [
    'Everyone has their future right in front of their eyes',
    'It just needs to be organized according to a plan',
    'It can be very useful in life',
  ];

  final List<Map<String, String>> _items = [
    {"img": "https://cdn-icons-png.flaticon.com/128/1973/1973100.png", "title": "Fire Policy"},
    {"img": "https://cdn-icons-png.flaticon.com/128/1861/1861925.png", "title": "Fire Bill"},
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _autoChangeCarousel();
  }

  void _autoChangeCarousel() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _carouselIndex = (_carouselIndex + 1) % _images.length;
      _pageController.animateToPage(
        _carouselIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildSmartAppBar(),
      drawer: _buildSmartDrawer(),
      body: _buildSmartBody(),
      bottomNavigationBar: _buildSmartBottomNav(context),
    );
  }

  AppBar _buildSmartAppBar() {
    return AppBar(
      title: const Text(
        'Green General Insurance Company LTD',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      flexibleSpace: AnimatedContainer(
        duration: const Duration(seconds: 2),
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

  Drawer _buildSmartDrawer() {

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.greenAccent],
              ),
            ),
            accountName: Text("Head Office"),
            accountEmail: Text("sadiar.rahman970@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('asset/images/avatar.jpg'),
            ),
          ),
          _drawerItem(Icons.person, 'Profile', '/profile'),
          _drawerItem(Icons.contact_mail, 'Contact Us', '/contact'),
          _drawerItem(Icons.business, 'Head Office', '/headOffice'),
          _drawerItem(Icons.location_city, 'Local Office', '/localOffice'),
          const Divider(),
          _drawerItem(Icons.login, 'Login', '/login'),
          _drawerItem(Icons.logout, 'Logout', '/login'),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }

  Widget _buildSmartBody() {
    return Container(
      color: Colors.green.withValues(alpha: 0.05),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSmartCarousel(),
          const SizedBox(height: 20),
          _buildSmartGrid(),
        ],
      ),
    );
  }

  Widget _buildSmartCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: (i) => setState(() => _carouselIndex = i),
            itemBuilder: (context, index) => AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage(_images[index]),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Text(
                  _texts[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_images.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _carouselIndex == i ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _carouselIndex == i ? Colors.teal : Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSmartGrid() {
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
            scale: _hoverIndex == index ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Card(
              elevation: _hoverIndex == index ? 8 : 2,
              shadowColor: Colors.tealAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  if (index < _routes.length) {
                    Navigator.pushNamed(context, _routes[index]);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(item["img"]!, height: 40),
                      const SizedBox(height: 8),
                      Text(
                        item["title"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
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
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HeadOffice()));
        }
      },
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
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
