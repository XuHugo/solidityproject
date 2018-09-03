pragma solidity ^0.4.7;

contract Crowdfunding{
    address owner;
    uint public goal;
    uint public endtime;
    uint public total=0;
    
    mapping(address=>uint) gift;
    
    constructor(uint _goal, uint _time) public{
        owner = msg.sender;
        goal = _goal;
        endtime = now + _time;
    }
    
    function donate() payable public{
        require(now < endtime);
        require(total < goal);
        require(msg.value > 0);
        gift[msg.sender] += msg.value;
        total += msg.value;
    }
    
    function draw() public{
        require(msg.sender == owner);
        require(total > goal);
        owner.transfer(address(this).balance);
    }
    
    function withdraw() public{
        require(now > endtime);
        require(total < goal);
        uint amount = gift[msg.sender];
        total -= amount;
        gift[msg.sender] = 0;
        address(msg.sender).transfer(amount);
    }
}
