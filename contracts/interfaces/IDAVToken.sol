pragma solidity 0.4.24;

interface IDAVToken {

  function name() external view returns (string);
  function symbol() external view returns (string);
  function decimals() external view returns (uint8);
  function increaseApproval(address spender, uint addedValue)
    external returns (bool success);
  function decreaseApproval(address spender, uint subtractedValue)
    external returns (bool success);

  function owner() external view returns (address);
  function transferOwnership(address newOwner) external;

  function burn(uint256 value) external;

  function pauseCutoffTime() external view returns (uint256);
  function paused() external view returns (bool);
  function pause() external;
  function unpause() external;
  function setPauseCutoffTime(uint256 time) external;
  function balanceOf(address who) external view returns (uint256);
  function transferFrom(address from, address to, uint256 value)
    external returns (bool);
}
