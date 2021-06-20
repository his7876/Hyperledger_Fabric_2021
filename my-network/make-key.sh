#!/bin/bash

export PATH=$PATH:${PWD}/bin

cryptogen generate \
  --config=./organizations/cryptogen/crypto-config-org1.yaml \
  --output="organizations"
cryptogen generate \
  --config=./organizations/cryptogen/crypto-config-org2.yaml \
  --output="organizations"
cryptogen generate \
  --config=./organizations/cryptogen/crypto-config-org3.yaml \
  --output="organizations"
cryptogen generate \
  --config=./organizations/cryptogen/crypto-config-org4.yaml \
  --output="organizations"
cryptogen generate \
  --config=./organizations/cryptogen/crypto-config-orderer.yaml \
  --output="organizations"
