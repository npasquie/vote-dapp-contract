let assert = require("assert");
const Ballot = artifacts.require("../build/Ballot");
let m = require("../misc/ballot-utils");
// let web3 = require("web3");
// let bignumber = require("bignumber");

async function deployStandardBallot(){
    return await Ballot.deployed();
}

contract("Ballot", (accounts) => {
    it("...should deploy in general case", async () => {

        let bI = await deployStandardBallot();
        const names = m.listBytes32ToListStr(await bI.getCandidateNames.call());
        assert.equal(names[1],"furiours",
          "names given as argument and stored in contract should be the sames");
    });

    it("...should register a vote", async () => {
        let bI = await deployStandardBallot();
        let cand = m.strToBytes32("unchained");
        let code = m.strToBytes32("code1");
        let voteCount = await bI.getCandidateScore.call(cand);
        voteCount = voteCount.toNumber();
        await bI.vote(cand,code,{from:accounts[0]});
        let voteCount2 = await bI.getCandidateScore.call(cand);
        voteCount2 = voteCount2.toNumber();

        assert.equal(voteCount2, voteCount + 1,
            "voting must add 1 to the candidate score");
    });

    it("...should't allow to vote twice", async () => {
        let bI = await deployStandardBallot();
        let code = m.strToBytes32("code2");
        let cand = m.strToBytes32("cosmoz");
        await bI.vote(cand,code,{from:accounts[0]});
        // await bI.vote(cand,code,{from:accounts[0]});
        // let voteCount = await bI.getCandidateScore.call(cand);
        // voteCount = voteCount.toNumber();
        let f = async () => {await bI.vote(cand,code,{from:accounts[0]});};
        assert.throws(f,"voters should be able to vote only once");
    });

    it("...should register externalities", async () => {
        let bI = await deployStandardBallot();
        let cand = m.strToBytes32("furiours");
        await bI.addNewExternality(cand,-2,{from:accounts[0]});
        let voteCount = await bI.getCandidateScore.call(cand);
        voteCount = voteCount.toNumber();
        assert.equal(voteCount,-2,"externalities must be registered");
    });

    it("...should NOT register externalities if sender is not owner", async () => {
        let bI = await deployStandardBallot();
        let cand = m.strToBytes32("cosmoz");
        await bI.addNewExternality(cand,-2,{from:accounts[1]});
        //let externality = await bI.getExternality.call(cand);
        //externality = externality.toNumber();
        assert.fail(await bI.getExternality.call(cand),"only the owner should be able to register externalities");
    });
});
