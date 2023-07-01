const Dquake = artifacts.require("Dquake");

module.exports = async function(deployer) {
	//pass token address for GameCenter contract(for future minting)
	await deployer.deploy(Dquake)

	//assign GameCenter contract into variable to get it's address
	const dquakekContract = await Dquake.deployed()

};