export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/buildartifacts/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_nationwide_CA=${PWD}/buildartifacts/crypto-config/peerOrganizations/nationwide.example.com/peers/peer0.nationwide.example.com/tls/ca.crt
export PEER0_calibber_CA=${PWD}/buildartifacts/crypto-config/peerOrganizations/calibber.example.com/peers/peer0.calibber.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/buildartifacts/config/

export CHANNEL_NAME=claimchannel

# setGlobalsForOrderer(){
#     export CORE_PEER_LOCALMSPID="OrdererMSP"
#     export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/buildartifacts/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
#     export CORE_PEER_MSPCONFIGPATH=${PWD}/buildartifacts/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp
    
# }

setGlobalsForPeer0nationwide(){
    export CORE_PEER_LOCALMSPID="nationwideMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_nationwide_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/buildartifacts/crypto-config/peerOrganizations/nationwide.example.com/users/Admin@nationwide.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1nationwide(){
    export CORE_PEER_LOCALMSPID="nationwideMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_nationwide_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/buildartifacts/crypto-config/peerOrganizations/nationwide.example.com/users/Admin@nationwide.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
    
}

setGlobalsForPeer0calibber(){
    export CORE_PEER_LOCALMSPID="calibberMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_calibber_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/buildartifacts/crypto-config/peerOrganizations/calibber.example.com/users/Admin@calibber.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
    
}

setGlobalsForPeer1calibber(){
    export CORE_PEER_LOCALMSPID="calibberMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_calibber_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/buildartifacts/crypto-config/peerOrganizations/calibber.example.com/users/Admin@calibber.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
    
}

createChannel(){
    #rm -rf ./channel-artifacts/*
    setGlobalsForPeer0nationwide
    
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.example.com \
    -f ./buildartifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

removeOldCrypto(){
    rm -rf ./api-1.4/crypto/*
    rm -rf ./api-1.4/fabric-client-kv-nationwide/*
    rm -rf ./api-2.0/nationwide-wallet/*
    rm -rf ./api-2.0/calibber-wallet/*
}


joinChannel(){
    setGlobalsForPeer0nationwide
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    
    setGlobalsForPeer0calibber
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    
}

updateAnchorPeers(){
    setGlobalsForPeer0nationwide
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./buildartifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0calibber
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./buildartifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
}

#removeOldCrypto // Not required
#Note Run the steps one by one
createChannel
joinChannel
updateAnchorPeers