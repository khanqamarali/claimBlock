export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/buildartifacts/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_nationwide_CA=${PWD}/buildartifacts/crypto-config/peerOrganizations/nationwide.example.com/peers/peer0.nationwide.example.com/tls/ca.crt
export PEER0_calibber_CA=${PWD}/buildartifacts/crypto-config/peerOrganizations/calibber.example.com/peers/peer0.calibber.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/buildartifacts/config/
# ask pavan why we need this
export PRIVATE_DATA_CONFIG=${PWD}/buildartifacts/private-data/collections_config.json

export CHANNEL_NAME=claimchannel

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/buildartifacts/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/buildartifacts/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp

}

setGlobalsForPeer0nationwide() {
    export CORE_PEER_LOCALMSPID="nationwideMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_nationwide_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/buildartifacts/crypto-config/peerOrganizations/nationwide.example.com/users/Admin@nationwide.example.com/msp
    # export CORE_PEER_MSPCONFIGPATH=${PWD}/buildartifacts/crypto-config/peerOrganizations/nationwide.example.com/peers/peer0.nationwide.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}



setGlobalsForPeer0calibber() {
    export CORE_PEER_LOCALMSPID="calibberMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_calibber_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/buildartifacts/crypto-config/peerOrganizations/calibber.example.com/users/Admin@calibber.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

}


presetup() {
    echo Vendoring Go dependencies ...
    pushd ./artifacts/src/github.com/fabcar/go
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}
# presetup

CHANNEL_NAME="claimchannel"
CC_RUNTIME_LANGUAGE="node"
VERSION="1"
CC_SRC_PATH="./buildartifacts/smartcontract/javascript"
CC_NAME="smartclaim"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0nationwide
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.nationwide ===================== "
}
# packageChaincode

installChaincode() {
    setGlobalsForPeer0nationwide
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.nationwide ===================== "



    setGlobalsForPeer0calibber
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.calibber ===================== "

}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0nationwide
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.nationwide on channel ===================== "
}

# queryInstalled

# --collections-config ./artifacts/private-data/collections_config.json \
#         --signature-policy "OR('nationwideMSP.member','calibberMSP.member')" \
# --collections-config $PRIVATE_DATA_CONFIG \

approveForMynationwide() {
    setGlobalsForPeer0nationwide
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --collections-config $PRIVATE_DATA_CONFIG \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from org 1 ===================== "

}

getBlock() {
    setGlobalsForPeer0nationwide
    # peer channel fetch 10 -c mychannel -o localhost:7050 \
    #     --ordererTLSHostnameOverride orderer.example.com --tls \
    #     --cafile $ORDERER_CA

    peer channel getinfo  -c mychannel -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --cafile $ORDERER_CA
}

# getBlock

# approveForMynationwide

# --signature-policy "OR ('nationwideMSP.member')"
# --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_nationwide_CA --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_calibber_CA
# --peerAddresses peer0.nationwide.example.com:7051 --tlsRootCertFiles $PEER0_nationwide_CA --peerAddresses peer0.calibber.example.com:9051 --tlsRootCertFiles $PEER0_calibber_CA
#--channel-config-policy Channel/Application/Admins
# --signature-policy "OR ('nationwideMSP.peer','calibberMSP.peer')"

checkCommitReadyness() {
    setGlobalsForPeer0nationwide
    peer lifecycle chaincode checkcommitreadiness \
        --collections-config $PRIVATE_DATA_CONFIG \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness

# --collections-config ./artifacts/private-data/collections_config.json \
# --signature-policy "OR('nationwideMSP.member','calibberMSP.member')" \
approveForMycalibber() {
    setGlobalsForPeer0calibber

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --collections-config $PRIVATE_DATA_CONFIG \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from org 2 ===================== "
}

# approveForMycalibber

checkCommitReadyness() {

    setGlobalsForPeer0nationwide
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_nationwide_CA \
        --collections-config $PRIVATE_DATA_CONFIG \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness

commitChaincodeDefination() {
    setGlobalsForPeer0nationwide
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --collections-config $PRIVATE_DATA_CONFIG \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_nationwide_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_calibber_CA \
        --version ${VERSION} --sequence ${VERSION} --init-required

}

# commitChaincodeDefination

queryCommitted() {
    setGlobalsForPeer0nationwide
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

# queryCommitted

chaincodeInvokeInit() {
    setGlobalsForPeer0nationwide
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_nationwide_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_calibber_CA \
        --isInit -c '{"Args":[]}'
        

}

# chaincodeInvokeInit

chaincodeInvoke() {
    # setGlobalsForPeer0nationwide
    # peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
    # --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} \
    # --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_nationwide_CA \
    # --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_calibber_CA  \
    # -c '{"function":"initLedger","Args":[]}'

    setGlobalsForPeer0nationwide

    ## Create Car
    # peer chaincode invoke -o localhost:7050 \
    #     --ordererTLSHostnameOverride orderer.example.com \
    #     --tls $CORE_PEER_TLS_ENABLED \
    #     --cafile $ORDERER_CA \
    #     -C $CHANNEL_NAME -n ${CC_NAME}  \
    #     --peerAddresses localhost:7051 \
    #     --tlsRootCertFiles $PEER0_nationwide_CA \
    #     --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_calibber_CA   \
    #     -c '{"function": "createCar","Args":["Car-ABCDEEE", "Audi", "R8", "Red", "Pavan"]}'

    ## Init ledger
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_nationwide_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_calibber_CA \
        -c '{"function": "initLedger","Args":[]}'

   
}

# chaincodeInvoke

chaincodeQuery() {
    setGlobalsForPeer0calibber

    # Query all cars
    # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryAllCars"]}'

    # Query Car by Id
   
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "queryCar","Args":["claim3"]}'
    #'{"Args":["GetSampleData","Key1"]}'

    # Query Private Car by Id
    # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "readPrivateCar","Args":["1111"]}'
    # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "readCarPrivateDetails","Args":["1111"]}'
}

# chaincodeQuery

# Run this function if you add any new dependency in chaincode
 #presetup

#  packageChaincode
#  installChaincode
# queryInstalled
#  approveForMynationwide
#  checkCommitReadyness
#  approveForMycalibber
#  checkCommitReadyness
#  commitChaincodeDefination
#  queryCommitted # up to this is good
# # #========================
#chaincodeInvokeInit
# sleep 5
#chaincodeInvoke
# sleep 3
chaincodeQuery
