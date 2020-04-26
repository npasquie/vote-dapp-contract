const web3 = require("web3");

//I actually should have used web3.abi.encode<...> instead of all this shit
module.exports = {
  ballotArgsHandler: function (
        name,
        question,
        endTime,
        votersCodeHashes,
        externalitiesEnabled,
        pictureHashes,
        candidateNames)
  {
    return [
      this.strToBytes32(name),
      this.strToBytes32(question),
      endTime,
      this.hashListToListBytes32(votersCodeHashes),
      externalitiesEnabled,
      this.hashListToListBytes32(pictureHashes),
      this.strListToListBytes32(candidateNames)
    ];
  },

  strToBytes32: function (str) {
    let ret;
    ret = web3.utils.utf8ToHex(str);
    ret = web3.utils.hexToBytes(ret);
    return ret.slice(0, 32);
  },

  bytes32ToStr: function (str) {
    return web3.utils.hexToUtf8(str);
  },

  strListToListBytes32: function (list) {
    let ret = [];
    list.forEach((el, i) => {
      ret[i] = this.strToBytes32(el);
    });
    return ret;
  },

  hashListToListBytes32: function (list) {
    let ret = [];
    list.forEach((el, i) => {
      ret[i] = web3.utils.hexToBytes(el);
    });
    return(ret);
  },

  listBytes32ToListStr: function (list) {
    let ret = [];
    list.forEach((el,i) => {
      ret[i] = this.bytes32ToStr(el);
    });
    return ret;
  },

  strToHash: function (str) {
    let ret = web3.utils.utf8ToHex(str);
    ret = web3.utils.hexToBytes(ret);
    ret = ret.slice(0, 32);
    ret = ret.concat(new Array(32 - ret.length).fill(0));
    ret = web3.utils.bytesToHex(ret);
    return web3.utils.soliditySha3(ret);
  }
};
