class CardInfo {
  final String number;
  final String type;
  final String expiry;

  const CardInfo({
    required this.number,
    required this.type,
    required this.expiry,
  });

  bool isValid() => number.isNotEmpty && number.length == 16;

  @override
  String toString() {
    return 'Card Info\nnumber: $number\ntype: $type\nexpiry: $expiry';
  }

  // Add factory constructor for creating a CardInfo instance from a JSON object
  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      number: json['cardNumber'],
      expiry: json['expirationDate'],
      type: json['type'],
    );
  }

  // Add method for converting a CardInfo instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'cardNumber': number,
      'expirationDate': expiry,
      'type': type,
    };
  }
}
