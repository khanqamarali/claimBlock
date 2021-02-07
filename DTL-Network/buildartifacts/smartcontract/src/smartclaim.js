
'use strict';
const { Contract } = require('fabric-contract-api');

class claimInfo extends Contract
{
    async initalPolices(ctx) {        
        console.log('====Started Initalizing ledger=====');
        const claimseed = [
            {
                policyid:'nationA001',
                type:'Auto',
                make:'Nissan',
                model:'rouge',
                year:'2010',
                claimId :'C001',
                claimamount:'5000',
                vendor:'calibber'
            },
            {
                policyid:'nationA002',
                type:'Auto',
                make:'Acura',
                model:'MDX',
                year:'2012',
                claimId :'C002',
                claimamount:'1000',
                vendor:'calibber'
            },
            {
                policyid:'nationA003',
                type:'Auto',
                make:'Acura',
                model:'MDX',
                year:'2012',
                claimId :'C002',
                claimamount:'1000',
                vendor:'calibber'
            },
            {
                policyid:'nationA003',
                type:'Auto',
                make:'BMW',
                model:'X3',
                year:'2020',
                claimId :'C003',
                claimamount:'1500',
                vendor:'calibber'
            },
        ];

        for (let i=0;i<claimseed.length;i++) {
           await ctx.stub.putState(claimseed[i].claimId,buffer.from(JSON.stringify(claimseed[i])));
            console.info('===seeded data===');
        }

    }
    
    async queryCar(ctx, policyid) {
        const policyAsBytes = await ctx.stub.getState(policyid); // get the car from chaincode state
        if (!policyAsBytes || policyAsBytes.length === 0) {
            throw new Error(`${policyid} does not exist`);
        }
        console.log(policyAsBytes.toString());
        return policyAsBytes.toString();
    }
}

module.exports = claimInfo;
