// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PiyoCoin is ERC20 {

  address public minter;

  constructor()  payable ERC20("PiyoCoin", "PIYO") {
    minter = msg.sender; //only initially
  }    

  function passMinterRole(address _owner) public returns (bool) {
  	require(msg.sender==minter, 'Error, only owner can change pass minter role');
  	minter = _owner;
  	return true;
  }

  function mint(address payable _account, uint256 _amount) public payable {
	require(msg.sender==minter, 'Error, msg.sender does not have minter role'); //dBank
	_mint(_account, _amount);
  }

}