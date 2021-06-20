#!/bin/bash

touch ./organizations/cryptogen/crypto-config-org1.yaml
touch ./organizations/cryptogen/crypto-config-org2.yaml
touch ./organizations/cryptogen/crypto-config-org3.yaml
touch ./organizations/cryptogen/crypto-config-orderer.yaml

cd ./organizations/cryptogen

touch test.txt

sed -i 's/1/PeerOrg/g' crypto-config-org1.yaml
