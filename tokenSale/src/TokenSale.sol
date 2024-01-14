// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";


error MaxCapReached(string _msg);
error NotWhiteListed(address _user);
error NotWithinContributionBounds(uint256 amount, uint256 minContribution, uint256 maxContribution);

/**
 * @title TokenSale Contract
 * @notice This contract manages a token sale with a whitelist, different sale stages, and refund functionality.
 * @dev This contract uses the OpenZeppelin Ownable and IERC20 contracts.
 */
contract TokenSale is Ownable {

    // Events
    event PreSaleStarted(uint256 timeStamp);
    event PreSaleEnded(uint256 timeStamp, uint256 amountRaised);

    event PublicSaleStarted(uint256 timeStamp);
    event PublicSaleEnded(uint256 timeStamp, uint256 amountRaised);

    event ClaimedRefund(address indexed contributor, uint256 amount);
    event Bought(address indexed contributor, uint256 ethAmount, uint256 amountOfTokensBought);

    // Enum for sale stages
    enum SaleStage{
        NotStarted,
        PreSaleOpen,
        PreSaleEnded,
        PublicSaleOpen,
        PublicSaleEnded
    }

    //storage
    mapping (address => bool) public whiteList;
    mapping (address => uint256) public contributions;

    SaleStage public status;

    IERC20 public token;

    uint public immutable minimumCapToRaiseInPresale;
    uint public immutable maximumCapToRaiseInPreSale;
    uint public immutable minimumCapToRaiseInPublicSale;
    uint public immutable maximumCapToRaiseInPublicSale;

    uint public constant MIN_CONTRIBUTION_PRESALE = 2 * 1e16;
    uint public constant MAX_CONTRIBUTION_PRESALE = 2 * 1e18;
    uint public constant MIN_CONTRIBUTION_PUBLIC_SALE = 1e16;
    uint public constant MAX_CONTRIBUTION_PUBLIC_SALE = 1e18;

    uint public amountRaisedInPreSale;
    uint public amountRaisedInPublicSale;

    uint public constant preSaleExchangeRate = 2000;
    uint public constant publicSaleExchangeRate = 1500;

    bool private enableRefunds;

    /**
     * @param _minimumCapToRaiseInPresale Minimum capital to be raised in presale
     * @param _maximumCapToRaiseInPreSale Maximum capital to be raised in presale
     * @param _minimumCapToRaiseInPublicSale Minimum capital to be raised in public sale
     * @param _maximumCapToRaiseInPublicSale Maximum capital to be raised in public sale
     * @param initialOwner Initial owner of contract
     * @param _token Address of token to be sold
     */
    constructor(
        uint _minimumCapToRaiseInPresale, 
        uint _maximumCapToRaiseInPreSale,
        uint _minimumCapToRaiseInPublicSale,
        uint _maximumCapToRaiseInPublicSale, 
        address initialOwner,
        address _token
    ) Ownable(initialOwner) {
        minimumCapToRaiseInPresale = _minimumCapToRaiseInPresale;
        maximumCapToRaiseInPreSale = _maximumCapToRaiseInPreSale;
        minimumCapToRaiseInPublicSale = _minimumCapToRaiseInPublicSale;
        maximumCapToRaiseInPublicSale = _maximumCapToRaiseInPublicSale; 
        status = SaleStage.NotStarted; //Setting sale stage to NotStarted
        enableRefunds = false; // Initially disabling the refunds
        token = IERC20(_token); 
    }
    /**
     * @notice Modifier for contributor specific functions
     */
    modifier onlyContributor(){
        require(contributions[msg.sender] != 0, "Not a contributor");
        _;
    }

    receive() external payable{}

    fallback() external payable{}

    /**
     * @dev Only callable by owner when pre sale is ended
     * @notice Starts pre sale stage
     */
    function startPreSale() external onlyOwner {
        require(status == SaleStage.NotStarted, "Invalid sale stage");
        status = SaleStage.PreSaleOpen;
        emit PreSaleStarted(block.timestamp);
    }

    /**
     * @dev Only callable by owner when pre sale is open
     * @notice Ends pre sale stage and enables refunds if min cap is not reached
     */
    function endPreSale() external onlyOwner{
        require(status == SaleStage.PreSaleOpen, "Presale is not open");
        status = SaleStage.PreSaleEnded;
        enableRefunds = minimumCapToRaiseInPresale > amountRaisedInPreSale ? true : false;
        emit PreSaleEnded(block.timestamp, amountRaisedInPreSale);
    }

    /**
     * @dev Only callable by owner when pre sale is ended
     * @notice Starts public sale stage and disables refunds
     */
    function startPublicSale() external onlyOwner{
        require(status == SaleStage.PreSaleEnded, "Invalid sale stage");
        status = SaleStage.PublicSaleOpen;
        enableRefunds = false;
        emit PublicSaleStarted(block.timestamp);
    }

    /**
     * @dev Only callable by owner when public sale is open
     * @notice Ends public sale stage and enables refunds if min cap is not reached
     */
    function endPublicSale() external onlyOwner{
        require(status == SaleStage.PublicSaleOpen, "Public sale is not open");
        status = SaleStage.PublicSaleEnded;
        if(minimumCapToRaiseInPublicSale > amountRaisedInPublicSale || minimumCapToRaiseInPresale > amountRaisedInPreSale){
            enableRefunds = true;
        }
        emit PublicSaleEnded(block.timestamp, amountRaisedInPublicSale);
    }

    /**
     * @param users list of users to be whitelisted
     * @notice only callable by owner
     */
    function addWhitelistedUsers(address[] memory users) external onlyOwner{
        require(status == SaleStage.NotStarted, "Sale has started");
        for(uint i = 0; i < users.length; i++){
            whiteList[users[i]] = true;
        }
    }

    /**
     * @param amount Amount of tokens to be deposited
     * @notice Deposits tokens to contract
     */
    function fundContractWithTokens(uint256 amount) external onlyOwner{
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");
    }

    /**
     * @notice Withdraws the Ether from the contract to the owner
     * @notice only callable by owner
     * @notice will only allow withdrawal if sales are ended and refunds are not valid
     */
    function withdraw() external onlyOwner{
        require(status == SaleStage.PublicSaleEnded, "Sales are not over yet");
        require(!enableRefunds, "refunds are issuable");
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * @notice Withdraws the tokens from the contract to the owner
     * @notice only callable by owner
     * @notice will only allow withdrawal if sales are ended and refunds are not valid
     */
    function withdrawRemainingTokens() external onlyOwner{
        require(status == SaleStage.PublicSaleEnded, "Sales are not over yet");
        require(!enableRefunds, "refunds are issuable");
        bool success = token.transfer(msg.sender, token.balanceOf(address(this)));
        require(success, "Transfer failed");
    }

    /**
     * @notice Buys tokens with Ether, can be called by anyone
     * @notice checks requirements by an internal call to _preRequirementChecks
     */
    function buyTokens() public payable {
        if(status == SaleStage.NotStarted || status == SaleStage.PreSaleEnded || status == SaleStage.PublicSaleEnded){
            revert("Sale not open");
        }
        _preRequirementChecks(msg.sender, msg.value);

        /// record the contribution by contributor
        contributions[msg.sender] += msg.value;

        /// increment amounts collected
        if(status == SaleStage.PreSaleOpen){
            amountRaisedInPreSale += msg.value;
        }else{
            amountRaisedInPublicSale += msg.value;
        }

        /// getting amount of tokens to be sent according to fixed rate and transferring tokens
        uint256 amountOfTokenToBeSent = _getAmountOfTokenToBeSent(msg.value);
        bool success = token.transfer(msg.sender, amountOfTokenToBeSent);
        require(success,"Failed to send");

        emit Bought(msg.sender, msg.value, amountOfTokenToBeSent);
    }

    /**
     * @notice Distributes funds to a specific account, can only be called by the owner
     * @param account Address to which funds will be sent
     * @param amount Amount of funds to be sent
     */
    function distributeFundsToSpecificAccount(address account, uint256 amount) external onlyOwner{
        bool success = token.transfer(account, amount);
        require(success, "Failed to send");
    }

    /**
     * @notice Claims a refund, can only be called by contributors during refund period
     */
    function claimRefund() external onlyContributor{
        require(enableRefunds, "Refunds are not issuable now");
        uint256 amount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit ClaimedRefund(msg.sender, amount);
    }

    /**
     * @dev Calculates the amount of tokens to be sent based on the provided Ether amount
     * @param ethAmount Amount of Ether sent
     * @return tokenAmountToBeSent Amount of tokens to be sent
     */
    function _getAmountOfTokenToBeSent(uint256 ethAmount) internal view returns(uint256 tokenAmountToBeSent){
        uint256 exchangeRate = status == SaleStage.PreSaleOpen ? preSaleExchangeRate : publicSaleExchangeRate;
        tokenAmountToBeSent = ethAmount*exchangeRate;
    }

    /**
     * @dev Checks pre-sale or public sale requirements before processing a token purchase
     * @param contributor Address of the contributor
     * @param amount Amount of Ether sent by the contributor
     * @notice Reverts if Max cap is reached
     * @notice Reverts if not whitelisted user tries to buy during presale
     * @notice Reverts if amount is less than minimum or more than maximum
     */
    function _preRequirementChecks(address contributor, uint256 amount) internal view{
        if(status == SaleStage.PreSaleOpen){

            if((amountRaisedInPreSale + amount) > maximumCapToRaiseInPreSale){
                revert MaxCapReached("Max cap for Presale is reached");
            }

            if(!whiteList[contributor]){
                revert NotWhiteListed(contributor);
            }

            if(amount < MIN_CONTRIBUTION_PRESALE || amount > MAX_CONTRIBUTION_PRESALE){
                revert NotWithinContributionBounds(
                    amount,
                    MIN_CONTRIBUTION_PRESALE, 
                    MAX_CONTRIBUTION_PRESALE
                );
            }

        } else if(status == SaleStage.PublicSaleOpen){

            if((amountRaisedInPublicSale + amount) > maximumCapToRaiseInPublicSale){
                revert MaxCapReached("Max cap for public sale is reached");
            }

            if(amount < MIN_CONTRIBUTION_PUBLIC_SALE || amount > MAX_CONTRIBUTION_PUBLIC_SALE){
                revert NotWithinContributionBounds(
                    amount, 
                    MIN_CONTRIBUTION_PUBLIC_SALE, 
                    MAX_CONTRIBUTION_PUBLIC_SALE
                );
            }

        }
    }

}