pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    YourToken yourToken;
    uint256 public constant tokensPerEth = 100;

    event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);
    event SellTokens(
        address seller,
        uint256 amountOfTokens,
        uint256 amountOfETH
    );

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    // ToDo: create a payable buyTokens() function:
    function buyTokens() public payable returns (uint256 amount) {
        require(msg.value > 0, "amount of eth should be greater than 0");
        uint256 amountToBuy = msg.value * tokensPerEth;

        uint256 venderBalance = yourToken.balanceOf(address(this));
        require(
            venderBalance >= amountToBuy,
            "Not enough in Vendor balance. Please decrease your amount"
        );
        bool sent = yourToken.transfer(msg.sender, amountToBuy);
        require(sent, "Failed to transfer tokens");
        emit BuyTokens(msg.sender, msg.value, amountToBuy);
        return amountToBuy;
    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() public onlyOwner {
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > 0, "No balance to withdraw");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send balance to owner");
    }

    // ToDo: create a sellTokens() function:
    function sellTokens(uint256 tokenAmountToSell) public {
        require(tokenAmountToSell > 0, "Amount needs to be greater than zero");
        uint256 userBalance = yourToken.balanceOf(msg.sender);
        require(userBalance >= tokenAmountToSell, "Your balance is too low");

        uint256 amountOfETHToTransfer = tokenAmountToSell / tokensPerEth;
        uint256 ownerETHBalance = address(this).balance;
        require(
            ownerETHBalance >= amountOfETHToTransfer,
            "Not enough vendor funds"
        );

        bool sent = yourToken.transferFrom(
            msg.sender,
            address(this),
            tokenAmountToSell
        );
        require(sent, "Failed to transfer tokens from user to vendor");

        (sent, ) = msg.sender.call{value: amountOfETHToTransfer}("");
        require(sent, "Failed to send ETH to the user");
    }
}
