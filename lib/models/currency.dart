class Currency {
  final String code;
  final String name;
  final String flag;
  final double rate; // Rate relative to base currency (e.g., USD)
  bool isFavorite;
  bool isSelected;
  double amount;

  Currency({
    required this.code,
    required this.name,
    required this.flag,
    required this.rate,
    this.isFavorite = false,
    this.isSelected = false,
    this.amount = 0.0,
  });

  Currency copyWith({
    String? code,
    String? name,
    String? flag,
    double? rate,
    bool? isFavorite,
    bool? isSelected,
    double? amount,
  }) {
    return Currency(
      code: code ?? this.code,
      name: name ?? this.name,
      flag: flag ?? this.flag,
      rate: rate ?? this.rate,
      isFavorite: isFavorite ?? this.isFavorite,
      isSelected: isSelected ?? this.isSelected,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'flag': flag,
      'rate': rate,
      'isFavorite': isFavorite,
    };
  }

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'],
      name: json['name'],
      flag: json['flag'],
      rate: json['rate'].toDouble(),
      isFavorite: json['isFavorite'] ?? false,
    );
  }
} 