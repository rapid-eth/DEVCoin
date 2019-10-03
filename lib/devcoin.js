const ethers = require("ethers");
const common = require('./common')
const ERC20 = require('./erc20')

const contractName = 'QuestDevCoin'

class DevCoin extends ERC20 {

    static async init(config) {
        let d = new DevCoin()
        await d.initializeProvider(config)
        d.initializeContracts()
        return d
    }

    constructor() {
        super()
    }

    async initializeProvider(config) {
        await common.initializeProvider(this, config)
    }

    initializeContracts() {
        // TODO get Address from network
        // let address = '0x6161baaB9F99Fb441365592D92a757435F9a88Cb'
        this.contract = common.createContract(this, contractName)
    }

    async createCertificate(amount, delegates, meta) {
        let params = [amount, delegates, meta]
        let tx = await common.callContract(this.contract, 'createCertificateType', params, this.signer)
        await tx.wait()
        let certificateId = await this.contract.getCertificateID(...params)
        return certificateId
    }

    async signCertificate(certificateId, recipient) {
        let messageHash = ethers.utils.solidityKeccak256(['bytes', 'address', 'address'], [certificateId, this.contract.address, recipient]);
        let messageHashBytes = ethers.utils.arrayify(messageHash);
        return await this.signer.signMessage(messageHashBytes);
    }

    async getCertificateMetadata(certificateId) {
        const meta = await this.contract.getCertificateData(certificateId)
        return meta
    }

    async getCertificateID(amount, delegates, meta) {
        let params = [amount, delegates, meta]
        let certificateId = await this.contract.getCertificateID(...params)
        return certificateId
    }

    async hasClaimedCertificate(address, certificateId) {
        const params = [certificateId, address]
        return await this.contract.isCertificateClaimed(...params)
    }

    async redeemCertificate(signature, certificateId) {
        let params = [signature, certificateId]
        let tx = await common.callContract(this.contract, 'redeemCertificate', params, this.signer)
        await tx.wait()
    }

    async getBalance(address) {
        let balance = await this.contract['balanceOf'](address)
        let decimals = await this.contract['decimals']()
        if (decimals) {
            balance = balance.div(ethers.utils.parseUnits('1', decimals))
        }
        return balance
    }

    async contractReadFunc(func, params) {
        return await this.contract[func](...params)
    }

    async contractWriteFunc(func, params) {
        const tx = await common.callContract(this.contract, func, params, this.signer)
        await tx.wait()
        return tx
    }

    async saveToIPFS(jsonObject) {
        const content = Buffer.from(JSON.stringify(jsonObject))
        let buffer = Buffer.from(content) //todo file to buffer
        let upload = await this.ipfs.add(Buffer.from(buffer))
        return upload[0].hash
    }
}


module.exports = DevCoin