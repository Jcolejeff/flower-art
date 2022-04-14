// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract FloralHome{
    struct FloralArt{
        address payable owner;
        string name;
        string image;
        string description;
        uint amount;
        uint quantity;
    }
        address internal cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    mapping(uint256=>FloralArt) internal arts;
    uint256 artLength = 0;

    function createArt(
        string memory _name,
        string memory _image,
        string memory _description,
        uint _amount,
        uint _quanitity
    )public{
        require (_quanitity > 0 , "Quantity must be greater than zero");
        arts[artLength] = FloralArt(
            payable(msg.sender),
            _name,
            _image,
            _description,
            _amount,
            _quanitity
        );
        artLength++;
    }

    function getArt(uint index)public view returns(
        address payable, 
        string memory,
        string memory,
        string memory,
        uint,
        uint
    ){
        FloralArt storage art = arts[index]; 
        return(
            art.owner,
            art.name,
            art.image,
            art.description,
            art.amount,
            art.quantity
        );
    }

    function buyArt(uint index)public payable{
        require(arts[index].quantity >= 0, "Cannot perform transaction");
         require(
             IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                arts[index].owner,
                arts[index].amount
            ),
            "Transaction could not be performed"
        );
        arts[index].quantity -= 1;
    }

    function editQuantity(uint index, uint  quantity)public{
        arts[index].quantity += quantity;
    }

    function getArtLength()public view returns(uint){
        return artLength;
    }

}