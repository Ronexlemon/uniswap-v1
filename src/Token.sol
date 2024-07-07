// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20{

    constructor()ERC20("Token","TKN"){
        _mint(msg.sender,1000000*10**18);
    }

    function mintExternal(address _recepient,uint256 _amount)public {
        _mint(_recepient,_amount*10**18);
    }
}