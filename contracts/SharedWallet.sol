//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Allowance.sol";

contract SharedWallet is Allowance {
    event MoneySpent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);

    //with ownable we handle the isOwner and owner in constructor
    //give us method natively to renounce ownership, transfer ownership
    function withdrawMoney(address payable _to, uint _amount ) public ownerOrAllowed(_amount) payable {
        require(_amount <= address(this).balance, "not enough fund on the smartconctract" );
        if(!isOwner()) {
            reduceAllowance(msg.sender, _amount);
        }
        (bool sent, ) = _to.call{value: _amount}("");
        emit MoneySpent(_to, _amount);
        require(sent, "Failed to send Ether");
    }

    //overwrite renounceOwnership function from the Ownable lib ! 
    function renounceOwnership() public override onlyOwner {
        revert("can't renounceOwnership here"); //not possible with this smart contract
    }


    //is the function used unpon deployment to send ETH to the contract
    receive() external payable {
        emit MoneyReceived(msg.sender, msg.value);
    }
}