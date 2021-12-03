//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";


contract SharedWallet is Ownable {
  mapping (address => uint) public allowance;

  function setAllowance(address _who, uint _amount) public onlyOwner {
      allowance[_who] = _amount;
  }

  function isOwner() internal view returns(bool) {
      return owner() == msg.sender;
  }

  modifier ownerOrAllowed (uint _amount) {
      require(isOwner() || allowance[msg.sender] >=  _amount, "You are not allowed"); // from zepplin lib
      _;
  }

  //with ownable we handle the isOwner and owner in constructor
  //give us method natively to renounce ownership, transfer ownership
  function sendViaCall(address payable _to ) public ownerOrAllowed(msg.value) payable {
      (bool sent, ) = _to.call{value: msg.value}("");
      require(sent, "Failed to send Ether");
  }

  //is the function used unpon deployment to send ETH to the contract
  receive() external payable {

  }
}