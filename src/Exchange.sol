// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "./Token.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Exchange is ERC20{
    address public tokenAddress;

    constructor(address _token)ERC20("ETH TOKEN LP TOKEN","IPETHTOKEN"){
        tokenAddress = _token;

    }


    /****
     * @dev get Reserve  returns the balance of 'token' held by 'this' contract
     */

    function getReserve()public view returns(uint256){
        return ERC20(tokenAddress).balanceOf(address(this));
    }

    /****
     * @dev addliquidity allows user to add liquidity to the exchange
     *  The math
     * x*y =k .....(i)
     * (x+x1)(y-y1) =k .......(ii)
     * Expand Equation
     * xy-xy1+x1y-x1y1 =k 
     * we know x*y =k  from equation (i) -> substitute
     * k-xy1+x1y-x1y1 =k
     * -xy1+x1y-x1y1 =0
     * x1y -xy1-x1y1 =0
     * xy1-x1y1 = x1y
     * y1(x-x1) = x1y
     * y1 = x1y/(x-x1)
     */

function addLiquidity(uint256 _amountofToken)public payable returns(uint256){
    uint256 IpTokensToMint;
    uint256 ethReserveBalance = address(this).balance;
    uint256 tokenReserveBalance = getReserve();

    ERC20 token = ERC20(tokenAddress);

    // if the reserve is empty, take any user supplied value for initial liquidity
    if(tokenReserveBalance == 0){
        //transfer the token from the user to the exchange
        token.transferFrom(msg.sender, address(this), _amountofToken);
        //IpTokensToMint = etheReserveBalance =msg.value
        IpTokensToMint = ethReserveBalance;

        //mintlpTokens to the user
        _mint(msg.sender,IpTokensToMint);
        return IpTokensToMint;
    }

    //if the reserve is not empty, calculate the amount the amount of Lp Tokens to be minted
    uint256 ethReservePriorToFunctionCall = ethReserveBalance - msg.value; // -> x -x1

    uint256 mintTokenAmountRequired = (msg.value *tokenReserveBalance)/ethReservePriorToFunctionCall;
    require(_amountofToken >= mintTokenAmountRequired,"insufficient amount of token required");
    //transfer the token from the user to the exchange
    token.transferFrom(msg.sender, address(this),mintTokenAmountRequired);

    //calculate the amount of lp tokens to be minted
    IpTokensToMint = (totalSupply() *msg.value)/ethReservePriorToFunctionCall;
    //mint lp tokens to the user
    _mint(msg.sender,IpTokensToMint);
    return IpTokensToMint;


    

}

//remove adding liquidity now possible

function removeLiquidity(uint256 _amountOfLpTokens)public returns(uint256,uint256){
    //check the user balance greater than 0   
    require(_amountOfLpTokens >0,"Amount should be greater than 0");
    uint256 ethreserveBalance = address(this).balance;
    uint256 ipTokenTotalSupply = totalSupply();

    //calculate the amount of eth and tokens to return to user
    uint256 ethToReturn = (ethreserveBalance * _amountOfLpTokens)/ipTokenTotalSupply;
    uint256 tokenToReturn = (getReserve() * _amountOfLpTokens)/ipTokenTotalSupply;

    // Burn the LP tokens from the user, and transfer the ETH and tokens to the user
    _burn(msg.sender, _amountOfLpTokens);
    payable(msg.sender).transfer(ethToReturn);
    ERC20(tokenAddress).transfer(msg.sender,tokenToReturn);
    return (ethToReturn,tokenToReturn);
}
}