// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../../tokens/AntiBotLiquidityGeneratorToken.sol";

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
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

contract AntiBotLiquidityGeneratorTokenFactory is TokenFactoryBase {
    using Address for address payable;

    constructor(address factoryManager_, address implementation_)
        TokenFactoryBase(factoryManager_, implementation_)
    {}

    function create(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        address router,
        address charity,
        uint16 taxFeeBps,
        uint16 liquidityFeeBps,
        uint16 charityBps,
        address pinkAntiBot_
    ) external payable enoughFee nonReentrant returns (address) {
        refundExcessiveFee();
        payable(feeTo).sendValue(flatFee);
        AntiBotLiquidityGeneratorToken ltoken = new AntiBotLiquidityGeneratorToken(
            msg.sender,
            name,
            symbol,
            totalSupply,
            router,
            charity,
            taxFeeBps,
            liquidityFeeBps,
            charityBps,
            pinkAntiBot_
        );
        ltoken.transferOwnership(msg.sender);
        assignTokenToOwner(msg.sender, address(ltoken), 5);
        emit TokenCreated(msg.sender, address(ltoken), 5);
        return address(ltoken);
    }
}
