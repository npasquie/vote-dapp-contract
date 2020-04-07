var Ballot = artifacts.require("./Ballot.sol");
let web3 = require("web3");

module.exports = async function(deployer) {
  let stob = (str) => {
    return web3.utils.hexToBytes(
        web3.utils.utf8ToHex(str));
  };
  let hash = (arg) => {
    return web3.utils.soliditySha3(arg);
  };
  let stoh = (str) => {
    return web3.utils.utf8ToHex(str);
  };
  let dob32hash = (str) =>{
    let ret = stob(hash(stoh(str)));
    ret = ret.slice(2,34);
    return ret;
  };

  /*
  constructor(
  bytes32 _name,
  bytes32 _question,
  uint _endTime,
  bytes32[] memory _votersCodeHashes,
  bool _externalitiesEnabled,
  bytes32[] memory _pictureHashes,
  bytes32[] memory _candidateNames)
   */

  let name = stob("vote1");
  let question = stob("pour qui tu votes ?");
  let endTime = Date.now() + 86400; // now + 1 day
  let votersCodeHashes = [
    dob32hash("code1"),
    dob32hash("code2"),
    dob32hash("code3")];
  let externalitiesEnabled = true;
  let pictureHashes = [
    dob32hash("pic1"),
    dob32hash("pic2"),
    dob32hash("pic1")];
  let candidateNames = [
    stob("unchained"),
    stob("furiours"),
    stob("cosmoz")];

  let args = [
    name,
    question,
    endTime,
    votersCodeHashes,
    externalitiesEnabled,
    pictureHashes,
    candidateNames];

  deployer.deploy(Ballot,...args);
};
