// This code has not been professionally audited, therefore I cannot make any promises about
// safety or correctness. Use at own risk.

pragma solidity 0.4.24;

interface IIdentityStorage {

  /** Ownable */
  function owner() external view returns(address);
  function isOwner() external view returns(bool);
  function renounceOwnership() external;
  function transferOwnership(address newOwner) external;

  function upgradeVersion(address _newVersion) external;

  function getUint(bytes32 _key) external view returns(uint);
  function getString(bytes32 _key) external view returns(string);
  function getAddress(bytes32 _key) external view returns(address);
  function getBytes(bytes32 _key) external view returns(bytes);
  function getBool(bytes32 _key) external view returns(bool);
  function getInt(bytes32 _key) external view returns(int);

  function setUint(bytes32 _key, uint _value) external;
  function setString(bytes32 _key, string _value) external;
  function setAddress(bytes32 _key, address _value) external;
  function setBytes(bytes32 _key, bytes _value) external;
  function setBool(bytes32 _key, bool _value) external;
  function setInt(bytes32 _key, int _value) external;

  function deleteUint(bytes32 _key) external;
  function deleteString(bytes32 _key) external;
  function deleteAddress(bytes32 _key) external;
  function deleteBytes(bytes32 _key) external;
  function deleteBool(bytes32 _key) external;
  function deleteInt(bytes32 _key) external;
}