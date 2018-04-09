pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol";

contract EladCrowdsale is RefundableCrowdsale, CappedCrowdsale {

  function EladCrowdsale(uint256 _goal, uint256 _openingTime, uint256 _closingTime, uint256 _cap, uint256 _rate, address _wallet, ERC20 _token) public 
    Crowdsale(_rate, _wallet, _token)
    CappedCrowdsale(_cap)
    TimedCrowdsale(_openingTime, _closingTime)
    RefundableCrowdsale(_goal) {
    require(_goal <= _cap);
  }

  function isOpen() public view returns (bool) {
    return now >= openingTime && now <= closingTime;
  }

  function allocateRemainingTokens() onlyOwner public {
    require(isFinalized);
    uint256 remaining = token.balanceOf(this);
    token.transfer(owner, remaining);
  }
}
