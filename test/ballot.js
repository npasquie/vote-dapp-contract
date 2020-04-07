let assert = require("assert");
const Ballot = artifacts.require("build/Ballot.json");

/*
Ballot.sol :
constructor(
bytes32 _name,
bytes32 _question,
uint _endTime,
bytes32[] memory _votersCodeHashes,
bool _externalitiesEnabled,
bytes32[] memory _pictureHashes,
bytes32[] memory _candidateNames) */

contract("Ballot", (accounts) => {
    it("...should deploy in general case", async () => {
        let stob = (str) => {
          return web3.utils.hexToBytes(
            web3.utils.utf8ToHex(str));
        };
        let hash = (arg) => {
          return web3.utils.soliditySha3(arg);
        };

        let name = stob("vote1");
        let question = stob("pour qui tu votes ?");
        console.log(question);
        let endTime = Date.now() + 86400; // now + 1 day
        let votersCodeHashes = [
          hash(stob("code1")),
          hash(stob("code2")),
          hash(stob("code3"))];
        let externalitiesEnabled = true;
        let pictureHashes = [
          hash(stob("pic1")),
          hash(stob("pic2")),
          hash(stob("pic3"))];
        let candidateNames = [
          stob("unchained"),
          stob("furiours"),
          stob("cosmoz")];

        const ballotInstance = await Ballot.new([
          name,
          question,
          endTime,
          votersCodeHashes,
          externalitiesEnabled,
          pictureHashes,
          candidateNames]);

        const names = await ballotInstance.getCandidateNames();
        assert.equal(names,candidateNames,
          "names given as argument and stored in contract should be the sames");
    });
});
