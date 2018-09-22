var Raffles = artifacts.require("./Raffles.sol");

module.exports = function(deployer) {
  deployer.deploy(Raffles);
};
