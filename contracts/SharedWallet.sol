//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Allowance is Ownable {
    mapping (address => uint) public allowance;

    function isOwner() internal view returns(bool) {
        return owner() == msg.sender;
    }

    function setAllowance(address _who, uint _amount) public onlyOwner {
        allowance[_who] = _amount;
    }

    modifier ownerOrAllowed (uint _amount) {
        require(isOwner() || allowance[msg.sender] >=  _amount, "You are not allowed"); // from zepplin lib
        _;
    }

    function reduceAllowance(address _who, uint _amount) internal ownerOrAllowed(_amount) {
        allowance[_who] -= _amount;
    }
}


contract SharedWallet is Allowance {
    //with ownable we handle the isOwner and owner in constructor
    //give us method natively to renounce ownership, transfer ownership
    function withdrawMoney(address payable _to, uint _amount ) public ownerOrAllowed(_amount) payable {
        require(_amount <= address(this).balance, "not enough fund on the smartconctract" );
        if(!isOwner()) {
            reduceAllowance(msg.sender, _amount);
        }
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    //is the function used unpon deployment to send ETH to the contract
    receive() external payable {

    }
}