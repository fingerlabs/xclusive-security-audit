# xclusive-security-audit
xclusive-security-audit

## Contracts that do not deploy on the mainnet
- contracts/marketplace/ethereum/token/ERC20/ERC20Token.sol
- contracts/marketplace/ethereum/token/WETH/WETH.sol
- contracts/marketplace/klaytn/token/KIP7/KIP7Token.sol
- contracts/marketplace/klaytn/token/WKLAY/WKLAY.sol

## contract tree
```bash
.
├── contracts
│   ├── access
│   │   ├── MinterRole.sol
│   │   └── Roles.sol
│   ├── common
│   │   ├── Ownable.sol
│   │   └── TokenOwnable.sol
│   ├── library
│   │   ├── AddressUtils.sol
│   │   ├── ArrayUtils.sol
│   │   ├── Context.sol
│   │   ├── Counters.sol
│   │   ├── SafeMath.sol
│   │   └── Strings.sol
│   ├── marketplace
│   │   ├── ethereum
│   │   │   ├── EthereumMarketplaceProxy.sol
│   │   │   ├── MarketplaceStorage.sol
│   │   │   ├── exchange
│   │   │   │   ├── EthereumExchange.sol
│   │   │   │   └── EthereumExchangeCore.sol
│   │   │   └── token
│   │   │       ├── ERC20
│   │   │       │   ├── ERC20Basic.sol
│   │   │       │   └── ERC20Token.sol
│   │   │       ├── ERC721
│   │   │       │   ├── ERC721.sol
│   │   │       │   ├── ERC721Enumerable.sol
│   │   │       │   ├── ERC721Metadata.sol
│   │   │       │   ├── ERC721Token.sol
│   │   │       │   ├── IERC721.sol
│   │   │       │   ├── IERC721Enumerable.sol
│   │   │       │   ├── IERC721Metadata.sol
│   │   │       │   └── IERC721Receiver.sol
│   │   │       ├── WETH
│   │   │       │   └── WETH.sol
│   │   │       ├── factory
│   │   │       │   └── ERCTokenFactory.sol
│   │   │       └── introspection
│   │   │           ├── ERC165.sol
│   │   │           └── IERC165.sol
│   │   └── klaytn
│   │       ├── KlaytnMarketplaceProxy.sol
│   │       ├── MarketplaceStorage.sol
│   │       ├── definix
│   │       │   ├── DefinixHolderList.sol
│   │       │   └── VFinix.sol
│   │       ├── exchange
│   │       │   ├── KlaytnExchange.sol
│   │       │   └── KlaytnExchangeCore.sol
│   │       ├── sunmiya
│   │       │   └── IStakingSunmiya.sol
│   │       └── token
│   │           ├── KIP17
│   │           │   ├── IERC721Receiver.sol
│   │           │   ├── IKIP17.sol
│   │           │   ├── IKIP17Enumerable.sol
│   │           │   ├── IKIP17Metadata.sol
│   │           │   ├── IKIP17Receiver.sol
│   │           │   ├── KIP17.sol
│   │           │   ├── KIP17Enumerable.sol
│   │           │   ├── KIP17Metadata.sol
│   │           │   └── KIP17Token.sol
│   │           ├── KIP7
│   │           │   ├── KIP7Basic.sol
│   │           │   └── KIP7Token.sol
│   │           ├── WKLAY
│   │           │   └── WKLAY.sol
│   │           ├── factory
│   │           │   └── KIPTokenFactory.sol
│   │           └── introspection
│   │               ├── IKIP13.sol
│   │               └── KIP13.sol
│   └── registry
│       ├── OwnableDelegateProxy.sol
│       ├── OwnedUpgradeabilityProxy.sol
│       └── OwnedUpgradeabilityStorage.sol
```