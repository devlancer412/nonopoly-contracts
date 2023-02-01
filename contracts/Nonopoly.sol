// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IRegisterableNFT.sol";

/**
 * @title Nonopol game contract
 */
contract Nonopoly is Ownable {
  enum PlayerType {
    Rookie,
    Intermediate,
    Advanced,
    Veteran,
    Visionary
  }

  enum RealEstateType {
    GarageBox,
    Apartment,
    House,
    Villa
  }

  enum BoardType {
    Start,
    Street,
    Neutral,
    Jail
  }

  enum StreetColor {
    None,
    Brown,
    LightBlue,
    Rose,
    Orange,
    Red,
    Yellow,
    Green,
    Blue
  }

  struct PlayerData {
    uint256 timestamp;
    uint256 tokenAmount;
    PlayerType playerType;
  }

  struct BoardData {
    BoardType boardType;
    StreetColor color;
    uint256[] streets;
  }

  address public player;
  address public street;
  address public realEstate;
  address public immutable nerd;

  mapping(uint8 => BoardData) public boards;
  // streetId => playerId
  mapping(uint256 => uint256) public playerStreets;

  event Inititalized(address _player, address _street, address _realEstate);

  modifier afterInitialized() {
    require(
      player != address(0) && street != address(0) && realEstate != address(0),
      "Nonopoly: not initailized yet"
    );
    _;
  }

  /**
   * @param _nerd NERD token contract address
   */
  constructor(address _nerd) {
    nerd = _nerd;

    // init board datas
    boards[0] = _createBoard(BoardType.Start, StreetColor.None);
    boards[1] = _createBoard(BoardType.Street, StreetColor.Brown);
    boards[2] = _createBoard(BoardType.Neutral, StreetColor.None);
    boards[3] = _createBoard(BoardType.Street, StreetColor.Brown);
    boards[4] = _createBoard(BoardType.Street, StreetColor.Brown);
    boards[5] = _createBoard(BoardType.Neutral, StreetColor.None);
    boards[6] = _createBoard(BoardType.Street, StreetColor.LightBlue);
    boards[7] = _createBoard(BoardType.Neutral, StreetColor.None);
    boards[8] = _createBoard(BoardType.Street, StreetColor.LightBlue);
    boards[9] = _createBoard(BoardType.Street, StreetColor.LightBlue);
    boards[10] = _createBoard(BoardType.Neutral, StreetColor.None);
    boards[11] = _createBoard(BoardType.Street, StreetColor.Rose);
    boards[12] = _createBoard(BoardType.Neutral, StreetColor.None);
    boards[13] = _createBoard(BoardType.Street, StreetColor.Rose);
    boards[14] = _createBoard(BoardType.Street, StreetColor.Rose);
    boards[15] = _createBoard(BoardType.Neutral, StreetColor.None);
    boards[16] = _createBoard(BoardType.Street, StreetColor.Orange);
    boards[17] = _createBoard(BoardType.Neutral, StreetColor.None);
    boards[18] = _createBoard(BoardType.Street, StreetColor.Orange);
    boards[19] = _createBoard(BoardType.Street, StreetColor.Orange);
    boards[20] = _createBoard(BoardType.Neutral, StreetColor.None);
    boards[21] = _createBoard(BoardType.Street, StreetColor.Red);
    boards[22] = _createBoard(BoardType.Neutral, StreetColor.None);
    boards[23] = _createBoard(BoardType.Street, StreetColor.Red);
    boards[24] = _createBoard(BoardType.Street, StreetColor.Red);
    boards[25] = _createBoard(BoardType.Neutral, StreetColor.None);
    boards[26] = _createBoard(BoardType.Street, StreetColor.Yellow);
    boards[27] = _createBoard(BoardType.Street, StreetColor.Yellow);
    boards[28] = _createBoard(BoardType.Neutral, StreetColor.None);
    boards[29] = _createBoard(BoardType.Street, StreetColor.Yellow);
    boards[30] = _createBoard(BoardType.Jail, StreetColor.None);
    boards[31] = _createBoard(BoardType.Street, StreetColor.Green);
    boards[32] = _createBoard(BoardType.Street, StreetColor.Green);
    boards[33] = _createBoard(BoardType.Neutral, StreetColor.None);
    boards[34] = _createBoard(BoardType.Street, StreetColor.Green);
    boards[35] = _createBoard(BoardType.Neutral, StreetColor.None);
    boards[36] = _createBoard(BoardType.Street, StreetColor.Blue);
    boards[37] = _createBoard(BoardType.Street, StreetColor.Blue);
    boards[38] = _createBoard(BoardType.Neutral, StreetColor.None);
    boards[39] = _createBoard(BoardType.Street, StreetColor.Blue);
  }

  function _createBoard(
    BoardType boardType,
    StreetColor color
  ) private pure returns (BoardData memory) {
    uint256[] memory streets;
    return BoardData(boardType, color, streets);
  }

  /**
   * @dev initialize game contract - set nft contracts
   * @param _player Nonopoly player contract address
   * @param _street Nonopoly street contract address
   * @param _realEstate Nonopoly realEstate contract address
   */
  function inititalize(address _player, address _street, address _realEstate) external onlyOwner {
    require(
      _player != address(0) && _street != address(0) && _realEstate != address(0),
      "Nonopoly: not initailized yet"
    );

    player = _player;
    street = _street;
    realEstate = _realEstate;

    emit Inititalized(_player, _street, _realEstate);
  }

  function _getStreetMultiplyer(StreetColor color) private pure returns (uint256) {
    if (color == StreetColor.None) {
      return 0;
    }

    return 100 + (uint8(color) - 1) * 5;
  }

  /**
   * @dev get board data
   * @param id board id 0 - 39
   * @return boardType type of board: "Start", "Street", "Neutral", "Jail"
   * @return color color of street:  "Brown", "LightBlue", "Rose", "Orange", "Red", "Yellow", "Green", "Blue"
   * @return streets array of street ids belonged this board
   * @return multiplyer multiplyer of board: 100 times 105 = 1.05
   */
  function getBoardData(
    uint8 id
  )
    public
    view
    returns (
      string memory boardType,
      string memory color,
      uint256[] memory streets,
      uint256 multiplyer
    )
  {
    require(id >= 0 && id < 40, "Nonopoly: invalid board id");

    BoardData memory board = boards[id];
    if (board.boardType == BoardType.Start) {
      boardType = string("Start");
    } else if (board.boardType == BoardType.Street) {
      boardType = string("Street");
    } else if (board.boardType == BoardType.Neutral) {
      boardType = string("Neutral");
    } else if (board.boardType == BoardType.Jail) {
      boardType = string("Jail");
    } else {
      revert("Invalid board data");
    }

    if (board.color == StreetColor.Brown) {
      color = string("Brown");
    } else if (board.color == StreetColor.LightBlue) {
      color = string("LightBlue");
    } else if (board.color == StreetColor.Rose) {
      color = string("Rose");
    } else if (board.color == StreetColor.Orange) {
      color = string("Orange");
    } else if (board.color == StreetColor.Red) {
      color = string("Red");
    } else if (board.color == StreetColor.Yellow) {
      color = string("Yellow");
    } else if (board.color == StreetColor.Green) {
      color = string("Green");
    } else if (board.color == StreetColor.Blue) {
      color = string("Blue");
    } else {
      color = "None";
    }

    streets = board.streets;
    multiplyer = _getStreetMultiplyer(board.color);
  }
}
