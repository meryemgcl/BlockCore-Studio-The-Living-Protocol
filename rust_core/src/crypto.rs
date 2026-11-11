use sha2::{Digest, Sha256};

pub fn sha256_hex(input: impl AsRef<[u8]>) -> String {
    hex::encode(Sha256::digest(input))
}

pub fn merkle_root(items: &[String]) -> String {
    if items.is_empty() {
        return sha256_hex("");
    }

    let mut level = items
        .iter()
        .map(|item| sha256_hex(item))
        .collect::<Vec<_>>();

    while level.len() > 1 {
        let mut next = Vec::with_capacity(level.len().div_ceil(2));
        for pair in level.chunks(2) {
            let right = pair.get(1).unwrap_or(&pair[0]);
            next.push(sha256_hex(format!("{}{}", pair[0], right)));
        }
        level = next;
    }

    level[0].clone()
}

pub fn block_hash(
    index: u64,
    timestamp: u64,
    previous_hash: &str,
    merkle_root: &str,
    nonce: u64,
    difficulty: u8,
) -> String {
    sha256_hex(format!(
        "{index}:{timestamp}:{previous_hash}:{merkle_root}:{nonce}:{difficulty}"
    ))
}

pub fn has_difficulty(hash: &str, difficulty: u8) -> bool {
    hash.starts_with(&"0".repeat(difficulty as usize))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn merkle_root_is_deterministic() {
        assert_eq!(
            merkle_root(&["a".into(), "b".into()]),
            merkle_root(&["a".into(), "b".into()])
        );
    }
}
