#!/bin/bash

export PATH=$PATH:${PWD}/bin
export FABRIC_CFG_PATH=${PWD}/configtx
configtxgen \
  -profile ThreeOrgsChannel \
  -outputCreateChannelTx ./channel-artifacts/hospital.tx \
  -channelID hospital

ls ./channel-artifacts

export PATH=$PATH:${PWD}/bin
export FABRIC_CFG_PATH=${PWD}/config
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:7051

peer channel create \
  -o localhost:7050 \
  -c hospital \
  --ordererTLSHostnameOverride orderer.example.com \
  -f ./channel-artifacts/hospital.tx \
  --outputBlock ./channel-artifacts/hospital.block \
  --tls \
  --cafile $ORDERER_CA

ls channel-artifacts


