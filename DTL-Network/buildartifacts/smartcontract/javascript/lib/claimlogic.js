/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');

class ClaimInfo extends Contract {

    async initLedger(ctx) {
        console.info('============= START : Initialize Ledger ===========');
        const claimseeds = [
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


        for (let i = 0; i < claimseeds.length; i++) {
            claimseeds[i].docType = 'claim';
            await ctx.stub.putState('claim' + i, Buffer.from(JSON.stringify(claimseeds[i])));
            console.info('Added <--> ', claimseeds[i]);
        }
        console.info('============= END : Initialize Ledger ===========');
    }

    async queryCar(ctx, claimNumber) {
        const carAsBytes = await ctx.stub.getState(claimNumber); // get the car from chaincode state
        if (!carAsBytes || carAsBytes.length === 0) {
            throw new Error(`${carNumber} does not exist`);
        }
        console.log(carAsBytes.toString());
        return carAsBytes.toString();
    }
          

}

module.exports = ClaimInfo;
