// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20{
    constructor() ERC20("Token A", "TKA"){
        _mint(msg.sender,1_000_000*1e18);
    }
}