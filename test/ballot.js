let assert = require("assert");
const Ballot = artifacts.require("../build/Ballot");
let m = require("../misc/ballot-args-handler");

contract("Ballot", (accounts) => {
    it("...should deploy in general case", async () => {
        let candidateNames = ["unchained","furiours","cosmoz"];

        let ballotInstance = await Ballot.new(...m.ballotArgsHandler(
            "vote 1",
            "pour qui tu votes ?",
            Date.now() + 86400,
            [m.strToHash("code1"),
                m.strToHash("code2"),
                m.strToHash("code3")],
            true,
            [m.strToHash("pic1"),
                m.strToHash("pic2"),
                m.strToHash("pic3")],
            candidateNames));

        const names = await ballotInstance.getCandidateNames();
        assert.equal(m.listBytes32ToListStr(names),candidateNames,
          "names given as argument and stored in contract should be the sames");
    });
});
