class Block {
  const Block({
    required this.index,
    required this.hash,
    required this.previousHash,
    required this.nonce,
    required this.difficulty,
    this.data = '',
    this.transactions = const [],
    this.merkleRoot = '',
    this.validator = '',
    this.isValid = true,
    this.isCorrupted = false,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      index: json['index'] as int,
      hash: json['hash'] as String,
      previousHash: json['previousHash'] as String,
      nonce: json['nonce'] as int,
      difficulty: json['difficulty'] as int,
      data: json['data'] as String? ?? '',
      transactions: (json['transactions'] as List<dynamic>? ?? [])
          .map((transaction) => transaction as String)
          .toList(growable: false),
      merkleRoot: json['merkleRoot'] as String? ?? '',
      validator: json['validator'] as String? ?? '',
      isValid: json['isValid'] as bool? ?? true,
      isCorrupted: json['isCorrupted'] as bool? ?? false,
    );
  }

  final int index;
  final String hash;
  final String previousHash;
  final int nonce;
  final int difficulty;
  final String data;
  final List<String> transactions;
  final String merkleRoot;
  final String validator;
  final bool isValid;
  final bool isCorrupted;

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'hash': hash,
      'previousHash': previousHash,
      'nonce': nonce,
      'difficulty': difficulty,
      'data': data,
      'transactions': transactions,
      'merkleRoot': merkleRoot,
      'validator': validator,
      'isValid': isValid,
      'isCorrupted': isCorrupted,
    };
  }

  String get shortHash => hash.length > 12 ? '${hash.substring(0, 12)}…' : hash;

  String get shortPreviousHash => previousHash.length > 12
      ? '${previousHash.substring(0, 12)}…'
      : previousHash;
}
