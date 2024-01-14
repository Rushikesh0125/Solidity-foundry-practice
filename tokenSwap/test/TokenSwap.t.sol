// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {TokenSwap} from "../src/TokenSwap.sol";
import { ERC20Mock } from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

/**
 * @title Test cases for TokenSwap
 * @notice All testcases with prefix test are meant to pass when ideal conditions are followed
 * @notice All testcases with prefix testFail are meant to pass when contract execution reverts on not followinf ideal 
 */
contract TokenSwapTest is Test{
    TokenSwap swapContract;
    ERC20Mock tokenA;
    ERC20Mock tokenB;

    address liquidityProvider = makeAddr("liquidityProvider");
    address user = makeAddr("user");

    /// @notice Setup for tests
    /// @notice Creates Mock ERC20s, Instance of Swap contract, and mints tokens to test actors
    function setUp() public {
        tokenA = new ERC20Mock();
        tokenB = new ERC20Mock();
        swapContract = new TokenSwap(address(tokenA), address(tokenB), 50);

        tokenA.mint(liquidityProvider, 1e25);
        tokenB.mint(liquidityProvider, 1e25);

        tokenA.mint(user, 1e25);
        tokenB.mint(user, 1e25);

    }

    /// @notice test for adding liquidity for both tokens
    /// @notice Checks balance of liquidity provider and swap contract before and after function execution
    function testAddLiquidity() public {
        vm.startPrank(liquidityProvider);
        tokenA.approve(address(swapContract), 1e25);
        assertEq(tokenA.balanceOf(liquidityProvider), 1e25);
        swapContract.addLiquidityForTokenA(1e25);
        assertEq(tokenA.balanceOf(liquidityProvider), 0);
        assertEq(tokenA.balanceOf(address(swapContract)), 1e25);

        tokenB.approve(address(swapContract), 1e25);
        assertEq(tokenB.balanceOf(liquidityProvider), 1e25);
        swapContract.addLiquidityForTokenB(1e25);
        assertEq(tokenB.balanceOf(liquidityProvider), 0);
        assertEq(tokenB.balanceOf(address(swapContract)), 1e25);
        vm.stopPrank();
    }

    /// @notice tests swapping of token A in return of token B
    /// @notice according to fixed rate, amount of token B user received should be 2 times of amount of token A swapped in by user
    function testSwapTokenAForTokenB() public {
        vm.startPrank(liquidityProvider);
        tokenA.approve(address(swapContract), 1e25);
        swapContract.addLiquidityForTokenA(1e25);

        tokenB.approve(address(swapContract), 1e25);
        swapContract.addLiquidityForTokenB(1e25);
        vm.stopPrank();

        vm.startPrank(user);
        uint256 balanceBefore = tokenB.balanceOf(user);
        tokenA.approve(address(swapContract), 10*1e18);
        bool success = swapContract.swapTokenAForTokenB(10*1e18);
        require(success);
        uint256 balanceAfter = tokenB.balanceOf(user);
        assertEq(balanceAfter - balanceBefore, 20*1e18);
    }

    /// @notice Fuzz test for swapping of token B in return of token A
    /// @notice according to fixed rate, amount of token A user received should be 1/2 times of amount of token B swapped in by user
    function testSwapTokenBForTokenA(uint256 _amount) public {
        
        vm.startPrank(liquidityProvider);
        tokenA.approve(address(swapContract), 1e25);
        swapContract.addLiquidityForTokenA(1e25);

        tokenB.approve(address(swapContract), 1e25);
        swapContract.addLiquidityForTokenB(1e25);
        vm.stopPrank();

        _amount = uint64(bound(_amount, 0, 1e25));

        vm.startPrank(user);
        uint256 balanceBefore = tokenA.balanceOf(user);
        tokenB.approve(address(swapContract), _amount);
        bool success = swapContract.swapTokenBForTokenA(_amount);
        require(success);
        uint256 balanceAfter = tokenA.balanceOf(user);
        assertEq(balanceAfter - balanceBefore, _amount/2);
    }

    /// @notice Test for testing InsufficientUserFunds Error
    /// @notice Tests against insufficient balance of user
    function testFailSwapTokenAForTokenBInsufficientUserFunds() public {
        vm.startPrank(liquidityProvider);
        tokenA.approve(address(swapContract), 1e25);
        swapContract.addLiquidityForTokenA(1e25);

        tokenB.approve(address(swapContract), 1e25);
        swapContract.addLiquidityForTokenB(1e25);
        vm.stopPrank();

        vm.startPrank(user);
        uint256 balanceBefore = tokenB.balanceOf(user);
        tokenA.approve(address(swapContract), 1e25);
        //burning few tokens from user balance before function call
        tokenA.burn(user, 5*1e18);
        bool success = swapContract.swapTokenAForTokenB(1e25);
        require(success);
        uint256 balanceAfter = tokenB.balanceOf(user);
        assertEq(balanceAfter - balanceBefore, 20*1e18);
    }

    /// @notice Test for testing InsufficientLiquidity Error
    /// @notice Providing such a input that there are no enough tokens to return 
    /// @notice swapping token A in for token B
    ///         contract should have balance - 2n of token B if n is amount of token A swapped in
    function testFailSwapTokenAForTokenBInsufficientLiquidity() public {
        vm.startPrank(liquidityProvider);
        tokenA.approve(address(swapContract), 1e25);
        swapContract.addLiquidityForTokenA(1e25);

        tokenB.approve(address(swapContract), 2e25);
        swapContract.addLiquidityForTokenB(2e25);
        vm.stopPrank();

        vm.startPrank(user);
        uint256 balanceBefore = tokenB.balanceOf(user);
        tokenA.approve(address(swapContract), 1e25);
        bool success = swapContract.swapTokenAForTokenB(1e25);
        require(success);
        uint256 balanceAfter = tokenB.balanceOf(user);
        assertEq(balanceAfter - balanceBefore, 1e25);

    }


}