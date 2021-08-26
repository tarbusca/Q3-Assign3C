const hre = require("hardhat");

async function main() {
  
	const [deployer] = await hre.ethers.getSigners();
	
  console.log("Deploying contracts with the account:", deployer.address);


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.

const TariqToken3B  = await hre.ethers.getContractFactory("TariqToken3B");
const Ttoken  = await TariqToken3B.deploy("Tariq-Token V2", "TTS");

await Ttoken.deployed();

  console.log("Token deployed to:", Ttoken.address);
}
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
