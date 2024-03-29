# Aderyn Analysis Report

This report was generated by [Aderyn](https://github.com/Cyfrin/aderyn), a static analysis tool built by [Cyfrin](https://cyfrin.io), a blockchain security company. This report is not a substitute for manual audit or security review. It should not be relied upon for any purpose other than to assist in the identification of potential security vulnerabilities.
# Table of Contents

- [Summary](#summary)
  - [Files Summary](#files-summary)
  - [Files Details](#files-details)
  - [Issue Summary](#issue-summary)
- [Low Issues](#low-issues)
  - [L-1: Conditional storage checks are not consistent](#l-1-conditional-storage-checks-are-not-consistent)
  - [L-2: PUSH0 is not supported by all chains](#l-2-push0-is-not-supported-by-all-chains)
- [NC Issues](#nc-issues)
  - [NC-1: Event is missing `indexed` fields](#nc-1-event-is-missing-indexed-fields)


# Summary

## Files Summary

| Key | Value |
| --- | --- |
| .sol Files | 1 |
| Total nSLOC | 59 |


## Files Details

| Filepath | nSLOC |
| --- | --- |
| src/TokenSwap.sol | 59 |
| **Total** | **59** |


## Issue Summary

| Category | No. of Issues |
| --- | --- |
| Critical | 0 |
| High | 0 |
| Medium | 0 |
| Low | 2 |
| NC | 1 |


# Low Issues

## L-1: Conditional storage checks are not consistent

When writing `require` or `if` conditionals that check storage values, it is important to be consistent to prevent off-by-one errors. There are instances found where the same storage variable is checked multiple times, but the conditionals are not consistent.

- Found in src/TokenSwap.sol [Line: 99](src/TokenSwap.sol#L99)

	```solidity
	            exchangeAmount = (amount * DIVISION_FACTOR)/EXCHANGE_RATE;
	```

- Found in src/TokenSwap.sol [Line: 101](src/TokenSwap.sol#L101)

	```solidity
	            exchangeAmount = (amount * EXCHANGE_RATE)/DIVISION_FACTOR;
	```



## L-2: PUSH0 is not supported by all chains

Solc compiler version 0.8.20 switches the default target EVM version to Shanghai, which means that the generated bytecode will include PUSH0 opcodes. Be sure to select the appropriate EVM version in case you intend to deploy on a chain other than mainnet like L2 chains that may not support PUSH0, otherwise deployment of your contracts will fail.

- Found in src/TokenSwap.sol [Line: 2](src/TokenSwap.sol#L2)

	```solidity
	pragma solidity 0.8.20;
	```



# NC Issues

## NC-1: Event is missing `indexed` fields

Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

- Found in src/TokenSwap.sol [Line: 27](src/TokenSwap.sol#L27)

	```solidity
	    event Swapped(
	```



