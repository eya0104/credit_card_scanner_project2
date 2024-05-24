import 'dart:core';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/card_info.dart';
import '../utils/string_extension.dart';

class CardParserUtil {
  final int _cardNumberLength = 16;
  final String _cardVisa = 'Visa';
  final String _cardMasterCard = 'MasterCard';
  final String _cardUnknown = 'Unknown';
  final String _cardVisaParam = '4';
  final String _cardMasterCardParam = '5';

  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<CardInfo?> detectCardContent(InputImage inputImage) async {
    final recognizedText = await _textRecognizer.processImage(inputImage);
    final clearElements = recognizedText.blocks.map((block) => block.text.clean()).toList();

    try {
      final possibleCardNumber = clearElements.firstWhere((input) {
        final cleanValue = input.fixPossibleMisspells();
        return (cleanValue.length == _cardNumberLength) && (int.tryParse(cleanValue) != null);
      });

      final cardType = _getCardType(possibleCardNumber);
      final expirationDate = _getExpireDate(clearElements);


      return CardInfo(
          number: possibleCardNumber, type: cardType, expiry: expirationDate);
    } catch (e) {
      return null;
    }
  }

  String _getExpireDate(List<String> input) {
    try {
      final possibleDate = input.firstWhere((input) {
        final cleanValue = input.fixPossibleMisspells();
        return cleanValue.length == 4 && RegExp(r'^(0[1-9]|1[0-2])([0-9]{2})$').hasMatch(cleanValue);
      });
      return possibleDate.fixPossibleMisspells().possibleDateFormatted();
    } catch (e) {
      return '';
    }
  }


  String _getCardType(String input) {
    if (input.startsWith(_cardVisaParam)) {
      return _cardVisa;
    } else if (input.startsWith(_cardMasterCardParam)) {
      return _cardMasterCard;
    } else {
      return _cardUnknown;
    }
  }
}
