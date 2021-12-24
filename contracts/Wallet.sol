// SPDX-License-Identifier: MIT
pragma solidity >=0.7.3;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './Compoud.sol';



contract Wallet is Compound {
    address public admin;

    constructor(
        address _comptroller,
        address _cEthAddress
    ) Compound(_comptroller, _cEthAddress) {
        admin = msg.sender;
    }
    function deposit(address cTokenAddress, uint underlyingAmount)  external {
        address underlyingAddress = getUnderlyingAddress(cTokenAddress);
        IERC20(underlyingAddress).transferFrom(msg.sender, address(this), underlyingAmount);
        supply(cTokenAddress, underlyingAmount);
    }

    function withdraw(address cTokenAddress, uint underlyingAmount, address recipient)  external {
        require(getUnderlyingBalance(cTokenAddress) >= underlyingAmount, 'balance too low');
        claimComp();
        redeem(cTokenAddress, underlyingAmount);

        address underlyingAddress = getUnderlyingAddress(cTokenAddress);
        IERC20(underlyingAddress).transfer(recipient, underlyingAmount);

        address compAddress = getCompAddress();
        IERC20 compToken = IERC20(compAddress);
        uint compAmount = compToken.balanceOf(address(this));
        compToken.transfer(recipient, compAmount);
    }
}