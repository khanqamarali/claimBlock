
chmod -R 0755 ./crypto-config
# Delete existing artifacts
rm -rf ./crypto-config
rm genesis.block claimchannel.tx
rm -rf ../../channel-artifacts/*

#Generate Crypto artifactes for organizations
cryptogen generate --config=./crypto-config.yaml --output=./crypto-config/



# System channel
SYS_CHANNEL="sys-channel"

# channel name defaults to "mychannel"
CHANNEL_NAME="claimchannel"

echo $CHANNEL_NAME

# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL  -outputBlock ./genesis.block


# Generate channel configuration block
configtxgen -profile BasicChannel -configPath . -outputCreateChannelTx ./claimchannel.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for nationwideMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./nationwideMSPanchors.tx -channelID $CHANNEL_NAME -asOrg nationwideMSP

echo "#######    Generating anchor peer update for calibberMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./calibberMSPanchors.tx -channelID $CHANNEL_NAME -asOrg calibberMSP