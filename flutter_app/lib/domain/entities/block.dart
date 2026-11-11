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

  String get shortHash => hash.length > 12 ? '${hash.substring(0, 12)}…' : hash;

  String get shortPreviousHash => previousHash.length > 12
      ? '${previousHash.substring(0, 12)}…'
      : previousHash;
}
