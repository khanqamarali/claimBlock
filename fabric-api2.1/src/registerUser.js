'use strict';

var { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const FabricCAServices = require('fabric-ca-client');
const fs = require('fs');
const util = require('util');
const { Console } = require('console');

const getCCP = async (org) => {
    let ccpPath;
   debugger
    if (org == "nationwide") {
        ccpPath = path.resolve('./', '..', 'fabric-api2.1/config', 'connection-nationwide.json');

    } else if (org == "calibber") {
        ccpPath = path.resolve(__dirname, '..', 'fabric-api2.1/config', 'connection-calibber.json');
    } else
        return null
    const ccpJSON1 = fs.readFileSync(ccpPath)
    const ccpJSON = fs.readFileSync(ccpPath, 'utf8')
    const ccp = JSON.parse(ccpJSON);
  
    return ccp
}

const getCaInfo = async (org, ccp) => {
    let caInfo
    if (org == "nationwide") {
        caInfo = ccp.certificateAuthorities['ca.nationwide.example.com'];

    } else if (org == "calibber") {
        caInfo = ccp.certificateAuthorities['ca.calibber.example.com'];
    } else
        return null
    return caInfo

}

const getCaUrl = async (org, ccp) => {
    let caURL;
;
    if (org == "nationwide") {
        caURL = ccp.certificateAuthorities['ca.nationwide.example.com'].url;

    } else if (org == "calibber") {
        caURL = ccp.certificateAuthorities['ca.calibber.example.com'].url;
    } else
        return null

    return caURL

}

const getWalletPath = async (org) => {
    let walletPath;
    if (org == "nationwide") {
        walletPath = path.join(process.cwd(), 'nationwide-wallet');

    } else if (org == "calibber") {
        walletPath = path.join(process.cwd(), 'calibber-wallet');
    } else
        return null
    return walletPath

}

const getRegisteredUser = async (username, userOrg, isJson) => {
    console.log(userOrg)
    let ccp = await getCCP(userOrg)
    console.log(ccp);
    const caURL = await getCaUrl(userOrg, ccp)
    console.log(caURL);
    const ca = new FabricCAServices(caURL);

     const walletPath = await getWalletPath(userOrg)
     const wallet = await Wallets.newFileSystemWallet(walletPath);
     console.log(`Wallet path: ${walletPath}`);
    console.log('1. ===========================================');
     const userIdentity = await wallet.get(username);

    if (userIdentity) {
        console.log(`An identity for the user ${username} already exists in the wallet`);
        var response = {
            success: true,
            message: username + ' enrolled Successfully',s
        };
        return response
    }
    console.log('2. ===========================================');
    //Check to see if we've already enrolled the admin user.
    let adminIdentity = await wallet.get('admin');
    if (!adminIdentity) {
        console.log('An identity for the admin user "admin" does not exist in the wallet');
        await enrollAdmin(userOrg, ccp);
        adminIdentity = await wallet.get('admin');
        console.log("Admin Enrolled Successfully")
    }
    console.log('3. ===========================================');
    //build a user object for authenticating with the CA
    const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
    const adminUser = await provider.getUserContext(adminIdentity, 'admin');
    let secret;
    try {
        //Register the user, enroll the user, and import the new identity into the wallet.
        secret = await ca.register({ affiliation: await getAffiliation(userOrg), enrollmentID: username, role: 'client' }, adminUser);
        const secret = await ca.register({ affiliation: 'nationwide.department1', enrollmentID: username, role: 'client', attrs: [{ name: 'role', value: 'approver', ecert: true }] }, adminUser);

    } catch (error) {
        return error.message
    }

    const enrollment = await ca.enroll({ enrollmentID: username, enrollmentSecret: secret });
    

    let x509Identity;
    if (userOrg == "nationwide") {
        x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: 'nationwideMSP',
            type: 'X.509',
        };
    } else if (userOrg == "calibber") {
        x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: 'calibberMSP',
            type: 'X.509',
        };
    }

    await wallet.put(username, x509Identity);
    console.log(`Successfully registered and enrolled admin user ${username} and imported it into the wallet`);

    var response = {
        success: true,
        message: username + ' enrolled Successfully',
    };
    return response
}

exports.getRegisteredUser = getRegisteredUser