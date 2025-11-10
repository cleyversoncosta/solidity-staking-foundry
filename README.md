🧱 StakingApp – Fixed-Amount ERC20 Token Staking Contract (Foundry)
===================================================================

A **Solidity-based staking dApp** that allows users to deposit a **fixed number of ERC20 tokens** for a defined staking period and later **claim ETH rewards** provided by the contract owner.  
Built and tested entirely using **Foundry** with **OpenZeppelin** libraries.

* * *

⚙️ Overview
-----------

The project includes two smart contracts and two test suites:

Contract

Description

**StakingApp.sol**

Core staking logic. Handles token deposits, withdrawals, and reward distribution in ETH.

**StakingToken.sol**

Minimal ERC20 token used for staking. Supports minting for testing/demo purposes.

**StakingAppTest.t.sol**

Foundry unit tests covering full staking logic.

**StakingTokenTest.t.sol**

Foundry tests for minting and token behavior.

* * *

🧩 Key Features
---------------

*   🔒 **Fixed staking amount:** users can stake only a predefined token quantity per cycle.
*   ⏱️ **Configurable staking period:** owner can change how long users must wait to claim rewards.
*   💰 **ETH-based rewards:** rewards are paid in ETH, sent from the contract balance.
*   🪙 **ERC20 token support:** uses OpenZeppelin’s `IERC20` interface for secure token operations.
*   🧾 **Event logging:** emits events for deposits, withdrawals, staking period changes, and ETH funding.
*   👑 **Owner-controlled parameters:** staking period and funding are managed by the owner only.
*   🧪 **Full Foundry test coverage:** includes revert scenarios, time manipulation, and state verification.

* * *

🧰 Dependencies
---------------

All dependencies are managed via **Foundry** and **OpenZeppelin**.

    forge install openzeppelin/openzeppelin-contracts
    forge install foundry-rs/forge-std
    

* * *

🧪 Running Tests
----------------

Run all tests with verbose output:

    forge test -vv
    

Run a specific test file:

    forge test --match-path test/StakingAppTest.t.sol -vv
    

Check gas usage:

    forge test --gas-report
    

* * *

📊 Code Coverage (Recommended Setup)
------------------------------------

1.  Install the VSCode **Gutter Coverage** extension.
2.  Generate coverage data:

    forge coverage
    

3.  Open the report in VSCode to visualize untested lines directly in the gutter.

* * *

🧾 Contract Functions Summary
-----------------------------

### 🔹 StakingApp.sol

Function

Visibility

Description

`depositTokens(uint256)`

External

Deposits a fixed amount of tokens into the contract.

`withdraw()`

External

Withdraws the user's staked tokens.

`claimRewards()`

External

Sends ETH reward to the user after the staking period elapses.

`receive()`

External payable

Accepts ETH only from the contract owner (funds rewards pool).

`changeStakingPeriod(uint256)`

Public onlyOwner

Updates the staking duration.

### 🔹 StakingToken.sol

Function

Visibility

Description

`mint(uint256)`

External

Mints new tokens to the caller for demo/testing.

* * *

🧠 Test Coverage Highlights
---------------------------

Category

Tests Included

✅ Deployment

Ensures both contracts deploy correctly

✅ Ownership

Validates only owner can modify staking parameters

✅ Deposit

Verifies correct deposit flow and reverts on wrong amounts

✅ Withdraw

Ensures proper token return and zero reset

✅ Rewards

Covers claiming logic, time manipulation, and ETH transfer

✅ Failure Scenarios

Reverts for missing ETH, premature claims, and invalid deposits

* * *

💡 Example Flow
---------------

1.  Owner deploys **StakingToken** and **StakingApp**.
2.  Users mint staking tokens and approve **StakingApp** to spend them.
3.  Users deposit exactly the `fixedStakingAmount`.
4.  After `stakingPeriod` passes, users call `claimRewards()` to receive ETH.
5.  Owner can refill ETH rewards anytime via direct transfer to the contract.

* * *

📂 Project Structure
--------------------

    📦 staking-app/
     ┣ 📂 src/
     ┃ ┣ 📜 StakingApp.sol
     ┃ ┗ 📜 StakingToken.sol
     ┣ 📂 test/
     ┃ ┣ 📜 StakingAppTest.t.sol
     ┃ ┗ 📜 StakingTokenTest.t.sol
     ┣ 📂 lib/
     ┃ ┗ 📂 openzeppelin-contracts/
     ┗ 📜 foundry.toml
    

* * *

🧑‍💻 Example Deployment (Remix)
--------------------------------

1.  Deploy **StakingToken** with a name and symbol.
2.  Deploy **StakingApp** with parameters:

*   `_stakingToken`: address of the deployed token
*   `_owner`: your wallet address
*   `_stakingPeriod`: seconds to wait before claiming
*   `_fixedStakingAmount`: exact token deposit amount
*   `_rewardPerPeriod`: ETH reward per claim

4.  Send ETH to the **StakingApp** contract (only owner).
5.  Approve and stake using your ERC20 tokens.

* * *

🪄 Events
---------

Event

Description

`ChangeStakingPeriod(uint256)`

Fired when the owner updates staking duration.

`DepositTokens(address,uint256)`

Fired when a user deposits tokens.

`WithdrawTokens(address,uint256)`

Fired when a user withdraws staked tokens.

`EtherSet(uint256)`

Fired when the owner funds ETH rewards.

* * *

🧰 Environment Setup
--------------------

    # Clone the repo
    git clone <repo-url>
    cd staking-app
    
    # Install dependencies
    forge install
    
    # Build project
    forge build
    
    # Run tests
    forge test -vv
    

* * *

🏗️ Built With
--------------

*   Solidity 0.8.30
*   Foundry (forge, cast, anvil)
*   OpenZeppelin Contracts
*   VSCode + Gutter Coverage Extension

* * *

🧠 Learnings
------------

*   How to design **fixed-amount staking logic** safely.
*   How to integrate **ETH reward payouts**.
*   How to simulate **block time and ownership restrictions** in Foundry tests.
*   How to visualize **test coverage directly in VSCode**.

* * *

📜 License
----------

**SPDX-License-Identifier: SEE LICENSE IN LICENSE**  
This repository follows an open structure for educational and demonstrative use.
