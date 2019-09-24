const utils = require("@utils");

let deployAccount = utils.ethersAccount(0)

const questDevCoin = async () => {
    console.log('deploying QuestDevCoin contract...')
    // string  memory _tokenName,
    // string memory _tokenSymbol,
    // uint8   _decimalUnits,
    // uint256 _cap
    params = ['DEVCoin', 'DEV', 18, utils.parseUnits('1000000', 18)]
    const contract = await utils.deployContractAndWriteToFile('QuestDevCoin', deployAccount, params)
    console.log("QuestDevCoin contract deployed at address: " + contract.address)
    return contract
}

module.exports = {
    questDevCoin,
}