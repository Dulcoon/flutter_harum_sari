import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'transaction_screen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePage(), // Halaman produk
    const CartScreen(),
    const TransactionScreen(), // Halaman transaksi
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        initialActiveIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          TabItem(icon: Icons.home, title: 'Products'),
          TabItem(icon: Icons.shopping_cart, title: 'Cart'),
          TabItem(icon: Icons.list, title: 'Transactions'),
        ],
      ),
    );
  }
}
