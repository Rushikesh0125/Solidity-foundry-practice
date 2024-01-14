// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {TokenSale} from "../src/TokenSale.sol";
import { ERC20Mock } from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

/**
 * @title Test cases for TokenSale
 * @notice All testcases with prefix test are meant to pass when ideal conditions are followed
 * @notice All testcases with prefix testFail are meant to pass when contract execution reverts on not followinf ideal 
 */
contract TokenSaleTest is Test{
    
    TokenSale public tokenSaleContract;
    address public owner;
    ERC20Mock public token;
    address[] whiteList = new address[](5);

    enum SaleStage{
        NotStarted,
        PreSaleOpen,
        PreSaleEnded,
        PublicSaleOpen,
        PublicSaleEnded
    }

    function setUp() public {
        owner = makeAddr("owner");
        token = new ERC20Mock();
        token.mint(owner,1_000_000_000*1 ether);
        tokenSaleContract = new TokenSale(5*1 ether, 7*1 ether, 2*1 ether, 4*1 ether, owner, address(token));
        vm.startPrank(owner);
        // funding contract with tokens
        token.approve(address(tokenSaleContract),100_000_000*1 ether);

        tokenSaleContract.fundContractWithTokens(100_000_000*1 ether);

        //whitelisting few users for preSale
        address user1 = makeAddr("user1");
        address user2 = makeAddr("user1");
        address user3 = makeAddr("user1");
        address user4 = makeAddr("user1");
        address user5 = makeAddr("user5");

        
        whiteList[0] = user1;
        whiteList[1] = user2;
        whiteList[2] = user3;
        whiteList[3] = user4;
        whiteList[4] = user5;

        tokenSaleContract.addWhitelistedUsers(whiteList);

        assertEq(token.balanceOf(address(tokenSaleContract)), 100_000_000*1 ether);
        assertEq(tokenSaleContract.whiteList(user1), true);
    }

    /**
     * @notice Test - start presale and buy tokens
     */
    function test_start_presale_and_buy_tokens() public{
        vm.startPrank(owner);
        
        tokenSaleContract.startPreSale();

        vm.stopPrank();

        address user1 = whiteList[0];

        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        (bool callSuccess,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPreSale(), 1e18);
        assertEq(tokenSaleContract.contributions(user1), 1e18);
        assertEq(token.balanceOf(user1),1e18*tokenSaleContract.preSaleExchangeRate());
        vm.stopPrank();
    }

    /**
     * @notice Test - buy tokens without starting presale should revert
     */
    function testFail_buy_tokens_without_starting_presale() public{
        
        // Not starting presale
        
        // vm.startPrank(owner);
        
        // tokenSaleContract.startPreSale();

        // vm.stopPrank();

        address user1 = whiteList[0];

        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        (bool callSuccess,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPreSale(), 1e18);
        assertEq(tokenSaleContract.contributions(user1), 1e18);
        vm.stopPrank();
    }

    /**
     * @notice Test - buy tokens with non whitelisted address should revert
     */
    function testFail_buying_tokens_by_non_whitelisted() public{
        vm.startPrank(owner);
        
        tokenSaleContract.startPreSale();

        vm.stopPrank();

        //random user
        address user1 = makeAddr("random non whitelist user");

        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        (bool callSuccess,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPreSale(), 1e18);
        assertEq(tokenSaleContract.contributions(user1), 1e18);
        vm.stopPrank();
    }

    /**
     * @notice Test - buy tokens with less than minimum contribution allowed should revert
     */
    function testFail_buying_tokens_with_less_than_minimum_contribution_allowed() public{
        vm.startPrank(owner);
        
        tokenSaleContract.startPreSale();

        vm.stopPrank();

        address user1 = whiteList[1];

        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        //Minimum contribution limit is 2*1e16
        (bool callSuccess,) = address(tokenSaleContract).call{value: 1e5}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPreSale(), 1e5);
        assertEq(tokenSaleContract.contributions(user1), 1e5);
        vm.stopPrank();
    }

    /**
     * @notice Test - buy tokens with more than maximum contribution allowed, should revert
     */
    function testFail_buying_tokens_with_more_than_max_contribution_allowed() public{
        vm.startPrank(owner);
        
        tokenSaleContract.startPreSale();

        vm.stopPrank();

        address user1 = whiteList[1];

        vm.startPrank(user1);
        vm.deal(user1, 5 ether);
        // Max contribution is 2 ether
        (bool callSuccess,) = address(tokenSaleContract).call{value: 4 ether}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPreSale(), 4 ether);
        assertEq(tokenSaleContract.contributions(user1), 4 ether);
        vm.stopPrank();
    }

    /**
     * @notice Test - buy tokens when maximum cap is exceeding, should revert
     */
    function testFail_buying_tokens_while_max_cap_exceeds() public{
        vm.startPrank(owner);
        
        tokenSaleContract.startPreSale();

        vm.stopPrank();

        address user1 = whiteList[1];

        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        (bool callSuccess,) = address(tokenSaleContract).call{value: 1 ether}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        vm.stopPrank();

        address user2 = whiteList[0];

        vm.startPrank(user2);
        vm.deal(user2, 5 ether);
        (bool callSuccess1,) = address(tokenSaleContract).call{value: 4 ether}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess1, "Call failed");
        vm.stopPrank();

        address user3 = whiteList[2];

        vm.startPrank(user3);
        vm.deal(user3, 5 ether);
        (bool callSuccess2,) = address(tokenSaleContract).call{value: 4 ether}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess2, "Call failed");
        vm.stopPrank();

        address user4 = whiteList[3];

        vm.startPrank(user4);
        vm.deal(user4, 5 ether);
        (bool callSuccess3,) = address(tokenSaleContract).call{value: 4 ether}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess3, "Call failed");
        vm.stopPrank();
    }

    /**
     * @notice Test - claim refund when less than minimum required capital is raised in presale
     */
    function test_amount_raised_is_less_than_min_capital_to_raise_refund_should_be_clamable() public{
        vm.startPrank(owner);
        
        tokenSaleContract.startPreSale();

        vm.stopPrank();

        address user1 = whiteList[0];

        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        (bool callSuccess,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPreSale(), 1e18);
        assertEq(tokenSaleContract.contributions(user1), 1e18);
        assertEq(token.balanceOf(user1),1e18*tokenSaleContract.preSaleExchangeRate());
        vm.stopPrank();

        vm.startPrank(owner);
        
        tokenSaleContract.endPreSale();

        vm.stopPrank();

        vm.startPrank(user1);

        tokenSaleContract.claimRefund();

        assertEq(tokenSaleContract.contributions(user1), 0);

        vm.stopPrank();

    }

    /**
     * @notice Test - Buy tokens when presale is ended, should revert
     */
    function testFail_buy_tokens_after_presale_ended() public{
        vm.startPrank(owner);
        
        tokenSaleContract.startPreSale();

        vm.stopPrank();

        address user1 = whiteList[0];

        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        (bool callSuccess,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPreSale(), 1e18);
        assertEq(tokenSaleContract.contributions(user1), 1e18);
        assertEq(token.balanceOf(user1),1e18*tokenSaleContract.preSaleExchangeRate());
        vm.stopPrank();

        vm.startPrank(owner);
        // ending presale
        tokenSaleContract.endPreSale();

        vm.stopPrank();

        address user2 = whiteList[2];

        vm.startPrank(user2);
        vm.deal(user2, 1 ether);
        (bool callSuccess2,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess2);
        vm.stopPrank();
    }

    /**
     * @notice Test - start public sale before ending pre sale, should revert.
     */
    function testFail_start_public_sale_before_ending_presale() public{
        vm.startPrank(owner);
        
        tokenSaleContract.startPreSale();

        vm.stopPrank();

        address user1 = whiteList[0];

        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        (bool callSuccess,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPreSale(), 1e18);
        assertEq(tokenSaleContract.contributions(user1), 1e18);
        assertEq(token.balanceOf(user1),1e18*tokenSaleContract.preSaleExchangeRate());
        vm.stopPrank();

        vm.startPrank(owner);
        // Not ending presale
        // tokenSaleContract.endPreSale();

        tokenSaleContract.startPublicSale();

        vm.stopPrank();

    }

    /**
     * @notice Test - start public sale and buy tokens
     */
    function test_start_public_sale_and_buy_tokens() public{
        vm.startPrank(owner);
        
        tokenSaleContract.startPreSale();

        vm.stopPrank();

        address user1 = whiteList[0];

        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        (bool callSuccess,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPreSale(), 1e18);
        assertEq(tokenSaleContract.contributions(user1), 1e18);
        assertEq(token.balanceOf(user1),1e18*tokenSaleContract.preSaleExchangeRate());
        vm.stopPrank();

        vm.startPrank(owner);
        // Ending presale
        tokenSaleContract.endPreSale();

        // Starting public sale 
        tokenSaleContract.startPublicSale();

        vm.stopPrank();

        address randomBuyer = makeAddr("Random buyer");

        vm.startPrank(randomBuyer);

        vm.deal(randomBuyer, 0.5 ether);

        (bool callSuccess1,) = address(tokenSaleContract).call{value: 1e16}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess1, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPublicSale(), 1e16);
        assertEq(tokenSaleContract.contributions(randomBuyer), 1e16);
        assertEq(token.balanceOf(randomBuyer),1e16*tokenSaleContract.publicSaleExchangeRate());
        vm.stopPrank();

    }   

    /**
     * @notice Test - amount raised in public sale less than minimum required to raise so can claim refund
     */
    function test_amount_raised_in_public_sale_less_tha_min_capital_to_raise_refund_should_be_claimable() public{
        vm.startPrank(owner);
        
        tokenSaleContract.startPreSale();

        vm.stopPrank();

        address user1 = whiteList[0];

        vm.startPrank(user1);
        vm.deal(user1, 1 ether);
        (bool callSuccess,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPreSale(), 1e18);
        assertEq(tokenSaleContract.contributions(user1), 1e18);
        assertEq(token.balanceOf(user1),1e18*tokenSaleContract.preSaleExchangeRate());
        vm.stopPrank();

        vm.startPrank(owner);
        // Ending presale
        tokenSaleContract.endPreSale();

        // Starting public sale 
        tokenSaleContract.startPublicSale();

        vm.stopPrank();

        address randomBuyer = makeAddr("Random buyer");

        vm.startPrank(randomBuyer);

        vm.deal(randomBuyer, 0.5 ether);

        (bool callSuccess1,) = address(tokenSaleContract).call{value: 1e16}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess1, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPublicSale(), 1e16);
        assertEq(tokenSaleContract.contributions(randomBuyer), 1e16);
        assertEq(token.balanceOf(randomBuyer),1e16*tokenSaleContract.publicSaleExchangeRate());
        vm.stopPrank();

    }

    /**
     * @notice Test - Minimum cap is raised in presale but not in public sale investor should be able to claim refund
     */
    function test_amount_raised_in_presale_more_than_min_capital_to_raise_but_amount_raised_in_public_sale_less_tha_min_capital_to_raise_refund_should_be_claimable() public{
        vm.startPrank(owner);
        
        tokenSaleContract.startPreSale();

        vm.stopPrank();

        address user1 = whiteList[1];

        vm.startPrank(user1);
        vm.deal(user1, 2 ether);
        (bool callSuccess,) = address(tokenSaleContract).call{value: 2 ether}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        vm.stopPrank();

        address user2 = whiteList[0];

        vm.startPrank(user2);
        vm.deal(user2, 5 ether);
        (bool callSuccess1,) = address(tokenSaleContract).call{value: 2 ether}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess1, "Call failed");
        vm.stopPrank();

        address user3 = whiteList[2];

        vm.startPrank(user3);
        vm.deal(user3, 5 ether);
        (bool callSuccess2,) = address(tokenSaleContract).call{value: 2 ether}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess2, "Call failed");
        vm.stopPrank();

        vm.startPrank(owner);
        // Ending presale
        tokenSaleContract.endPreSale();

        // Starting public sale 
        tokenSaleContract.startPublicSale();

        vm.stopPrank();

        address randomBuyer = makeAddr("Random buyer");

        vm.startPrank(randomBuyer);

        vm.deal(randomBuyer, 0.5 ether);

        (bool callSuccessn,) = address(tokenSaleContract).call{value: 1e16}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccessn, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPublicSale(), 1e16);
        assertEq(tokenSaleContract.contributions(randomBuyer), 1e16);
        assertEq(token.balanceOf(randomBuyer),1e16*tokenSaleContract.publicSaleExchangeRate());
        vm.stopPrank();

        vm.startPrank(owner);
        // Ending public sale 
        tokenSaleContract.endPublicSale();

        vm.stopPrank();

        vm.startPrank(randomBuyer);

        tokenSaleContract.claimRefund();

        assertEq(tokenSaleContract.contributions(randomBuyer), 0);

        vm.stopPrank();

    }

    /**
     * @notice Test - Minimum cap is not raised in presale but raised in public sale investor should be able to claim refund
     */
    function test_amount_raised_in_presale_less_than_min_capital_to_raise_but_amount_raised_in_public_sale_more_tha_min_capital_to_raise_refund_should_be_claimable() public{
        vm.startPrank(owner);
        
        tokenSaleContract.startPreSale();

        vm.stopPrank();

        address user1 = whiteList[1];

        vm.startPrank(user1);
        vm.deal(user1, 2 ether);
        (bool callSuccess,) = address(tokenSaleContract).call{value: 2 ether}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        vm.stopPrank();


        vm.startPrank(owner);
        // Ending presale
        tokenSaleContract.endPreSale();

        // Starting public sale 
        tokenSaleContract.startPublicSale();

        vm.stopPrank();

        address randomBuyer = makeAddr("Random buyer");

        vm.startPrank(randomBuyer);

        vm.deal(randomBuyer, 1e18);

        (bool callSuccessn,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccessn, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPublicSale(), 1e18);
        assertEq(tokenSaleContract.contributions(randomBuyer), 1e18);
        assertEq(token.balanceOf(randomBuyer),1e18*tokenSaleContract.publicSaleExchangeRate());
        vm.stopPrank();

        address randomBuyer2 = makeAddr("Random buyer");

        vm.startPrank(randomBuyer2);

        vm.deal(randomBuyer2, 1e18);

        (bool callSuccessn1,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccessn1, "Call failed");
        vm.stopPrank();

        vm.startPrank(owner);
        // Ending public sale 
        tokenSaleContract.endPublicSale();

        vm.stopPrank();

        vm.startPrank(randomBuyer);

        tokenSaleContract.claimRefund();

        assertEq(tokenSaleContract.contributions(randomBuyer), 0);

        vm.stopPrank();

    }

    /**
     * @notice Test - Minimum cap is raised in both sales investor should not be able to claim refund
     */
    function testFail_amount_raised_in_presale_more_than_min_capital_to_raise_and_amount_raised_in_public_sale_more_tha_min_capital_to_raise_refund_should_not_be_claimable() public{
        vm.startPrank(owner);
        
        tokenSaleContract.startPreSale();

        vm.stopPrank();

        address user1 = whiteList[1];

        vm.startPrank(user1);
        vm.deal(user1, 2 ether);
        (bool callSuccess,) = address(tokenSaleContract).call{value: 2 ether}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        vm.stopPrank();


        vm.startPrank(owner);
        // Ending presale
        tokenSaleContract.endPreSale();

        // Starting public sale 
        tokenSaleContract.startPublicSale();

        vm.stopPrank();

        address randomBuyer = makeAddr("Random buyer");

        vm.startPrank(randomBuyer);

        vm.deal(randomBuyer, 1e18);

        (bool callSuccessn,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccessn, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPublicSale(), 1e18);
        assertEq(tokenSaleContract.contributions(randomBuyer), 1e18);
        assertEq(token.balanceOf(randomBuyer),1e18*tokenSaleContract.publicSaleExchangeRate());
        vm.stopPrank();

        address randomBuyer2 = makeAddr("Random buyer");

        vm.startPrank(randomBuyer2);

        vm.deal(randomBuyer2, 1e18);

        (bool callSuccessn1,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccessn1, "Call failed");
        vm.stopPrank();

        vm.startPrank(randomBuyer);

        tokenSaleContract.claimRefund();

        assertEq(tokenSaleContract.contributions(randomBuyer), 0);

        vm.stopPrank();

        address randomBuyer3 = makeAddr("randomBuyer3");

        vm.startPrank(randomBuyer3);

        vm.deal(randomBuyer3, 1e18);

        (bool callSuccessn2,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccessn2, "Call failed");
        vm.stopPrank();

        vm.startPrank(owner);

        tokenSaleContract.endPublicSale();

        vm.stopPrank();

        vm.startPrank(randomBuyer3);

        tokenSaleContract.claimRefund();

        vm.stopPrank();
        
    }

    /**
     * @notice Test - Minimum cap is not raised in presale but raised in public sale Owner should be able to withdraw funds
     */
    function test_amount_raised_in_presale_more_than_min_capital_to_raise_and_amount_raised_in_public_sale_more_tha_min_capital_to_raise_funds_should_be_withdrawble() public{
        vm.startPrank(owner);
        
        tokenSaleContract.startPreSale();

        vm.stopPrank();

        address user1 = whiteList[1];

        vm.startPrank(user1);
        vm.deal(user1, 2 ether);
        (bool callSuccess,) = address(tokenSaleContract).call{value: 2 ether}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "Call failed");
        vm.stopPrank();

        address user2 = whiteList[0];

        vm.startPrank(user2);
        vm.deal(user2, 2 ether);
        (bool callSuccess2,) = address(tokenSaleContract).call{value: 2 ether}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess2, "Call failed");
        vm.stopPrank();

        address user3 = whiteList[0];

        vm.startPrank(user3);
        vm.deal(user3, 2 ether);
        (bool callSuccess3,) = address(tokenSaleContract).call{value: 2 ether}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess3, "Call failed");
        vm.stopPrank();


        vm.startPrank(owner);
        // Ending presale
        tokenSaleContract.endPreSale();

        // Starting public sale 
        tokenSaleContract.startPublicSale();

        vm.stopPrank();

        address randomBuyer = makeAddr("Random buyer");

        vm.startPrank(randomBuyer);

        vm.deal(randomBuyer, 1e18);

        (bool callSuccessn,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccessn, "Call failed");
        assertEq(tokenSaleContract.amountRaisedInPublicSale(), 1e18);
        assertEq(tokenSaleContract.contributions(randomBuyer), 1e18);
        assertEq(token.balanceOf(randomBuyer),1e18*tokenSaleContract.publicSaleExchangeRate());
        vm.stopPrank();

        address randomBuyer2 = makeAddr("Random buyer");

        vm.startPrank(randomBuyer2);

        vm.deal(randomBuyer2, 1e18);

        (bool callSuccessn1,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccessn1, "Call failed");
        vm.stopPrank();


        address randomBuyer3 = makeAddr("randomBuyer3");

        vm.startPrank(randomBuyer3);

        vm.deal(randomBuyer3, 1e18);

        (bool callSuccessn2,) = address(tokenSaleContract).call{value: 1e18}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccessn2, "Call failed");
        vm.stopPrank();

        vm.startPrank(owner);

        tokenSaleContract.endPublicSale();

        vm.stopPrank();

        vm.startPrank(owner);

        uint256 ownerEthBalanceBefore = owner.balance;

        tokenSaleContract.withdraw();

        uint256 ownerEthBalanceAfter = owner.balance;

        uint256 contractTokenBalanceBefore = token.balanceOf(address(tokenSaleContract));

        tokenSaleContract.withdrawRemainingTokens();

        uint256 contractTokenBalanceAfter = token.balanceOf(address(tokenSaleContract));

        assertEq(contractTokenBalanceBefore-contractTokenBalanceAfter, contractTokenBalanceBefore);
        assertEq(ownerEthBalanceAfter - ownerEthBalanceBefore,  tokenSaleContract.amountRaisedInPreSale()+tokenSaleContract.amountRaisedInPublicSale());

        vm.stopPrank();
        
    }

    /**
     * @notice Test - Send tokens to specific account
     */
    function test_distribute_funds_to_specific_account() public{
        address beneficiery = makeAddr("beneficiery");
        vm.startPrank(owner);

        tokenSaleContract.distributeFundsToSpecificAccount(beneficiery, 200*1e18);

        assertEq(token.balanceOf(beneficiery), 200*1e18);
        vm.stopPrank();
    }


}