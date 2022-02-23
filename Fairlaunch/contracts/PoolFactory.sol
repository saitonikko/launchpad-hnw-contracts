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
    uint256 public createFee;

    address payable public feeWallet;
    IPinkLock lock;

    uint256 public tvl;
    uint256 public curPool;

    event CreatePool(address pool);

    constructor() {
        fees[0] = 2;
        fees[1] = 2;
        createFee = 3 * 10**17;
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

    function getCreateFee() public view returns (uint256) {
        return createFee;
    }

    function setValues(
        uint256 _tokenFee,
        uint256 _ethFee,
        uint256 _createFee,
        address payable _newFeeWallet
    ) external onlyOwner {
        fees[0] = _tokenFee;
        fees[1] = _ethFee;
        createFee = _createFee;
        feeWallet = _newFeeWallet;
    }

    function removePoolForToken(address token, address pool) external {
        isExisting[token] = false;
    }

    function createPool(
        address[4] memory _addrs, // [0] = owner, [1] = token, [2] = router, [3] = governance
        uint256[2] memory _capSettings, // [0] = soft cap, [1] = hard cap
        uint256[3] memory _timeSettings, // [0] = start, [1] = end, [2] = unlock seconds
        uint256 _saletoken,
        uint256[5] memory _teamVestings,
        string memory _urls,
        uint256 _liquidityPercent,
        uint256[2] memory _refundType,
        string memory _poolDetails // ERC20 _rewardToken
    ) external payable {
        require(createFee >= msg.value, 'not enough Fee');
        uint256 totaltoken = _saletoken + _saletoken.mul(_liquidityPercent).div(100);

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
                _capSettings,
                _timeSettings,
                totaltoken,
                fees,
                _teamVestings,
                _urls,
                _liquidityPercent,
                _refundType,
                _poolDetails,
                lock
            );
            emit CreatePool(address(pool));
        }
    }

    function removeStuckBNB() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}
}
