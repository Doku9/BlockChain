pragma solidity 0.8.6;

contract Dapp03 {
    address public manager;
    
    constructor () {
        manager = msg.sender;
    }
    
    struct card {
        string cardType;
        string cardName;
        string cardImage;
        uint cardRarity;
        uint cardStatATK;
        uint cardStatLife;
        uint cardUpgrade;
    }
    
      struct userInfo {
        string userName;
        uint userStack;
        card[] myCard;
    }
    
    card[] public AllCardList;
    card[] public CommonCardList;
    card[] public LegendaryCardList;
    
     mapping (address => userInfo) user;
     
     event drawLegendaryCardEvent (string cardName, address userAddress);
  
    
    function makeCard (string memory _cardType, string memory _cardName, string memory _cardImage, uint _cardRarity, uint _cardStatATK, uint _cardStatLife, uint _cardUpgrade) public {
        require (msg.sender == manager);
        AllCardList.push(card(_cardType, _cardName, _cardImage, _cardRarity, _cardStatATK, _cardStatLife, _cardUpgrade));
        if (_cardRarity == 4) {
             LegendaryCardList.push(card(_cardType, _cardName, _cardImage, _cardRarity, _cardStatATK, _cardStatLife, 1));
        } else if (_cardRarity == 1) {
            CommonCardList.push(card(_cardType, _cardName, _cardImage, _cardRarity, _cardStatATK, _cardStatLife, 1));
        }
    }
    
     function drawCard () public {
        uint drawCommonCard = (uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) + user[msg.sender].userStack) % CommonCardList.length;
        uint drawLegendaryCard = (uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) + user[msg.sender].userStack) % LegendaryCardList.length;
       
        if (user[msg.sender].userStack == 10) {
            user[msg.sender].userStack = 0;
            user[msg.sender].myCard.push(LegendaryCardList[drawLegendaryCard]);
            emit drawLegendaryCardEvent (LegendaryCardList[drawLegendaryCard].cardName, msg.sender);
        } else {
            user[msg.sender].userStack++;
            user[msg.sender].myCard.push(CommonCardList[drawCommonCard]);
        }
     }
    
    function sendCard (uint _num, address _address) public {
        uint length = user[msg.sender].myCard.length;
        require (_num < length);
        user[_address].myCard.push(user[msg.sender].myCard[_num]);
        delete user[msg.sender].myCard[_num];
    }
    
    function upgradeCard (uint _num1, uint _num2) public {
        uint length = user[msg.sender].myCard.length;
        require (_num1 < length && _num2 < length, "Cheak Your Card Number!!!");
        require (keccak256(abi.encodePacked(user[msg.sender].myCard[_num1].cardName)) == keccak256(abi.encodePacked(user[msg.sender].myCard[_num2].cardName)), "Not Same Card Name!!!");
        require ((user[msg.sender].myCard[_num1].cardRarity > 0) && (user[msg.sender].myCard[_num1].cardRarity < 4) );
        require (user[msg.sender].myCard[_num1].cardUpgrade == user[msg.sender].myCard[_num2].cardUpgrade, "Not Same Card Upgrade!!!");
        for (uint i = 0; i < AllCardList.length; i++) {
            if ((keccak256(abi.encodePacked(AllCardList[i].cardName)) == keccak256(abi.encodePacked(user[msg.sender].myCard[_num1].cardName))) && (AllCardList[i].cardUpgrade == user[msg.sender].myCard[_num1].cardUpgrade + 1)) {
                user[msg.sender].myCard[_num1] = AllCardList[i];
                delete user[msg.sender].myCard[_num2];
                break;
            }
        }
        
    }
    
    function viewCard (address _address, uint _num) view public returns (card memory) {
        return (user[_address].myCard[_num]);
    }
    
    function viewCardLength (address _address) view public returns (uint) {
        return user[_address].myCard.length;
    }
    
     function viewManager () view public returns (address) {
        return manager;
    }
    
}