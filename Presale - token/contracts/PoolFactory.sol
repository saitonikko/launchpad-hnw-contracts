// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
import "./Pool.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract PoolFactory is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address[] public pools;

    mapping(address => bool) public isExisting;

    uint256[2] public fees;

    address payable public feeWallet;
    IPinkLock lock;

    uint256 public tvl;
    uint256 public curPool;

    constructor() {
        fees[0] = 2;
        fees[1] = 2;
        tvl = 0;
        feeWallet = payable(0xC2a5ea1d4406EC5fdd5eDFE0E13F59124C7e9803);
        lock = IPinkLock(0xb5fbCFfd664Ad994f12878c85206e96Aa71AaD87);
    }

    function getPools() public view returns (address[] memory a) {
        return pools;
    }

    function getFees() public view returns (uint256[2] memory a) {
        return fees;
    }

    function setValues(
        uint256 _newfee1,
        uint256 _newfee2,
        address payable _newFeeWallet
    ) external onlyOwner {
        fees[0] = _newfee1;
        fees[1] = _newfee2;
        feeWallet = _newFeeWallet;
    }

    function removePoolForToken(address token, address pool) external {
        isExisting[token] = false;
    }

    function estimateTokenAmount(
        uint256[2] memory _rateSettings,
        uint256[2] memory _capSettings,
        uint256 _liquidityPercent,
        uint256 _teamtoken
    ) public view returns (uint256) {
        uint256 tokenamount = _rateSettings[0]
            .mul(_capSettings[1])
            .mul(100)
            .div(100 - fees[0])
            .div(1e18);

        uint256 liquidityBnb = _capSettings[1]
            .mul(_liquidityPercent)
            .div(100)
            .mul(_rateSettings[1]);
        uint256 liquidityToken = liquidityBnb.div(1e18).mul(100).div(
            100 - fees[1]
        );

        uint256 totaltoken = tokenamount + liquidityToken + _teamtoken;

        return totaltoken;
    }

    function createPool(
        address[5] memory _addrs, // [0] = owner, [1] = token, [2] = router, [3] = governance, [4] = cointoken
        uint256[2] memory _rateSettings, // [0] = rate, [1] = uniswap rate
        uint256[2] memory _contributionSettings, // [0] = min, [1] = max
        uint256[2] memory _capSettings, // [0] = soft cap, [1] = hard cap
        uint256[3] memory _timeSettings, // [0] = start, [1] = end, [2] = unlock seconds
        uint256[3] memory _vestings,
        uint256[5] memory _teamVestings,
        string memory _urls,
        uint256 _liquidityPercent,
        uint256 _refundType,
        string memory _poolDetails // ERC20 _rewardToken
    ) external payable {
        uint256 totaltoken = estimateTokenAmount(
            _rateSettings,
            _capSettings,
            _liquidityPercent,
            _teamVestings[0]
        );

        if (isExisting[_addrs[1]] == false) {
            Pool pool = new Pool();
            pools.push(address(pool));
            for (uint256 i = pools.length - 1; i > 0; i--)
                pools[i] = pools[i - 1];
            pools[0] = address(pool);
            isExisting[_addrs[1]] = true;

            IERC20(_addrs[1]).approve(address(pool), totaltoken);

            IERC20(_addrs[1]).transferFrom(
                msg.sender,
                address(pool),
                totaltoken
            );

            pool.initialize(
                _addrs,
                _rateSettings,
                _contributionSettings,
                _capSettings,
                _timeSettings,
                fees,
                _vestings,
                _teamVestings,
                _urls,
                _liquidityPercent,
                _refundType,
                _poolDetails,
                lock
            );
        }
    }

    receive() external payable {}
}
