use crate::model::{Block, Chain, Transaction};

pub fn create_genesis_chain(timestamp: u64, difficulty: u8) -> Chain {
    Chain::genesis(timestamp, difficulty)
}

pub fn mine_block(chain: &mut Chain, timestamp: u64, transactions: Vec<Transaction>) -> Block {
    chain.append(timestamp, transactions).clone()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn mining_appends_a_valid_block() {
        let mut chain = create_genesis_chain(1, 1);
        let block = mine_block(
            &mut chain,
            2,
            vec![Transaction {
                id: "tx-1".into(),
                payload: "demo".into(),
            }],
        );
        assert_eq!(block.index, 1);
        assert!(chain.is_valid());
    }
}
