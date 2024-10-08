#!/bin/bash
set -o pipefail

cd "$(dirname "$0")"
cd ..

# Delete old files
rm -rf ./compiled/*

#if [[ -z "${SOLC_PATH}" ]]; then
    ## Assumes that you have solc 0.6.12 (https://github.com/ethereum/solidity/releases/tag/v0.6.12) installed in your PATH
    #solcBin="solc"
#else
    ## Otherwise, you can specify the path to solc 0.6.12
    #solcBin="${SOLC_PATH}"
#fi

echo 'Downloading solc...'
case "$OSTYPE" in
  darwin*)  solcPlatform="solc-macos" ;;
  linux*)   solcPlatform="solc-static-linux" ;;
  *)        solcPlatform="solc-static-linux" ;;
esac
solcBin=$(pwd)/solc
wget -nc -q -O $solcBin https://github.com/ethereum/solidity/releases/download/v0.6.12/${solcPlatform}
chmod a+x $solcBin

pwd="$(pwd -P)"
paths="$pwd/sol/,$pwd/node_modules/@openzeppelin/"
oz_map="@openzeppelin/=$pwd/node_modules/@openzeppelin/"
./scripts/writeMerkleZeroesContracts.sh

echo 'Building contracts'
$solcBin $oz_map -o ./compiled ./sol/*.sol --overwrite --optimize --bin --abi --bin-runtime --allow-paths=$paths
$solcBin $oz_map -o ./compiled ./sol/**/*.sol --overwrite --optimize --bin --abi --bin-runtime --allow-paths=$paths

# Build the Poseidon contract from bytecode
node build/buildPoseidon.js
