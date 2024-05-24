import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card_info.dart';
import '../utils/logger.dart';

class CardInfoService {
  static const String _baseUrl = 'https://backendapi-tv7m.onrender.com/api/card_info';

  // Create card info
  Future<void> sendCardData(CardInfo cardInfo) async {
    final url = Uri.parse('$_baseUrl/create');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cardInfo.toJson()),
      );

      if (response.statusCode == 201) {
        Logger.log('Card Data', 'Card data sent successfully');
      } else {
        Logger.log('Card Data', 'Failed to send card data: ${response.body}');
      }
    } catch (e) {
      Logger.log('Card Data', 'Error sending card data: $e');
    }
  }

  // Get all card info
  Future<List<CardInfo>> getAllCardInfo() async {
    final url = Uri.parse('$_baseUrl/get');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => CardInfo.fromJson(item)).toList();
      } else {
        Logger.log('Card Data', 'Failed to fetch card data: ${response.body}');
        return [];
      }
    } catch (e) {
      Logger.log('Card Data', 'Error fetching card data: $e');
      return [];
    }
  }

  // Get card info by ID
  Future<CardInfo> getCardInfoById(String id) async {
    final url = Uri.parse('$_baseUrl/getOne/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return CardInfo.fromJson(json.decode(response.body));
      } else {
        Logger.log('Card Data', 'Failed to fetch card data: ${response.body}');
        throw Exception('Failed to fetch card data');
      }
    } catch (e) {
      Logger.log('Card Data', 'Error fetching card data: $e');
      throw Exception('Error fetching card data');
    }
  }

  // Update card info by ID
  Future<void> updateCardInfo(String id, CardInfo cardInfo) async {
    final url = Uri.parse('$_baseUrl/update/$id');
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cardInfo.toJson()),
      );

      if (response.statusCode == 200) {
        Logger.log('Card Data', 'Card data updated successfully');
      } else {
        Logger.log('Card Data', 'Failed to update card data: ${response.body}');
      }
    } catch (e) {
      Logger.log('Card Data', 'Error updating card data: $e');
    }
  }

  // Delete card info by ID
  Future<void> deleteCardInfo(String id) async {
    final url = Uri.parse('$_baseUrl/delete/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        Logger.log('Card Data', 'Card data deleted successfully');
      } else {
        Logger.log('Card Data', 'Failed to delete card data: ${response.body}');
      }
    } catch (e) {
      Logger.log('Card Data', 'Error deleting card data: $e');
    }
  }
}
