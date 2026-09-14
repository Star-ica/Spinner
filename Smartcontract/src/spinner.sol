// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SpinReward {
    mapping(address => uint256) public balances; // User balances (claimable)
    uint256 public contractBalance; // Contract's total balance (tracked separately)
    address public owner; // Contract owner
    IERC20 public token; // Token interface
    uint256 public withdrawalFeePercent = 2; // 2% fee on withdrawals

    event Funded(address indexed user, uint256 amount);
    event Staked(address indexed user, uint256 amount);
    event RewardCalculated(address indexed user, uint256 reward, string result);
    event Withdraw(address indexed user, uint256 amount, uint256 fee);
    event ContractFunded(uint256 amount);
    event ContractWithdrawal(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action.");
        _;
    }

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
    }

    // Fund the user's balance
    function fund(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero.");
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed.");

        balances[msg.sender] += amount;
        emit Funded(msg.sender, amount);
    }

    // Add funds directly to the contract balance (owner only)
    function addFundsToContract(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero.");
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed.");

        contractBalance += amount;
        emit ContractFunded(amount);
    }

    // Withdraw funds from the contract balance (owner only)
    function withdrawFromContract(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero.");
        require(contractBalance >= amount, "Insufficient contract balance.");

        contractBalance -= amount;
        require(token.transfer(owner, amount), "Token transfer failed.");
        emit ContractWithdrawal(amount);
    }

    // Process the spin result and calculate the reward.
    // IMPORTANT: this now only ever moves the internal `balances` ledger.
    // No tokens leave the contract here — wins are *credited*, not paid.
    // Players claim by calling withdraw(), same as any other balance.
    function processSpinResult(uint256 stakedAmount, string memory result) external {
        require(balances[msg.sender] >= stakedAmount, "Insufficient balance to process spin.");

        balances[msg.sender] -= stakedAmount; // Deduct the staked amount initially

        bytes32 r = keccak256(abi.encodePacked(result));

        if (r == keccak256(abi.encodePacked("Death"))) {
            // User loses the entire stake — it becomes house funds.
            contractBalance += stakedAmount;
            emit RewardCalculated(msg.sender, 0, result);

        } else if (r == keccak256(abi.encodePacked("2"))) {
            uint256 reward = (stakedAmount * 2) / 100;
            uint256 total = stakedAmount + reward;
            contractBalance -= reward; // reward is funded out of the house pot
            balances[msg.sender] += total; // credited, not transferred — claim via withdraw()
            emit RewardCalculated(msg.sender, total, result);

        } else if (r == keccak256(abi.encodePacked("3"))) {
            uint256 reward = (stakedAmount * 3) / 100;
            uint256 total = stakedAmount + reward;
            contractBalance -= reward;
            balances[msg.sender] += total; // credited, not transferred — claim via withdraw()
            emit RewardCalculated(msg.sender, total, result);

        } else if (r == keccak256(abi.encodePacked("-2")) || r == keccak256(abi.encodePacked("-3"))) {
            // Loss cases: stake becomes house funds, same as Death.
            contractBalance += stakedAmount;
            emit RewardCalculated(msg.sender, 0, result);

        } else if (r == keccak256(abi.encodePacked("Draw"))) {
            uint256 halfStake = stakedAmount / 2; // Half of the stake is returned
            balances[msg.sender] += halfStake; // credited, not transferred
            contractBalance += halfStake;       // the other half goes to the house
            emit RewardCalculated(msg.sender, halfStake, result);

        } else {
            // Default case: stake is simply returned to the claimable balance.
            balances[msg.sender] += stakedAmount;
            emit RewardCalculated(msg.sender, stakedAmount, result);
        }
    }

    // Withdraw funds from the user's balance with a 2% fee.
    // This is now the ONLY path real tokens take to leave the contract
    // and reach a player — including their winnings.
    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero.");
        require(balances[msg.sender] >= amount, "Insufficient balance to withdraw.");

        uint256 fee = (amount * withdrawalFeePercent) / 100; // 2% fee
        uint256 amountAfterFee = amount - fee;

        balances[msg.sender] -= amount;
        contractBalance += fee;

        require(token.transfer(msg.sender, amountAfterFee), "Token transfer failed.");
        emit Withdraw(msg.sender, amountAfterFee, fee);
    }
}
