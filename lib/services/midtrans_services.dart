import 'dart:convert';
import 'package:http/http.dart' as http;

class MidtransService {
  static const String _baseUrl = 'https://52e8-36-81-70-227.ngrok-free.app/api';

  Future<String?> getSnapToken({
    required String orderId,
    required double grossAmount,
    required List<Map<String, dynamic>> items,
    required Map<String, String> customer,
    required String userId,
  }) async {
    try {
      // Menyusun body request
      final body = jsonEncode({
        'order_id': orderId,
        'gross_amount': grossAmount,
        'items': items,
        'customer': customer,
        'user_id': userId, // Mengirimkan user_id ke backend
      });

      // Debugging: Mencetak body yang akan dikirim
      print('Request Body: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/transaction'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['token']; // Kembalikan token Snap
      } else {
        print('Failed to get Snap Token. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching Snap Token: $e');
      return null;
    }
  }
}
