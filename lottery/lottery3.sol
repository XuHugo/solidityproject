pragma solidity ^0.4.23;

contract Lottery {
    address[3] cormorants;//参加者数组
    uint8 participantsCount = 0;//初始参加人数0
    uint nonce = 0;//随机数，生成赢家时使用

    function draw() public payable {
        require(msg.value == 0.01 ether);//最少要有0.01eth，value转入本合约
        require(participantsCount < 3);//参加人数小于3
        require(drawSituation(msg.sender) == false);//sender未参加
        cormorants[participantsCount] = msg.sender;//将sender添加到数组
        participantsCount++;//参加人数加一
        if (participantsCount == 3) {//人数满3人时开奖
            produceWinner();//生成赢家
        }
    }

    function drawSituation(address _cormorant) private view returns(bool) {//判断某个用户是否已参加
        bool contains = false;
        for(uint i = 0; i < 3; i++) {//遍历数组
            if (cormorants[i] == _cormorant) {//若地址相同
                contains = true;
            }
        }
        return contains;
    }
    
    function produceWinner() private returns(address) {//生成赢家
        require(participantsCount == 3);//人数要满3人
        address winner = cormorants[winnerNumber()];//得到赢家地址
        winner.transfer(address(this).balance);//向赢家转eth
        delete cormorants;//参加者数组每个元素置0
        participantsCount = 0;//参加者人数归0
        return winner;
    }
    
    function winnerNumber() private returns(uint) {//生成随机数作为赢家地址在数组中的索引位置
        uint winner = uint(keccak256(abi.encodePacked(now, msg.sender, nonce))) % 3;
        nonce++;
        return winner;
    }
}
