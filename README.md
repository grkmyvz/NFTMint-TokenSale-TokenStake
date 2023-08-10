## First step install foundryup

`https://book.getfoundry.sh/getting-started/installation`

## Second step run cli commends

### For Build

Building project:

`forge build`

### For Test

For all tests:

`forge test`

But if you want run one test use to:

`forge test --match-path file/testfilename.t.sol`

Description type extensions for test cli:

`-v`- `-vv`- `-vvv`- `-vvvv`- `-vvvvv`

Example test commend:

`forge test --match-path test/TokenSale.t.sol -vvvvv`
