# PigaKura

In this repo, I am going to cover all aspects of building a voting smart contract, sourcing my knowledge from the latest Solidity docs. [0.8.26]

---

### Initializing a Hardhat project

In this project, I am going to test and deploy the contract locally. I opted to using Hardhat and not Foundry, but maybe in future I might add up a branch that uses Foundry for the testing.

Also, I will be using Js mostly and rarely Typescript.

To initialize a Hardhat project, first ensure Node.js is installed in your computer.

Run the following commands on the terminal:

1. `npm init -y` to initialize a new npm project.
2. Install Hardhat as a development dependency in the project by running `npm install --save-dev hardhat`. Otherwise, Hardhat can be installed globally by running `npm install -g hardhat`, but use the first one please. We'll dive into difference later.
3. After installing Hardhat locally, run `npx hardhat` to create a hardhat project, follow the prompts that come afterwards and choose **Create Javascript Project**

Nice and easy, we have a skeleton of our project with 4 folders: contracts, ignition, node_modules, and test.

---
