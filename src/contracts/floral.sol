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
    // adding a delete functionality
    struct FloralArt{
        address payable owner;
        uint artId;
        string name;
        string image;
        string description;
        uint amount;
        uint quantity;
    }
        address internal cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    FloralArt[] internal arts;
    uint256 artId = 0; // id of each art, always incrementing to keep it unique

    event Artcreated(address indexed owner, uint256 artId);
    event Artdeleted(uint256 indexed artId, uint256 index);
    event ArtBought(address indexed from, address to, uint256 artId);
    event ArtOutOfStock(address indexed owner, uint256 artId);

    function createArt(
        string memory _name,
        string memory _image,
        string memory _description,
        uint _amount,
        uint _quanitity
    ) public {
        require (_quanitity > 0 , "Quantity must be greater than zero");
        // pushing into array
        arts.push(FloralArt(
            payable(msg.sender),
            artId,
            _name,
            _image,
            _description,
            _amount,
            _quanitity
        ));
        emit Artcreated(msg.sender, artId);
        artId++;
    }

    // steps to run this binarySearch function. 
    // You can create an array of art ids from your react frontend using JavaScript and pass it as parameter
    // Also send the id of target art that you want as an arguement and the array length.
    // Then this function can return you the index of that art in the array.
    // After that call other functions from react only, you should not call another function internally from this function.
    function binarySearch(uint[] memory artIds, uint _target, uint _maxArrayLength) public pure returns(uint256 _index) {
        // arrIds are always going to be a sorted array, as arrId is always increasing
        uint start = 0;
        uint end = _maxArrayLength - 1;
        uint mid = start + (end - start) / 2; // optimised to always get the correct mid value
        while (true) {
            if (artIds[mid] > _target)
                end = mid - 1;
            else if (artIds[mid] < _target)
                start = mid + 1;
            else 
                return mid;
            mid = start + (end - start) / 2;
        }
        // if not found don't return anything
    }

    // function to delete an art.
    function deleteArt(uint256 _targetIndex) public returns (bool) {
        arts[_targetIndex] = arts[arts.length - 1];
        arts.pop(); // deletes the FloralArt struct at that index, with your desired artId.
        emit Artdeleted(artId, _targetIndex);
        return true;
    }

    // we are using an array now, so call the binarySearch function first from your react code and pass in the
    // artIds array, target art id and the array length to get the index of your desired art.
    // then call this function from the react frontend with right arguement and it will work fine.
    function getArt(uint index)public view returns(
        address payable, 
        uint,
        string memory,
        string memory,
        string memory,
        uint,
        uint
    ){
        FloralArt memory art = arts[index]; 
        return(
            art.owner,
            art.artId,
            art.name,
            art.image,
            art.description,
            art.amount,
            art.quantity
        );
    }

    // we are using an array now, so call the binarySearch function first from your react code and pass in the
    // artIds array, target art id and the array length to get the index of your desired art.
    // then call this function from the react frontend with right arguement and it will work fine.
    function buyArt(uint index, uint _quantity)public payable{
        //Checks if the quantity available for sale is lesser than the quantity specified 
        require(_quantity <= arts[index].quantity, "Specified quantity is higer than the available quantity");
         require(
             IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                arts[index].owner,
                arts[index].amount * _quantity
            ),
            "Transaction could not be performed"
        );
        emit ArtBought(arts[index].owner, msg.sender, arts[index].artId);
        arts[index].quantity -= _quantity;
        if (arts[index].quantity == 0)
            emit ArtOutOfStock(arts[index].owner, arts[index].artId);
        // trigger an event if the quantity becomes 0 and ask the user to update the quantity of the product.
    }

    // we are using an array now, so call the binarySearch function first from your react code and pass in the
    // artIds array, target art id and the array length to get the index of your desired art.
    // then call this function from the react frontend with right arguement and it will work fine.
    function editQuantity(uint index, uint  quantity)public{
        arts[index].quantity += quantity;
    }

    function getArtLength()public view returns(uint){
        return arts.length; // return uint as the length of the array.
    }

}