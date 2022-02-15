// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../../tokens/AntiBotBuybackBabyToken.sol";

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../../interfaces/IFactoryManager.sol";

contract TokenFactoryBase is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address payable;

    address public factoryManager;
    address public implementation;
    address public feeTo;
    uint256 public flatFee;

    event TokenCreated(
        address indexed owner,
        address indexed token,
        uint8 tokenType
    );

    modifier enoughFee() {
        require(msg.value >= flatFee, "Flat fee");
        _;
    }

    constructor(address factoryManager_, address implementation_) {
        factoryManager = factoryManager_;
        implementation = implementation_;
        feeTo = msg.sender;
        flatFee = 10_000_000 gwei;
    }

    function setImplementation(address implementation_) external onlyOwner {
        implementation = implementation_;
    }

    function setFeeTo(address feeReceivingAddress) external onlyOwner {
        feeTo = feeReceivingAddress;
    }

    function setFlatFee(uint256 fee) external onlyOwner {
        flatFee = fee;
    }

    function assignTokenToOwner(
        address owner,
        address token,
        uint8 tokenType
    ) internal {
        IFactoryManager(factoryManager).assignTokensToOwner(
            owner,
            token,
            tokenType
        );
    }

    function refundExcessiveFee() internal {
        uint256 refund = msg.value.sub(flatFee);
        if (refund > 0) {
            payable(msg.sender).sendValue(refund);
        }
    }
}

contract AntiBotBuyBackBabyTokenFactory is TokenFactoryBase {
    using Address for address payable;

    constructor(address factoryManager_, address implementation_)
        TokenFactoryBase(factoryManager_, implementation_)
    {}

    function create(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        address rewardToken_,
        address router_,
        address antiBot_,
        uint256[5] memory feeSettings_
    ) external payable enoughFee nonReentrant returns (address) {
        refundExcessiveFee();
        payable(feeTo).sendValue(flatFee);
        AntiBotBuybackBabyToken btoken = new AntiBotBuybackBabyToken(
            msg.sender,
            name_,
            symbol_,
            totalSupply_,
            rewardToken_,
            router_,
            antiBot_,
            feeSettings_
        );
        btoken.transferOwnership(payable(msg.sender));
        assignTokenToOwner(msg.sender, address(btoken), 7);
        emit TokenCreated(msg.sender, address(btoken), 7);
        return address(btoken);
    }
}
