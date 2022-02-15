// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
 hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');

//   // We get the contract to deploy
//   let Staking = await hre.ethers.getContractFactory("StandardTokenFactory");
//   let staking = await Staking.deploy("0x61731dF345D63160ac979De280F75b96856BE229", "0xBcCb626aDd32b731fFb4FB949f3aaF43e4Fc5987");
// await staking.deployed();

 Staking = await hre.ethers.getContractFactory("LiquidityGeneratorTokenFactory");
   staking = await Staking.deploy("0x61731dF345D63160ac979De280F75b96856BE229", "0xBcCb626aDd32b731fFb4FB949f3aaF43e4Fc5987");
await staking.deployed();
console.log("LiquidityGeneratorTokenFactory deployed to:", staking.address);


 Staking = await hre.ethers.getContractFactory("BabyTokenFactory");
   staking = await Staking.deploy("0x61731dF345D63160ac979De280F75b96856BE229", "0xBcCb626aDd32b731fFb4FB949f3aaF43e4Fc5987");
await staking.deployed();
console.log("BabyTokenFactory deployed to:", staking.address);


 Staking = await hre.ethers.getContractFactory("BuyBackBabyTokenFactory");
   staking = await Staking.deploy("0x61731dF345D63160ac979De280F75b96856BE229", "0xBcCb626aDd32b731fFb4FB949f3aaF43e4Fc5987");
await staking.deployed();
console.log("BuyBackBabyTokenFactory deployed to:", staking.address);


 Staking = await hre.ethers.getContractFactory("AntiBotStandardTokenFactory");
   staking = await Staking.deploy("0x61731dF345D63160ac979De280F75b96856BE229", "0xBcCb626aDd32b731fFb4FB949f3aaF43e4Fc5987");
await staking.deployed();
console.log("AntiBotStandardTokenFactory deployed to:", staking.address);


 Staking = await hre.ethers.getContractFactory("AntiBotLiquidityGeneratorTokenFactory");
   staking = await Staking.deploy("0x61731dF345D63160ac979De280F75b96856BE229", "0xBcCb626aDd32b731fFb4FB949f3aaF43e4Fc5987");
await staking.deployed();
console.log("AntiBotLiquidityGeneratorTokenFactory deployed to:", staking.address);


 Staking = await hre.ethers.getContractFactory("AntiBotBabyTokenFactory");
   staking = await Staking.deploy("0x61731dF345D63160ac979De280F75b96856BE229", "0xBcCb626aDd32b731fFb4FB949f3aaF43e4Fc5987");
await staking.deployed();
console.log("AntiBotBabyTokenFactory deployed to:", staking.address);


 Staking = await hre.ethers.getContractFactory("AntiBotBuyBackBabyTokenFactory");
   staking = await Staking.deploy("0x61731dF345D63160ac979De280F75b96856BE229", "0xBcCb626aDd32b731fFb4FB949f3aaF43e4Fc5987");
await staking.deployed();
console.log("AntiBotBuyBackBabyTokenFactory deployed to:", staking.address);

  //  Staking = await hre.ethers.getContractFactory("LiquidityGeneratorToken");
  //  staking = await Staking.deploy(
  //   "ETH",
  //   "ETH",
  //   '0x' + Math.pow(10, 17).toString(16),
  //   "0xD99D1c33F9fC3444f8101754aBC46c52416550D1",
  //   "0x0000000000000000000000000000000000000000",
  //   0,
  //   0,
  //   0,
  // );

  // await staking.deployed();

  console.log("Staking deployed to:", staking.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
