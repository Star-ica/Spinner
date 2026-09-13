// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SpinReward {
    mapping(address => uint256) public balances; // User balances
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

    // Stake a specified amount from the user's balance
    function stake(uint256 amount) external {
        require(amount > 0, "Stake amount must be greater than zero.");
        require(balances[msg.sender] >= amount, "Insufficient balance to stake.");

        balances[msg.sender] -= amount;
        emit Staked(msg.sender, amount);
    }

    // Process the spin result and calculate the reward
    function processSpinResult(uint256 stakedAmount, string memory result) external {
        require(balances[msg.sender] >= stakedAmount, "Insufficient balance to process spin.");
        
        balances[msg.sender] -= stakedAmount; // Deduct the staked amount initially

        if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked("Death"))) {
            // Handle "Death" case: User loses the entire stake
            contractBalance += stakedAmount;
            emit RewardCalculated(msg.sender, 0, result);
        } else if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked("2"))) {
            uint256 reward = (stakedAmount * 2) / 100;
            contractBalance -= reward;
            uint256 total = stakedAmount + reward;
            balances[msg.sender] += total;
            require(token.transfer(msg.sender, total), "Token transfer failed.");
            emit RewardCalculated(msg.sender, total, result);
        } else if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked("3"))) {
            uint256 reward = (stakedAmount * 3) / 100;
            contractBalance -= reward;
            uint256 total = stakedAmount + reward;
            balances[msg.sender] += total;
            require(token.transfer(msg.sender, total), "Token transfer failed.");
            emit RewardCalculated(msg.sender, total, result);
        } else if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked("-2")) ||
                   keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked("-3"))) {
            // Handle loss cases (-2, -3)
            contractBalance += stakedAmount;
            emit RewardCalculated(msg.sender, 0, result);
        } else if (keccak256(abi.encodePacked(result)) == keccak256(abi.encodePacked("Draw"))) {
            uint256 halfStake = stakedAmount / 2; // Half of the stake is returned
            balances[msg.sender] += halfStake;
            contractBalance += halfStake;
            require(token.transfer(msg.sender, halfStake), "Token transfer failed.");
            emit RewardCalculated(msg.sender, halfStake, result);
        } else {
            // Default case: No reward or penalty
            balances[msg.sender] += stakedAmount;
            require(token.transfer(msg.sender, stakedAmount), "Token transfer failed.");
            emit RewardCalculated(msg.sender, stakedAmount, result);
        }
    }

    // Withdraw funds from the user's balance with a 2% fee
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
