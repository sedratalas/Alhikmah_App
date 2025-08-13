class WalletModel {
  final int balance;

//<editor-fold desc="Data Methods">
  const WalletModel({
    required this.balance,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is WalletModel &&
              runtimeType == other.runtimeType &&
              balance == other.balance);

  @override
  int get hashCode => balance.hashCode;

  @override
  String toString() {
    return 'WalletModel{' + ' balance: $balance,' + '}';
  }

  WalletModel copyWith({
    int? balance,
  }) {
    return WalletModel(
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'balance': this.balance,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      balance: map['balance'] as int,
    );
  }

//</editor-fold>
}