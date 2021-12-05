require('dotenv').config();
const Web3 = require('web3');
const BigNumber = require('bignumber.js');
const ethers = require('ethers');

const abis = require('./abis');
const { mainnet: addresses } = require('./addresses');
const schedule = require("node-schedule");

const web3 = new Web3('https://bsc-dataseed1.binance.org:443');
const admin = web3.eth.accounts.wallet.add(process.env.PRIVATE_KEY)
const bscWinBulls = new web3.eth.Contract(
    abis.bscWinBulls,
    addresses.bscWinBulls.proxy
);
const pwn = new web3.eth.Contract(
    abis.pwnLottery,
    addresses.bscWinBulls.pwn
);

const init = async () => {
    var now = new Date();
    var millisTill1 = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 1, 0, 0, 0) - now;
    var millisTill7 = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 7, 0, 0, 0) - now;
    var millisTill13 = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 13, 0, 0, 0) - now;
    var millisTill19 = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 19, 0, 0, 0) - now;
    if (millisTill1 < 0) {
        millisTill1 += 86400000;
    }
    if (millisTill7 < 0) {
        millisTill7 += 86400000;
    }
    if (millisTill13 < 0) {
        millisTill13 += 86400000;
    }
    if (millisTill19 < 0) {
        millisTill19 += 86400000;
    }
    const f = async () => {
        const win = await pwn.methods.tryPwnLottery(10000, true).send({
            from: admin.address,
            gasPrice: '6100000000',
            gas: '12079984'
        })

        console.log(win);
    }

    setTimeout(f, millisTill1);
    setTimeout(f, millisTill7);
    setTimeout(f, millisTill13);
    setTimeout(f, millisTill19);
}

init();
