let assert = require("assert");
const Ballot = artifacts.require("../build/Ballot");
let m = require("../misc/ballot-utils");

async function deployStandardBallot(){
    return await Ballot.new(...m.ballotArgsHandler(
        "vote 1",
        "pour qui tu votes ?",
        Date.now() + 86400, //now + 1 day
        [m.strToHash("code1"),
            m.strToHash("code2"),
            m.strToHash("code3")],
        true,
        [m.strToHash("pic1"),
            m.strToHash("pic2"),
            m.strToHash("pic3")],
        ["unchained","furiours","cosmoz"]));
}

contract("Ballot", (accounts) => {
    it("...should deploy in general case", async () => {

        let ballotInstance = deployStandardBallot();
        const names = m.listBytes32ToListStr(await ballotInstance.getCandidateNames.call(accounts[0]));
        assert.equal(names[1],"furiours",
          "names given as argument and stored in contract should be the sames");
    });

    it("...should register a vote", async () => {
        let ballotInstance = deployStandardBallot();
        let cand = m.strToBytes32("unchained");
        let code = m.strToBytes32("code1");
        let voteCount = ballotInstance.getCandidateScore.call(cand);
        await ballotInstance.vote.send(cand,code,{from:accounts[0]});
        assert.equal(ballotInstance.getCandidateScore.call(cand), voteCount + 1,
            "voting must add 1 to the candidate score");
    });
});
