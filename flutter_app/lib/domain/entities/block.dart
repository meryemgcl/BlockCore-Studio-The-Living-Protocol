class Block {
  const Block({
    required this.index,
    required this.hash,
    required this.previousHash,
    required this.nonce,
    required this.difficulty,
  });

  final int index;
  final String hash;
  final String previousHash;
  final int nonce;
  final int difficulty;
}
