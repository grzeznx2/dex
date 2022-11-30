// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/IERC20/IERC20.sol";

contract Dex {
    enum Side {
        BUY,
        SELL
    }

    struct Order {
        uint256 id;
        Side side;
        uint256 ticker;
        uint256 amount;
        uint256 filled;
        uint256 price;
        uint256 date;
    }

    struct Token {
        bytes32 ticker;
        address tokenAddress;
    }
    mapping(bytes32 => mapping(uint256 => Order[])) public orderBook;
    mapping(address => mapping(bytes32 => uint256)) public traderBalances;
    mapping(bytes32 => Token) public tokens;
    bytes32[] public tokenList;
    address public admin;
    uint256 public nextOrderId;
    bytes32 constant DAI = bytes32("DAI");

    constructor(){
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "DEX: Only admin can perform this action");
        _;
    }

    modifier tokenExists(bytes32 ticker) {
        require(tokens[ticker] != address(0), "DEX: Unsupported token");
        _;
    }

    function deposit(uint256 amount, bytes32 ticker) external tokenExists(ticker) {
        IERC20(tokens[ticker].tokenAddress).transferFrom(msg.sender, address(this), amount);
        traderBalances[msg.sender][ticker] += amount;
    }

    function withdraw(uint256 amount, bytes32 ticker) external tokenExists(ticker) {
        require(traderBalances[msg.sender][ticker] >= amount, "DEX: insufficient balance");
        IERC20(tokens[ticker].tokenAddress).transfer(msg.sender, amount);
        traderBalances[msg.sender][ticker] -= amount;
    }

    function addToken(bytes32 ticker, address tokenAddress) external onlyAdmin {
        tokens[ticker] = Token(ticker, tokenAddress);
        tokenList.push(ticker);
    }

    function createLimitOrder(bytes32 ticker, uint256 amount, uint256 price,  Side side) external tokenExists(ticker){
        require(ticker != DAI, "Dex: Cannot trade DAI");
        if(side == Side.SELL){
            require(tokenBalances[msg.sender][ticker] >= amount, "DEX: Token balance too low");
        }else {
            require(tokenBalances[msg.sender][DAI] >= amount * price, "DEX: DAI balance too lowe");
        }
    }
}
