use serde::{Deserialize, Serialize};

use crate::crypto::{block_hash, has_difficulty, merkle_root};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Transaction {
    pub id: String,
    pub payload: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Block {
    pub index: u64,
    pub timestamp: u64,
    pub previous_hash: String,
    pub current_hash: String,
    pub nonce: u64,
    pub difficulty: u8,
    pub merkle_root: String,
    pub transactions: Vec<Transaction>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Chain {
    pub blocks: Vec<Block>,
}

impl Block {
    pub fn new(
        index: u64,
        timestamp: u64,
        previous_hash: String,
        transactions: Vec<Transaction>,
        difficulty: u8,
    ) -> Self {
        let transaction_data = transactions
            .iter()
            .map(|transaction| format!("{}:{}", transaction.id, transaction.payload))
            .collect::<Vec<_>>();
        let root = merkle_root(&transaction_data);
        let mut nonce = 0;
        let current_hash;

        loop {
            let candidate = block_hash(index, timestamp, &previous_hash, &root, nonce, difficulty);
            if has_difficulty(&candidate, difficulty) {
                current_hash = candidate;
                break;
            }
            nonce += 1;
        }

        Self {
            index,
            timestamp,
            previous_hash,
            current_hash,
            nonce,
            difficulty,
            merkle_root: root,
            transactions,
        }
    }
}

impl Chain {
    pub fn genesis(timestamp: u64, difficulty: u8) -> Self {
        let genesis = Block::new(0, timestamp, "0".repeat(64), Vec::new(), difficulty);
        Self {
            blocks: vec![genesis],
        }
    }

    pub fn append(&mut self, timestamp: u64, transactions: Vec<Transaction>) -> &Block {
        let previous = self.blocks.last().expect("chain always has genesis");
        let block = Block::new(
            previous.index + 1,
            timestamp,
            previous.current_hash.clone(),
            transactions,
            previous.difficulty,
        );
        self.blocks.push(block);
        self.blocks.last().expect("block was just appended")
    }

    pub fn is_valid(&self) -> bool {
        self.blocks.windows(2).all(|pair| {
            let previous = &pair[0];
            let current = &pair[1];
            current.previous_hash == previous.current_hash
                && current.current_hash
                    == block_hash(
                        current.index,
                        current.timestamp,
                        &current.previous_hash,
                        &current.merkle_root,
                        current.nonce,
                        current.difficulty,
                    )
                && has_difficulty(&current.current_hash, current.difficulty)
        })
    }
}
