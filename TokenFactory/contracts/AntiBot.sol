// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AntiBot is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    struct Config {
        address router;
        address pair;
        uint256 limitAmount;
        uint256 amountPerBlock;
        uint256 preTransferTime;
        uint256 disableBlockTime;
        uint256 lastTime;
    }
    mapping(address => address) public token_owner;
    mapping(address => mapping(address => bool)) public blocklists;
    mapping(address => Config) public configs;
    mapping(address => bool) public isConfigSet;

    constructor() {}

    function setTokenOwner(address owner) public {
        token_owner[msg.sender] = owner;
    }
    
    function addBlockLists(address _token, address[] memory _blocklists)
        public
    {
        require(token_owner[_token] == msg.sender, "Not Owner");
        for (uint256 i = 0; i < _blocklists.length; i++) {
            blocklists[_token][_blocklists[i]] = true;
        }
    }

    function removeBlockLists(address _token, address[] memory _blocklists)
        public
    {
        require(token_owner[_token] == msg.sender, "Not Owner");
        for (uint256 i = 0; i < _blocklists.length; i++) {
            blocklists[_token][_blocklists[i]] = false;
        }
    }

    function saveConfig(
        address _token,
        address _router,
        address _pair,
        uint256 _limitAmount,
        uint256 _amountPerBlock,
        uint256 _perTransferTime,
        uint256 _disableBlockTime
    ) public {
        require(token_owner[_token] == msg.sender, "Not Owner");
        Config storage _config = configs[_token];
        _config.router = _router;
        _config.pair = _pair;
        _config.amountPerBlock = _amountPerBlock;
        _config.limitAmount = _limitAmount;
        _config.disableBlockTime = block.number + _disableBlockTime;
        _config.preTransferTime = _perTransferTime;
        isConfigSet[_token] = true;
    }

    function onPreTransferCheck(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        Config storage _config = configs[msg.sender];
        if (block.number >= _config.disableBlockTime) return true;
        require(
            blocklists[msg.sender][from] != true &&
                blocklists[msg.sender][to] != true,
            "Transfer between not blocklisted users"
        );
        require(amount > 0 && amount <= _config.limitAmount * (_config.disableBlockTime - block.number), "Invalid Amount");
        require(
            block.timestamp.sub(_config.preTransferTime * 1000) >= _config.lastTime,
            "Not Transfer Time"
        );
        _config.lastTime = block.timestamp;
        return true;
    }

    function getCurrrentBlock() public view returns (uint256) {
        return block.number;
    }
}
