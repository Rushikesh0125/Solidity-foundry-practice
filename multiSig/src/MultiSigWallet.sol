// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title MultiSigWallet
 * @dev A multi-signature wallet contract allowing multiple owners to jointly manage and execute transactions.
 * Owners can submit transactions, confirm them, and execute them based on a minimum required number of confirmations.
 */
contract MultiSigWallet {

    // Events emitted by the contract
    event Deposit(
        address indexed sender, 
        uint amount, 
        uint balance
    );
    event TransactionSubmitted(
        address indexed msgSender,
        uint indexed txId,
        address indexed to,
        uint value,
        bytes data
    );
    event TransactionConfirmed(
        address indexed msgSender, 
        uint indexed txId
    );
    event ConfirmationRevoked(
        address indexed msgSender, 
        uint indexed txId
    );
    event TransactionExecuted(
        address indexed msgSender,
        uint indexed txId
    );

    // State variables
    address[] public walletOwners;
    uint public immutable minRequiredConfirmations;
    uint constant public maxOwnerCount = 25;
    uint public transactionCount;

    // Transaction-related mappings
    mapping(uint => Transaction) public transactions1;
    mapping(address => bool) public isOwner;
    mapping(uint => mapping(address => bool)) public isConfirmed;

    // Struct to represent a transaction
    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    // Modifiers to enforce access control and transaction conditions
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txId) {
        require(transactions1[_txId].to != address(0), "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint _txId) {
        require(!transactions1[_txId].executed, "tx is already executed");
        _;
    }

    modifier notConfirmed(uint _txId) {
        require(!isConfirmed[_txId][msg.sender], "tx is already confirmed");
        _;
    }

    /**
     * @dev Contract constructor.
     * @param _owners Addresses of the initial wallet owners.
     * @param _minRequiredConfirmations Minimum number of confirmations required to execute a transaction.
     */
    constructor(address[] memory _owners, uint _minRequiredConfirmations) {
        require(_owners.length > 1, "MultiSig wallet requires at least 2 owners");
        require(_owners.length <= maxOwnerCount, "Maximum Owners limit:10");
        require(
            _minRequiredConfirmations > 0 &&
                _minRequiredConfirmations <= _owners.length,
            "invalid number of required confirmations"
        );

        // Initialize owners and required confirmations
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            walletOwners.push(owner);
        }

        minRequiredConfirmations = _minRequiredConfirmations;
        transactionCount = 0;
    }

    /**
     * @dev Fallback function to receive Ether.
     */
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    /**
     * @notice Submits a new transaction to the wallet.
     * @param _to Target address for the transaction.
     * @param _value Amount of Ether to send in the transaction.
     * @param _data Data payload for the transaction.
     * @return txId transaction id
     */
    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) external onlyOwner returns(uint txId){
        txId = transactionCount;

        transactions1[txId] = Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0
        });

        emit TransactionSubmitted(msg.sender, txId, _to, _value, _data);
    }

    /**
     * @notice Confirms a transaction by an owner.
     * @param _txId ID of the transaction to confirm.
     */
    function confirmTransaction(
        uint _txId
    ) external onlyOwner txExists(_txId) notExecuted(_txId) notConfirmed(_txId) {
        Transaction storage transaction = transactions1[_txId];
        transaction.numConfirmations += 1;
        isConfirmed[_txId][msg.sender] = true;

        emit TransactionConfirmed(msg.sender, _txId);
    }

    /**
     * @notice Executes a confirmed transaction.
     * @param _txId ID of the transaction to execute.
     */
    function executeTransaction(
        uint _txId
    ) external onlyOwner txExists(_txId) notExecuted(_txId) {
        Transaction storage transaction = transactions1[_txId];

        require(
            transaction.numConfirmations >= minRequiredConfirmations,
            "cannot execute tx"
        );

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "tx failed");

        emit TransactionExecuted(msg.sender, _txId);
    }

    /**
     * @notice Revokes a previously confirmed transaction.
     * @param _txId ID of the transaction to revoke confirmation.
     */
    function revokeConfirmation(
        uint _txId
    ) external onlyOwner txExists(_txId) notExecuted(_txId) {
        Transaction storage transaction = transactions1[_txId];

        require(isConfirmed[_txId][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txId][msg.sender] = false;

        emit ConfirmationRevoked(msg.sender, _txId);
    }

    /**
     * @notice Gets the addresses of all wallet owners.
     * @return Array of wallet owner addresses.
     */
    function getOwners() external view returns (address[] memory) {
        return walletOwners;
    }

    /**
     * @notice Gets details of a specific transaction.
     * @param _txId ID of the transaction.
     * @return to destination address
     * @return value value of transaction
     * @return data tx data
     * @return executed status 
     * @return numConfirmations number of confirmations
     */
    function getTransaction(
        uint _txId
    )
        external
        view
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations
        )
    {
        Transaction storage transaction = transactions1[_txId];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}
