var Ballot = artifacts.require("./Ballot.sol");
let misc = require("../misc/ballot-utils");

module.exports = async function(deployer) {
  deployer.deploy(Ballot,...misc.ballotArgsHandler(
      "vote 1",
      "pour qui tu votes ?",
      new Date("December 17, 2023 03:24:00"),
      [misc.strToHash("code1"),
        misc.strToHash("code2"),
        misc.strToHash("code3")],
      true,
      [misc.strToHash("pic1"),
        misc.strToHash("pic2"),
        misc.strToHash("pic3")],
      ["unchained","furiours","cosmoz"]
  ));
};
