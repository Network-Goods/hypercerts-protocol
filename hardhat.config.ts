import "@nomiclabs/hardhat-waffle";
import "@openzeppelin/hardhat-upgrades";
import "@typechain/hardhat";
import { config as dotenvConfig } from "dotenv";
import fs from "fs";
import "hardhat-preprocessor";
import { HardhatUserConfig } from "hardhat/config";
import { NetworkUserConfig } from "hardhat/types";
import { resolve } from "path";

import "./tasks";

function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean)
    .map((line) => line.trim().split("="));
}

const dotenvConfigPath: string = process.env.DOTENV_CONFIG_PATH || "./.env";
dotenvConfig({ path: resolve(__dirname, dotenvConfigPath) });

// Ensure that we have all the environment variables we need.
const mnemonic: string | undefined = process.env.MNEMONIC;
if (!mnemonic) {
  throw new Error("Please set your MNEMONIC in a .env file");
}

const infuraApiKey: string | undefined = process.env.INFURA_API_KEY;
if (!infuraApiKey) {
  throw new Error("Please set your INFURA_API_KEY in a .env file");
}

const chainIds = {
  goerli: 5,
  hardhat: 31337,
  mainnet: 1,
};

function getChainConfig(chain: keyof typeof chainIds): NetworkUserConfig {
  const jsonRpcUrl = "https://" + chain + ".infura.io/v3/" + infuraApiKey;

  return {
    accounts: {
      count: 10,
      mnemonic,
      path: "m/44'/60'/0'/0",
    },
    chainId: chainIds[chain],
    url: jsonRpcUrl,
  };
}

const config: HardhatUserConfig = {
  defaultNetwork: "localhost",
  networks: {
    hardhat: {
      accounts: {
        mnemonic,
      },
      chainId: chainIds.hardhat,
    },
    goerli: getChainConfig("goerli"),
    mainnet: getChainConfig("mainnet"),
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache_hardhat", // Use a different cache for Hardhat than Foundry
    sources: "./src",
    tests: "./test",
  },
  preprocess: {
    eachLine: (hre) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import /i)) {
          getRemappings().forEach(([find, replace]) => {
            if (line.match(find)) {
              line = line.replace(find, replace);
            }
          });
        }
        return line;
      },
      dest: "./build",
    }),
  },
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 10_000,
      },
    },
  },
  typechain: {
    outDir: "./typechain",
    target: "ethers-v5",
    externalArtifacts: ["out/**/*.json"], // optional array of glob patterns with external artifacts to process (for example external libs from node_modules)
  },
};

export default config;
