pragma solidity ^0.4.7;

contract AddressList{
    address  owner;
    mapping (string => address)  linkman;
    
    modifier isOwner{
        require(owner == msg.sender);
        _;
    }
    
    constructor() public{
        owner = msg.sender;
    }
    
    event Transfer(address to, uint amount);
    
    function addAddress(string man, address to) public  isOwner {
        linkman[man] = to;
    }
    
    function queryAddress(string man ) public  view isOwner returns(address) {
        return linkman[man];
    }
    
    function removeAddress(string man) public  isOwner{
        linkman[man]=address(0);
    }
    
    function changeAddress(string man, address to) public   isOwner{
        linkman[man] = to;
    }
    
    function transferTo(string man,  uint amount) payable  public{
        require(msg.sender.balance >= amount);
        require(linkman[man]!=address(0));
        
        linkman[man].transfer(amount);
        Transfer(msg.sender, amount);
    }
}
