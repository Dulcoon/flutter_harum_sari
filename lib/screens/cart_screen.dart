import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'payment_screen.dart';
import '../services/midtrans_services.dart';
import 'package:http/http.dart' as http;
import '../utils/toast_utils.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map> cartItems = [];
  bool isLoading = true;
  double totalPrice = 0.0;
  final MidtransService _midtransService = MidtransService();

  @override
  void initState() {
    super.initState();
    loadCartItems();
  }

  Future<void> removeFromCart(int index) async {
    final url =
        Uri.parse('https://52e8-36-81-70-227.ngrok-free.app/api/cart/remove');
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null || userId.isEmpty) {
      ToastUtils.showToastMessage(
          'Please log in to remove items from your cart.');
      return;
    }

    final product = cartItems[index];
    print(product);
    final productId = product['product_id'];

    print('User ID: $userId, Product ID: $productId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'product_id': productId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          cartItems.removeAt(index);
          calculateTotal();
        });
        print('Product removed successfully');
      } else {
        print('Failed to remove product');
        print('Response status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> loadCartItems() async {
    isLoading = true;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final token = prefs.getString('auth_token');

    if (userId == null || userId.isEmpty || token == null) {
      await Future.delayed(Duration(milliseconds: 500)); // Delay sedikit
      ToastUtils.showToastMessage('Please log in to view your cart.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('https://52e8-36-81-70-227.ngrok-free.app/api/cart');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          cartItems = data.map((item) {
            return {
              'id': item['id'],
              'product_id': item['product_id'],
              'name': item['product_name'] ?? 'Unknown',
              'price': item['price'] ?? 0,
              'stock': item['stock'] ?? 0,
              'quantity': item['quantity'] ?? 1,
              'image': item['image_url'] ?? '',
            };
          }).toList();
          print('Cart items: $cartItems');
          calculateTotal();
          isLoading = false;
        });
      } else {
        ToastUtils.showToastMessage('Failed to load cart items.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error occurred: $e');
      ToastUtils.showToastMessage('An error occurred. Please try again later.');
      setState(() {
        isLoading = false;
      });
    }
  }

  void calculateTotal() {
    totalPrice = cartItems.fold(
      0.0,
      (sum, item) {
        final price = (item['price'] ?? 0) as num;
        final quantity = (item['quantity'] ?? 1) as num;
        return sum + (price * quantity);
      },
    );
  }

  Future<void> showConfirmationModal(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String fullName = prefs.getString('name') ?? '';
    String email = prefs.getString('email') ?? '';
    print('User name: $fullName, email: $email');

    // Split the full name into first and last name
    List<String> nameParts = fullName.split(' ');
    String firstName = nameParts.isNotEmpty ? nameParts.first : '';
    String lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    String phone = '';

    // Controllers for the TextField widgets
    TextEditingController firstNameController =
        TextEditingController(text: firstName);
    TextEditingController lastNameController =
        TextEditingController(text: lastName);
    TextEditingController emailController = TextEditingController(text: email);
    TextEditingController phoneController = TextEditingController(text: phone);

    // Show dialog and update state to capture email properly
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with improved typography
                Center(
                  child: Text(
                    'Konfirmasi Data Diri Anda',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Accent color
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // First Name field with pre-filled value
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary, // Accent color
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary, // Accent color
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white, // Keep the background white
                  ),
                  onChanged: (value) {
                    firstName = value;
                  },
                ),
                const SizedBox(height: 16),

                // Last Name field with pre-filled value
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary, // Accent color
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary, // Accent color
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white, // Keep the background white
                  ),
                  onChanged: (value) {
                    lastName = value;
                  },
                ),
                const SizedBox(height: 16),

                // Email field with pre-filled value
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary, // Accent color
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary, // Accent color
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white, // Keep the background white
                  ),
                  onChanged: (value) {
                    email = value;
                  },
                ),
                const SizedBox(height: 16),

                // Phone field where user can input their phone number
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary, // Accent color
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary, // Accent color
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white, // Keep the background white
                  ),
                  onChanged: (value) {
                    phone = value;
                  },
                ),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    // Submit button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        proceedToPayment(
                          firstName,
                          lastName,
                          emailController.text, // Use this instead of email
                          phoneController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondary, // Accent color
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> proceedToPayment(
      String firstName, String lastName, String email, String phone) async {
    if (cartItems.isEmpty) {
      ToastUtils.showToastMessage('Your cart is empty.');
      return;
    }

    final orderId = "ORDER-${DateTime.now().millisecondsSinceEpoch}";
    final List<Map<String, dynamic>> items = cartItems.map((item) {
      return {
        'id': item['id'],
        'price': item['price'],
        'quantity': item['quantity'],
        'name': item['name'],
      };
    }).toList();

    final customer = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
    };

    final prefs = await SharedPreferences.getInstance();
    final userId =
        prefs.getString('user_id'); // Ambil user_id dari SharedPreferences

    if (userId == null) {
      ToastUtils.showToastMessage('User ID not found. Please log in.');
      return;
    }

    // Menambahkan user_id ke dalam pemanggilan getSnapToken
    final snapToken = await _midtransService.getSnapToken(
      orderId: orderId,
      grossAmount: totalPrice,
      items: items,
      customer: customer,
      userId: userId, // Mengirimkan user_id ke MidtransService
    );

    if (snapToken != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(snapToken: snapToken),
        ),
      );
    } else {
      ToastUtils.showToastMessage(
          'Failed to get Snap Token. Please try again later.');
    }
  }

  Future<bool> updateCartQuantity(int index, int newQuantity) async {
    final url =
        Uri.parse('https://52e8-36-81-70-227.ngrok-free.app/api/cart/update');
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null || userId.isEmpty) {
      ToastUtils.showToastMessage(
          'Please log in to update items in your cart.');
      return false;
    }

    final product = cartItems[index];
    final productId = product['product_id'];
    print('productId: $productId, newQuantity: $newQuantity, userId: $userId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'product_id': productId,
          'quantity': newQuantity,
        }),
      );

      if (response.statusCode == 200) {
        print('Product quantity updated successfully');
        return true;
      } else {
        ToastUtils.showToastMessage('The stock is not enough');
        print('Failed to update product quantity');
        print('Response status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary),
              ),
            )
          : cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      'https://52e8-36-81-70-227.ngrok-free.app/storage/${item['image']}'),
                                  backgroundColor: Colors.grey[300],
                                  radius: 30,
                                ),
                                title: Text(
                                  item['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Price: Rp ${item['price']}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () async {
                                            if (item['quantity'] > 1) {
                                              final newQuantity =
                                                  item['quantity'] - 1;
                                              final success =
                                                  await updateCartQuantity(
                                                      index, newQuantity);
                                              if (success) {
                                                setState(() {
                                                  item['quantity'] =
                                                      newQuantity;
                                                  calculateTotal();
                                                });
                                              }
                                            }
                                          },
                                        ),
                                        Text(
                                          '${item['quantity']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () async {
                                            final newQuantity =
                                                item['quantity'] + 1;
                                            final success =
                                                await updateCartQuantity(
                                                    index, newQuantity);
                                            if (success) {
                                              setState(() {
                                                item['quantity'] = newQuantity;
                                                calculateTotal();
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 28),
                                  onPressed: () => removeFromCart(index),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Rp ${totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => showConfirmationModal(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 120),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              'Checkout',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
