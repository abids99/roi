const Roi = artifacts.require("Roi");
// const Token = artifacts.require("Token");

module.exports = function (deployer) {
  // deployer.deploy(Token);
    
  deployer.deploy(Roi);
};