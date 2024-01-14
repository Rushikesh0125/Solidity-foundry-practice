// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

error InsufficientUserBalance();
error InsufficientLiquidity();


/**
 * @title TokenSwap
 * @dev A decentralized token swapping contract facilitating exchanges between Token A and Token B.
 */
contract TokenSwap {

    using SafeERC20 for IERC20;

    IERC20 immutable public tokenA;
    IERC20 immutable public tokenB;

    /// @notice EXCHANGE_RATE - Number of token A in return for 100 Token 
    uint256 immutable public EXCHANGE_RATE;

    /// @notice DIVISION_FACTOR - as we are compairing token A with respect to 100 B tokens
    uint256 constant public DIVISION_FACTOR = 100;

    event Swapped(
        address indexed user, 
        address indexed tokenIn, 
        address tokenOut, 
        uint256 amountTokenIn, 
        uint256 amountTokenOut, 
        bool status
    );

    /**
     * @dev Contract constructor.
     * @param _tokenA Address of Token A.
     * @param _tokenB Address of Token B.
     * @param _exchangeRate Number of Token A for 100 units of Token B.
     */
    constructor(address _tokenA, address _tokenB, uint256 _exchangeRate) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        EXCHANGE_RATE = _exchangeRate;
    }

    /**
     * @notice Swaps Token A for Token B.
     * @param amountIn Amount of Token A.
     * @return Status of the swap.
     */
    function swapTokenAForTokenB(uint256 amountIn) external returns (bool) {
        if(tokenA.balanceOf(msg.sender) < amountIn) revert InsufficientUserBalance();

        uint256 amountTokenOut = getExchangeAmount(tokenA, amountIn);
        if(tokenB.balanceOf(address(this)) < amountTokenOut) revert InsufficientLiquidity();

        tokenA.safeTransferFrom(msg.sender, address(this), amountIn);
        tokenB.safeTransfer(msg.sender, amountTokenOut);

        emit Swapped(msg.sender, address(tokenA), address(tokenB), amountIn, amountTokenOut, true);
        return true;
    }

    /**
     * @notice Swaps Token B for Token A.
     * @param amountIn Amount of Token B.
     * @return Status of the swap.
     */
    function swapTokenBForTokenA(uint256 amountIn) external returns (bool) {
        if(tokenB.balanceOf(msg.sender) < amountIn) revert InsufficientUserBalance();

        uint256 amountTokenOut = getExchangeAmount(tokenB, amountIn);
        if(tokenA.balanceOf(address(this)) < amountTokenOut) revert InsufficientLiquidity();

        tokenB.safeTransferFrom(msg.sender, address(this), amountIn);

        tokenA.safeTransfer(msg.sender, amountTokenOut);
    
        emit Swapped(msg.sender, address(tokenB), address(tokenA), amountIn, amountTokenOut, true);
        return true;
    }

    /**
     * @notice Adds liquidity for Token A.
     * @param amount Amount of Token A.
     */
    function addLiquidityForTokenA(uint256 amount) external {
        require(tokenA.balanceOf(msg.sender) >= amount,"Not enought balance");
        tokenA.safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @notice Adds liquidity for Token B.
     * @param amount Amount of Token B.
     */
    function addLiquidityForTokenB(uint256 amount) external {
        require(tokenB.balanceOf(msg.sender) >= amount,"Not enought balance");
        tokenB.safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @dev Calculates the exchange amount based on the specified token and amount.
     * @param tokenIn Token to be received.
     * @param amount Amount of the token being received.
     * @return exchangeAmount Exchange amount of the token to be sent.
     */
    function getExchangeAmount(IERC20 tokenIn, uint256 amount) internal view returns(uint256 exchangeAmount){
        bool tokenInIsTokenA = tokenIn == tokenA ? true : false;
        if(tokenInIsTokenA){
            exchangeAmount = (amount * DIVISION_FACTOR)/EXCHANGE_RATE;
        }else{
            exchangeAmount = (amount * EXCHANGE_RATE)/DIVISION_FACTOR;
        }
    }


}