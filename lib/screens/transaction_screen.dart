import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/toast_utils.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<dynamic> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final userId =
        prefs.getString('user_id'); // Ambil user_id dari SharedPreferences

    if (userId == null) {
      ToastUtils.showToastMessage('Please login first');
      return;
    }

    final url = Uri.parse(
        'https://52e8-36-81-70-227.ngrok-free.app/api/transactions/$userId');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${prefs.getString('auth_token')}', // Token autentikasi
      });

      if (response.statusCode == 200) {
        // Jika request berhasil, debug data yang diterima
        final List<dynamic> data = jsonDecode(response.body);
        print('Transactions data received: $data'); // Debug data yang diterima

        setState(() {
          // Hanya update transaksi jika data tidak kosong
          if (data != null && data.isNotEmpty) {
            // Decode items yang ada pada setiap transaksi
            transactions = data.map((transaction) {
              transaction['items'] = jsonDecode(transaction['items']);
              return transaction;
            }).toList();
          }
          isLoading = false;
        });
      } else {
        // Jika request gagal
        setState(() {
          isLoading = false;
        });
        print('Failed to load transactions. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Transactions',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text('No transactions found'))
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 5,
                        shadowColor: Colors.blueGrey[900],
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            'Order ID: ${transaction['order_id']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blueGrey[900],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Status: ${transaction['payment_status']}',
                                style: TextStyle(
                                  color: transaction['payment_status'] ==
                                          'completed'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Amount: Rp ${transaction['gross_amount']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueGrey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Customer: ${transaction['customer_first_name']} ${transaction['customer_last_name']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueGrey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Items:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: (transaction['items'] as List)
                                    .map<Widget>((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: Text(
                                      '${item['name']} - Rp ${item['price']} x ${item['quantity']}',
                                      style: TextStyle(
                                        color: Colors.blueGrey[700],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            transaction['payment_status'] == 'completed'
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: transaction['payment_status'] == 'completed'
                                ? Colors.green
                                : Colors.red,
                            size: 32,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
