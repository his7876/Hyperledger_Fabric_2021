#!/bin/bash

export PATH=$PATH:${PWD}/bin

configtxgen \
  -profile ThreeOrgsOrdererGenesis \
  -channelID system-channel \
  -outputBlock ./system-genesis-block/genesis.block \
  -configPath ./configtx

ls ./system-genesis-block
