const { ethers } = require("hardhat")
const tenPow10 = ethers.BigNumber.from(10).pow(ethers.BigNumber.from(18))

const Gasprice = {
	low: 149,
	average: 170,
	fast: 466,
}

function timeout(ms) {
	return new Promise(resolve => setTimeout(resolve, ms))
}

async function main() {
	let [owner, user, ...addrs] = await ethers.getSigners()
	console.log(owner.address, "-----------------")

	const Staking = await ethers.getContractFactory("Staking")
	const contract = await Staking.attach(
		"0x0600aa50C4E47016F48B858E3c9B26f7FD7d28a7"
	)
	
	const transaction = await contract.transferOwnership(
		"0x86593e854b62279b8b82216e07133320871a4eed"
	)
	await transaction.wait()

}

main()
	.then(() => process.exit(0))
	.catch(error => {
		console.error(error)
		process.exit(1)
	})
