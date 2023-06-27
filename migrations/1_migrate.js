const Token = artifacts.require("PiyoCoin");
const Pbank = artifacts.require("PiyoBank");

module.exports = async function(deployer) {
	//deploy Token
	await deployer.deploy(Token)

	//assign token into variable to get it's address
	const tokenContract = await Token.deployed()
	
	//pass token address for GameCenter contract(for future minting)
	await deployer.deploy(Pbank, tokenContract.address)

	//assign GameCenter contract into variable to get it's address
	const pbankContract = await Pbank.deployed()

	//change token's owner/minter from deployer to GameCenter
	await tokenContract.passMinterRole(pbankContract.address)
};