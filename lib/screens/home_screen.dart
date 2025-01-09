import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/toast_utils.dart';
import 'dart:async'; // Add this import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List products = [];
  bool isLoading = true;
  bool isLoggedIn = false; // Status login pengguna
  String userName = ''; // Nama pengguna yang login
  List<bool> imageLoadingStates = [];

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    fetchProducts();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      userName = prefs.getString('name') ?? '';
    });
  }

  Future<void> fetchProducts() async {
    final url =
        Uri.parse('https://52e8-36-81-70-227.ngrok-free.app/api/products');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          products = data['data'];
          imageLoadingStates = List<bool>.filled(products.length, true);
        });
        await _loadAllImages();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadAllImages() async {
    await Future.wait(
        products.map((product) => _loadImage(product['image_url'])));
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadImage(String imageUrl) async {
    final image = NetworkImage(
        'https://52e8-36-81-70-227.ngrok-free.app/storage/$imageUrl');
    final completer = Completer<void>();
    final listener = ImageStreamListener((_, __) {
      completer.complete();
    }, onError: (dynamic exception, StackTrace? stackTrace) {
      completer.complete();
    });
    image.resolve(const ImageConfiguration()).addListener(listener);
    await completer.future;
  }

  void navigateToDetail(int productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: productId),
      ),
    );
  }

  void navigateToLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    if (result == true) {
      checkLoginStatus();
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      isLoggedIn = false;
      userName = '';
    });
    ToastUtils.showToastMessage('Logout successful');
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
    );

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(
                  child: Text(
                    'No products available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isLoggedIn
                                          ? 'Welcome Back, $userName'
                                          : '',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'Find Your Perfect Furniture',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: isLoggedIn ? logout : navigateToLogin,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isLoggedIn
                                            ? CupertinoIcons
                                                .square_arrow_left // Ikon Logout
                                            : CupertinoIcons
                                                .square_arrow_right, // Ikon Login
                                        color: Colors.red, // Warna ikon
                                        size: 30, // Ukuran ikon
                                      ),
                                      const SizedBox(
                                          height:
                                              4), // Jarak antara ikon dan teks
                                      Text(
                                        isLoggedIn ? 'Logout' : 'Login',
                                        style: const TextStyle(
                                          fontSize: 14, // Ukuran font
                                          color: Colors.black, // Warna teks
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),

                          // List Produk
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return GestureDetector(
                                onTap: () => navigateToDetail(product['id']),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20.0),
                                  padding: const EdgeInsets.all(15.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 120,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(20))),
                                        child: ClipRRect(
                                            child: Image.network(
                                          'https://52e8-36-81-70-227.ngrok-free.app/storage/${product['image_url']}',
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child; // Menampilkan gambar jika sudah selesai dimuat
                                            } else {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          (loadingProgress
                                                                  .expectedTotalBytes ??
                                                              1)
                                                      : null,
                                                ),
                                              );
                                            }
                                          },
                                        )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Container(
                                          // Ganti Expanded dengan Container
                                          margin:
                                              const EdgeInsets.only(left: 5),
                                          width: 142, // Menetapkan lebar tetap
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['name'],
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                softWrap: true,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                formatter
                                                    .format(product['price']),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Stock: ${product["stok"].toString()}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  final int productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Map product = {};
  bool isLoading = true;
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
  );

  void addToCart(Map product) async {
    if ((product['stok'] ?? 0) < 1) {
      ToastUtils.showToastMessage('Out of stock');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final csrfToken = prefs.getString('csrf_token');
    List<String>? cart = prefs.getStringList('cart') ?? [];

    final userId = prefs.getString('user_id');
    final token = prefs.getString('auth_token');

    if (token == null) {
      ToastUtils.showToastMessage('Please log in to add products to cart');
      return;
    }

    if (userId == null) {
      // Jika user_id tidak ditemukan (misalnya user belum login), tampilkan pesan dan keluar
      ToastUtils.showToastMessage('Please log in to add products to cart');
      return;
    }

    cart.add(jsonEncode({
      'product_id': product['id'],
      'name': product['name'],
      'price': product['price'],
      'stock': product['stok'],
      'quantity': 1,
      'image': product['image_url'],
    }));
    await prefs.setStringList('cart', cart);
    print('Cart: $cart');

    final url =
        Uri.parse('https://52e8-36-81-70-227.ngrok-free.app/api/cart/add');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'X-CSRF-TOKEN': csrfToken ?? '',
      },
      body: jsonEncode({
        'user_id': userId, // Kirim user_id
        'product_id': product['id'],
        'quantity': 1,
      }),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      ToastUtils.showToastMessage('${product['name']} added to cart');
    } else {
      ToastUtils.showToastMessage('Failed to add product to cart');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProductDetail();
  }

  Future<void> fetchProductDetail() async {
    final url = Uri.parse(
        'https://52e8-36-81-70-227.ngrok-free.app/api/products/${widget.productId}');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          product = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      ToastUtils.showToastMessage('Failed to load product details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : product.isEmpty
              ? const Center(child: Text('Product not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            'https://52e8-36-81-70-227.ngrok-free.app/storage/${product['image_url']}',
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child; // Menampilkan gambar jika sudah selesai dimuat
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                );
                              }
                            },
                          )),
                      const SizedBox(height: 20),
                      Container(
                        padding:
                            const EdgeInsets.only(top: 30, left: 30, right: 30),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product['name'] ?? 'No name',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  formatter.format(product['price']),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Category: ${product['category'] ?? 'Unknown'}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              product['description'] ??
                                  'No description available',
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Stock',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${product["stok"] ?? 'Not available'}',
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => addToCart(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Add to Cart',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
