#!/bin/bash


export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export FABRIC_CFG_PATH=${PWD}/config
export PATH=$PATH:${PWD}/bin
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

mkdir anchor 
cd ./anchor

peer channel fetch config config_block.pb \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  -c hospital \
  --tls \
  --cafile $ORDERER_CA

configtxlator proto_decode \
  --input config_block.pb \
  --type common.Block \
  | jq .data.data[0].payload.data.config \
  > Org1MSPconfig.json


jq '.channel_group.groups.Application.groups.Org1MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org1.example.com","port": 7051}]},"version": "0"}}' Org1MSPconfig.json \
  > Org1MSPmodified_config.json

configtxlator proto_encode \
  --input Org1MSPconfig.json \
  --type common.Config \
  > original_config.pb

configtxlator proto_encode \
  --input Org1MSPmodified_config.json \
  --type common.Config \
  > modified_config.pb

configtxlator compute_update \
  --channel_id hospital \
  --original original_config.pb \
  --updated modified_config.pb \
  > config_update.pb

configtxlator proto_decode \
  --input config_update.pb \
  --type common.ConfigUpdate \
  > config_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"hospital", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' \
  | jq . \
  > config_update_in_envelope.json

configtxlator proto_encode \
  --input config_update_in_envelope.json \
  --type common.Envelope \
  > Org1MSPanchors.tx

cd ../

export PATH=$PATH:${PWD}/bin
export FABRIC_CFG_PATH=${PWD}/config
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

cd ./anchor

peer channel signconfigtx -f Org1MSPanchors.tx

peer channel update \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  -c hospital \
  -f Org1MSPanchors.tx \
  --tls \
  --cafile $ORDERER_CA

cd ../

export PATH=$PATH:${PWD}/bin
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

sudo rm ./anchor/*
cd ./anchor


peer channel fetch config config_block.pb \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  -c hospital \
  --tls \
  --cafile $ORDERER_CA

configtxlator proto_decode \
  --input config_block.pb \
  --type common.Block \
  | jq .data.data[0].payload.data.config \
  > Org2MSPconfig.json

jq '.channel_group.groups.Application.groups.Org2MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org2.example.com","port": 9051}]},"version": "0"}}' Org2MSPconfig.json \
  > Org2MSPmodified_config.json

configtxlator proto_encode \
  --input Org2MSPconfig.json \
  --type common.Config \
  > original_config.pb

configtxlator proto_encode \
  --input Org2MSPmodified_config.json \
  --type common.Config \
  > modified_config.pb

configtxlator compute_update \
  --channel_id hospital \
  --original original_config.pb \
  --updated modified_config.pb \
  > config_update.pb

configtxlator proto_decode \
  --input config_update.pb \
  --type common.ConfigUpdate \
  > config_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"hospital", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' \
  | jq . \
  > config_update_in_envelope.json

configtxlator proto_encode \
  --input config_update_in_envelope.json \
  --type common.Envelope \
  > Org2MSPanchors.tx  

cd ../

export PATH=$PATH:${PWD}/bin
export FABRIC_CFG_PATH=${PWD}/config
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

cd ./anchor

peer channel signconfigtx -f Org2MSPanchors.tx

peer channel update \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  -c hospital \
  -f Org2MSPanchors.tx \
  --tls \
  --cafile $ORDERER_CA

:<<'END'

cd ../

export PATH=$PATH:${PWD}/bin
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

sudo rm ./anchor/*
cd ./anchor

peer channel fetch config config_block.pb \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  -c hospital \
  --tls \
  --cafile $ORDERER_CA

configtxlator proto_decode \
  --input config_block.pb \
  --type common.Block \
  | jq .data.data[0].payload.data.config \
  > Org3MSPconfig.json

jq '.channel_group.groups.Application.groups.Org3MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org3.example.com","port": 6051}]},"version": "0"}}' Org3MSPconfig.json \
  > Org3MSPmodified_config.json

configtxlator proto_encode \
  --input Org3MSPconfig.json \
  --type common.Config \
  > original_config.pb

configtxlator proto_encode \
  --input Org3MSPmodified_config.json \
  --type common.Config \
  > modified_config.pb

configtxlator compute_update \
  --channel_id hospital \
  --original original_config.pb \
  --updated modified_config.pb \
  > config_update.pb

configtxlator proto_decode \
  --input config_update.pb \
  --type common.ConfigUpdate \
  > config_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"hospital", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' \
  | jq . \
  > config_update_in_envelope.json

configtxlator proto_encode \
  --input config_update_in_envelope.json \
  --type common.Envelope \
  > Org3MSPanchors.tx  

cd ../

export PATH=$PATH:${PWD}/bin
export FABRIC_CFG_PATH=${PWD}/config
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org3MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
export CORE_PEER_ADDRESS=localhost:6051

cd ./anchor

peer channel signconfigtx -f Org3MSPanchors.tx

peer channel update \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  -c hospital \
  -f Org3MSPanchors.tx \
  --tls \
  --cafile $ORDERER_CA

END








