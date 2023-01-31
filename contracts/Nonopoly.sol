// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IRegisterableNFT.sol";

contract Nonopoly is Ownable {
  address public player;
  address public city;
  address public hourses;
  address public immutable nerd;

  event Inititalized(address _player, address _city, address _hourses);

  modifier afterInitialized() {
    require(
      player != address(0) && city != address(0) && hourses != address(0),
      "Nonopoly: not initailized yet"
    );
    _;
  }

  /**
   * @param _nerd NERD token contract address
   */
  constructor(address _nerd) {
    nerd = _nerd;
  }

  /**
   * @dev initialize game contract - set nft contracts
   * @param _player Nonopoly player contract address
   * @param _city Nonopoly city contract address
   * @param _hourses Nonopoly hourses contract address
   */
  function inititalize(address _player, address _city, address _hourses) external onlyOwner {
    require(
      _player != address(0) && _city != address(0) && _hourses != address(0),
      "Nonopoly: not initailized yet"
    );

    player = _player;
    city = _city;
    hourses = _hourses;

    emit Inititalized(_player, _city, _hourses);
  }
}
