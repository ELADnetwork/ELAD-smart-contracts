pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/token/ERC20/PausableToken.sol";

contract EladToken is PausableToken {
  string public constant name = "Elad Token";
  string public constant symbol = "ELAD";
  uint8 public constant decimals = 18;

  uint256 public constant initialSupply = 100000000 * 10 ** uint256(decimals);

  uint256 public startTime = 1524470400; // 04/23/2018 @ 8:00am (UTC)
  
  struct TokenLock { uint256 amount; uint256 duration; bool withdrawn; }

  TokenLock public advisorLock = TokenLock({
    amount: initialSupply.div(uint256(100/5)), // 5% of initialSupply
    duration: 180 days,
    withdrawn: false
  });

  TokenLock public foundationLock = TokenLock({
    amount: initialSupply.div(uint256(100/10)), // 10% of initialSupply
    duration: 360 days,
    withdrawn: false
  });

  TokenLock public teamLock = TokenLock({
    amount: initialSupply.div(uint256(100/10)), // 10% of initialSupply
    duration: 720 days,
    withdrawn: false
  });

  function EladToken() public {
    totalSupply_ = initialSupply;
    balances[owner] = initialSupply;
    Transfer(address(0), owner, balances[owner]);

    lockTokens(advisorLock);
    lockTokens(foundationLock);
    lockTokens(teamLock);
  }

  function withdrawLocked() external onlyOwner {
    if (unlockTokens(advisorLock)) advisorLock.withdrawn = true;
    if (unlockTokens(foundationLock)) foundationLock.withdrawn = true;
    if (unlockTokens(teamLock)) teamLock.withdrawn = true;
  }

  function lockTokens(TokenLock lock) internal {
    balances[owner] = balances[owner].sub(lock.amount);
    balances[address(0)] = balances[address(0)].add(lock.amount);
    Transfer(owner, address(0), lock.amount);
  }

  function unlockTokens(TokenLock lock) internal returns (bool) {
    if (startTime + lock.duration < now && lock.withdrawn == false) {
      balances[owner] = balances[owner].add(lock.amount);
      balances[address(0)] = balances[address(0)].sub(lock.amount);
      Transfer(address(0), owner, lock.amount);
      return true;
    }
    return false;
  }
}