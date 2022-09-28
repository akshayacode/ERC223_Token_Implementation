// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "https://github.com/akshayacode/ERC223_Token_Implementation/blob/main/IERC223.sol";
import "https://github.com/akshayacode/ERC223_Token_Implementation/blob/main/IERC223Recipient.sol";
import "https://github.com/akshayacode/ERC223_Token_Implementation/blob/main/Address.sol";

/**
 * @title Reference implementation of the ERC223 standard token.
 */
contract ERC223Token is IERC223 {

    string  private _name;
    string  private _symbol;
    uint8   private _decimals;
    uint256 private _totalSupply;
    address private owner;
    
    mapping(address => uint256) public balances; // List of user balances.

   
     
    constructor(string memory new_name, string memory new_symbol, uint8 new_decimals)
    {
        _name     = new_name;
        _symbol   = new_symbol;
        _decimals = new_decimals;
         owner= msg.sender;
        uint256 _initialsupply = 100 * 10 ** (decimals());
        mint(msg.sender,_initialsupply);
        balances[msg.sender]= _totalSupply;
    }
    

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

  modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner validAddress(_newOwner) {
        owner = _newOwner;
    }


    function standard() public pure override returns (string memory)
    {
        return "erc223";
    }

   
    function name() public view override returns (string memory)
    {
        return _name;
    }

    
    function symbol() public view override returns (string memory)
    {
        return _symbol;
    }

    
    function decimals() public view override returns (uint8)
    {
        return _decimals;
    }

  
    function totalSupply() public view override returns (uint256)
    {
        return _totalSupply;
    }

    
   
    function balanceOf(address _owner) public view override returns (uint256)
    {
        return balances[_owner];
    }
    
    
    function transfer(address _to, uint _value, bytes calldata _data) public override returns (bool success)
    {
        
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        if(Address.isContract(_to)) {
            IERC223Recipient(_to).tokenReceived(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value);
        emit TransferData(_data);
        return true;
    }
    
    
    function transfer(address _to, uint _value) public override returns (bool success)
    {
        bytes memory _empty = hex"00000000";
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        if(Address.isContract(_to)) {
            IERC223Recipient(_to).tokenReceived(msg.sender, _value, _empty);
        }
        emit Transfer(msg.sender, _to, _value);
        emit TransferData(_empty);
        return true;
    }

    function mint(address account, uint256 amount) public onlyOwner returns (bool) {
        balances[account] = balances[account] + amount;
        _totalSupply = _totalSupply + amount;
    
        emit Transfer(address(0), account, amount);
        return true;
    }

   
}
