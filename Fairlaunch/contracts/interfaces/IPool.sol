// SPDX-License-Identifier: MIT

interface IPool {
    function initialize(
        address[4] memory _addrs, // [0] = owner, [1] = token, [2] = router, [3] = governance
        uint256 _softCap, // [0] = soft cap, [1] = hard cap
        uint256 _saleToken,
        uint256[3] memory _timeSettings, // [0] = start, [1] = end, [2] = unlock seconds
        uint256[2] memory _feeSettings, // [0] = token fee percent, [1] = eth fee percent
        uint256[5] memory _teamVestings, //[0] = total team token, [1] = first release minute, [2] = first release percent, [3] = period minutes, [4] = each cycle percent
        string memory _urls,
        uint256 _liquidityPercent,
        string memory _poolDetails,
        address _lock
    ) external;
}
