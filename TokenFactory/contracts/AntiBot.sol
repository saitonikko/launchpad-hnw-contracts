pragma solidity ^0.8.0;
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
        uint256 limitTime;
        uint256 disableBlockTime;
        uint256 preTransferTime;
    }
    mapping(address => address) public token_owner;
    mapping(address => mapping(address => bool)) public whitelists;
    mapping(address => Config) public configs;
    mapping(address => bool) public isConfigSet;

    constructor() {}

    function setTokenOwner(address owner) public {
        token_owner[msg.sender] = owner;
    }

    function addWhiteLists(address _token, address[] memory _whitelists)
        public
    {
        require(token_owner[_token] == msg.sender, "Not Owner");
        for (uint256 i = 0; i < _whitelists.length; i++) {
            whitelists[_token][_whitelists[i]] = true;
        }
    }

    function removeWhiteLists(address _token, address[] memory _whitelists)
        public
    {
        require(token_owner[_token] == msg.sender, "Not Owner");
        for (uint256 i = 0; i < _whitelists.length; i++) {
            whitelists[_token][_whitelists[i]] = false;
        }
    }

    function saveConfig(
        address _token,
        address _router,
        address _pair,
        uint256 _limitAmount,
        uint256 _limitTime,
        uint256 _disableBlockTime
    ) public {
        require(token_owner[_token] == msg.sender, "Not Owner");
        Config storage _config = configs[_token];
        _config.router = _router;
        _config.limitTime = _limitTime;
        _config.limitAmount = _limitAmount;
        _config.pair = _pair;
        _config.disableBlockTime = block.number + _disableBlockTime;
        isConfigSet[_token] = true;
    }

    function onPreTransferCheck(
        address from,
        address to,
        uint256 amount
    ) public view returns (bool) {
        Config storage _config = configs[msg.sender];
        if (block.number >= _config.disableBlockTime) return true;
        require(
            whitelists[msg.sender][from] == true &&
                whitelists[msg.sender][to] == true,
            "Transfer between not whitelisted users"
        );
        require(amount > 0 && amount <= _config.limitAmount, "Invalid Amount");
        require(
            block.timestamp.sub(_config.preTransferTime) >= _config.limitTime,
            "Not Transfer Time"
        );
        return true;
    }

    function getCurrrentBlock() public view returns (uint256) {
        return block.number;
    }
}
