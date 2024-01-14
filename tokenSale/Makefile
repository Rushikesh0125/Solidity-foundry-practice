-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy-tokensale ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy-tokensale ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install foundry-rs/forge-std --no-commit && forge install openzeppelin/openzeppelin-contracts --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast -vvvv

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy-token :
	@forge script script/DeployToken.sol ${NETWORK_ARGS}

deploy-tokenSale :
	@forge script script/DeployTokenSale.sol ${NETWORK_ARGS}

add-whitelist :
	@forge script script/AddWhitelist.sol ${NETWORK_ARGS}

fund-tokens :
	@forge script script/FundTokens.sol ${NETWORK_ARGS}

start-presale :
	@forge script script/StartPresale.sol ${NETWORK_ARGS}

buy-in-presale :
	@forge script script/BuyInPresale.sol ${NETWORK_ARGS}

end-presale :
	@forge script script/EndPresale.sol ${NETWORK_ARGS}

start-publicsale : 
	@forge script script/StartPublicSale.sol ${NETWORK_ARGS}

buy-in-publicsale :
	@forge script script/BuyInPublicSale.sol ${NETWORK_ARGS}

end-publicsale :
	@forge script script/EndPublicSale.sol ${NETWORK_ARGS}

withdraw-funds :
	@forge script script/WithdrawFunds.sol ${NETWORK_ARGS}

withdraw-tokens :
	@forge script script/WithdrawRemTokens.sol ${NETWORK_ARGS}

claim-refund :
	@forge script script/ClaimRefund.sol ${NETWORK_ARGS}
-include ${FCT_PLUGIN_PATH}/makefile-external