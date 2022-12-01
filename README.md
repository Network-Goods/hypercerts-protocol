# hypercerts-protocol [![Github Actions][gha-badge]][gha] [![Hardhat][hardhat-badge]][hardhat] [![License: MIT][license-badge]][license]

[gha]: https://github.com/bitbeckers/foundry-infinitoken-poc/actions
[gha-badge]: https://github.com/bitbeckers/foundry-infinitoken-poc/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

## Usage

Here's a list of the most frequently needed commands.

### Build

Build the contracts:

```sh
$ forge build
```

### Clean

Delete the build artifacts and cache directories:

```sh
$ forge clean
```

### Compile

Compile the contracts:

```sh
$ forge build
```

### Deploy

Deploy to Anvil:

```sh
$ forge script script/Foo.s.sol:FooScript --fork-url http://localhost:8545 \
 --broadcast --private-key $PRIVATE_KEY
```

For instructions on how to deploy to a testnet or mainnet, check out the
[Solidity Scripting tutorial](https://book.getfoundry.sh/tutorials/solidity-scripting.html).

### Format

Format the contracts with Prettier:

```sh
$ yarn prettier
```

### Gas Usage

Get a gas report:

```sh
$ forge test --gas-report
```

### Lint

Lint the contracts:

```sh
$ yarn lint
```

### Test

Run the tests:

```sh
$ forge test
```

## License

[MIT](./LICENSE.md) © Paul Razvan Berg
