//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";



contract Auction{
    using Counters for Counters.Counter;

    Counters.Counter private _myCounter;
    uint256 MAX_SUPPLY = 1;

    uint public AuctionDuration;
    address payable owner;
    address[] public bidders;
        uint public leastAmount;
        bool public status;

mapping (address => uint) BiddersTrack;

    constructor(uint _AuctionDuration) ERC721("VeeNFT", "OF"){
        owner = payable (msg.sender);
        AuctionDuration = _AuctionDuration + block.timestamp;
    }

    modifier OnlyOwner(){
        require(msg.sender == owner);
        _;
    }  

    function startAuction(uint _leastAmount) external OnlyOwner { 
        leastAmount = _leastAmount;
        status = true;
        
    }

    function placeBid(uint _amount) public {
        require(status == true, "Bid has not commenced");
        require(block.timestamp < AuctionDuration);
        require(_amount> leastAmount, "You can't bid anything less than the stated least amount");
        
        bidders.push (msg.sender);

        
        BiddersTrack[msg.sender] = _amount;
        

    }

    function safeMint(address to, string memory uri) private{

        uint256 tokenId = _myCounter.current();
        require(tokenId <= MAX_SUPPLY, "Oops!, all NFTs have been minted!");
        _myCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }
    function claimBid(string memory uri) external payable {
        require(msg.sender != address(0), "Zero address can't call this function");
        require(block.timestamp > AuctionDuration, "Auction is still ongoing");
        require(msg.value >= leastAmount, "Can't pay less than highest bid!");
        address HighestBidder = bidders[bidders.length - 1];
        require(msg.sender == HighestBidder, "Only the highest bidder calls this function");

        safeMint(msg.sender, uri);
    }

    function transferToContractOwner () external OnlyOwner{
        require(msg.sender != address(0), "NFT can't be minted to this account");
        require(block.timestamp > AuctionDuration, "Auction has not ended");
        payable (msg.sender).transfer(address(this).balance);
    }
}