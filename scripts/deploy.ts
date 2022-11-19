// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  // We get the contract to deploy



  const Staking = await ethers.getContractFactory("Staking");
  const nftCollection = "0x6609D62E2E3C65858Bf1AADac3fd4C25187B9d99"
  const link = "0x404460C6A5EdE2D891e8297795264fDe62ADBB75"
  const oracle = "0xEF847C4D7893C4598f234638CebE25B4C9Ea32B3"
  const staking = await Staking.deploy(nftCollection, link, oracle);
  await staking.deployed();
  console.log("Staking deployed to:", staking.address);

  await staking.deployTransaction.wait(5);


  await hre.run("verify:verify", {
    address: staking.address,
    contract: "contracts/Staking.sol:Staking", //Filename.sol:ClassName
    constructorArguments: [nftCollection, link, oracle],
 });
 
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
