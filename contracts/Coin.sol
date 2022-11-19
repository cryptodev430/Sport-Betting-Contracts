//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
	constructor() ERC20("Test Token", "TEST") {
		_mint(msg.sender, 10e18);
	}
}
