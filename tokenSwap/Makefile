-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy-tokenA ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy-tokenA ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install openzeppelin/openzeppelin-contracts --no-commit && forge install foundry-rs/forge-std --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy-tokenA :
	@forge script script/DeployTokenA.sol ${NETWORK_ARGS}

deploy-tokenB :
	@forge script script/DeployTokenB.sol ${NETWORK_ARGS}

deploy-tokenSwapContract :
	@forge script script/DeployTokenSwapContract.sol ${NETWORK_ARGS}

addLiquidityForBothTokens :
	@forge script script/AddLiquidity.sol ${NETWORK_ARGS}

swapTokenAForTokenB :
	@forge script script/SwapTokenAForTokenB.sol ${NETWORK_ARGS}

swapTokenBForTokenA :
	@forge script script/SwapTokenBForTokenA.sol ${NETWORK_ARGS}

-include ${FCT_PLUGIN_PATH}/makefile-external