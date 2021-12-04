//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract Allowance is Ownable {

    using SafeMath for uint;

    //indexed let us search easily for the addresses in the side-chain
    event AllowanceChanged(address indexed _forWho, address indexed _fromWho, uint _oldAmount, uint uint_newAmount);

    mapping (address => uint) public allowance;

    function isOwner() internal view returns(bool) {
        return owner() == msg.sender;
    }

    function setAllowance(address _who, uint _amount) public onlyOwner {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], _amount);
        allowance[_who] = _amount;
    }

    modifier ownerOrAllowed (uint _amount) {
        require(isOwner() || allowance[msg.sender] >=  _amount, "You are not allowed"); // from zepplin lib
        _;
    }

    function reduceAllowance(address _who, uint _amount) internal ownerOrAllowed(_amount) {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who].sub(_amount));
        allowance[_who] = allowance[_who].sub(_amount);
    }
}