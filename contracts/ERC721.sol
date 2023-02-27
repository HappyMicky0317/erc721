// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract ERC721 {
    mapping(address => uint256) internal balances;
    mapping(uint256 => address) internal owners;
    mapping(address => mapping(address => bool)) private operatorApprovals; // NFT owner => operator => approved or not
    mapping(uint256 => address) private tokenApprovals; // token ID => approved address

    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 _tokenId
    );
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    // Returns the number of NFTs assigned to an owner
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "Address is zero");
        return balances[_owner];
    }

    // Finds the owner of an NFT
    function ownerOf(uint256 _tokenId)
        public
        view
        tokenIdExists(_tokenId)
        returns (address)
    {
        return owners[_tokenId];
    }

    // OPERATOR
    // Enables or disables an operator to manage all of msg.sender's assets
    function setApprovalForAll(address _operator, bool _approved) public {
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // Checks if an address is an operator for another address
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        returns (bool)
    {
        return operatorApprovals[_owner][_operator];
    }

    // APPROVAL
    // Updates an approved address for an NFT
    function approve(address _to, uint256 _tokenId) public {
        address owner = ownerOf(_tokenId);
        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "Msg.sender is not the owner or an approved operator"
        );
        tokenApprovals[_tokenId] = _to;
        emit Approval(owner, _to, _tokenId);
    }

    // Gets the approved address for a single NFT
    function getApproved(uint256 _tokenId)
        public
        view
        tokenIdExists(_tokenId)
        returns (address)
    {
        return tokenApprovals[_tokenId];
    }

    // TRANSFER
    // Transfers ownership of an NFT
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public tokenIdExists(_tokenId) {
        address owner = ownerOf(_tokenId);
        require(
            msg.sender == owner ||
                getApproved(_tokenId) == msg.sender ||
                isApprovedForAll(owner, msg.sender),
            "Msg.sender is not the owner or approved for transfer"
        );
        require(owner == _from, "From address is not the owner");
        require(_to != address(0), "Address is zero");
        approve(address(0), _tokenId);

        balances[_from] -= 1;
        balances[_to] += 1;
        owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    // Standard transferFrom
    // Check if onERC721Received is implemented WHEN sending to smart contracts
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) public {
        transferFrom(_from, _to, _tokenId);
        require(checkOnERC721Received(), "Receiver not implemented");
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    // Oversimplified => what would actually do: call the smart contract's onERC721Received function and check if any response is given
    function checkOnERC721Received() private pure returns (bool) {
        return true;
    }

    // EIP165: Query if a contract implements another interface (checks if another smart contract have the functions that are been looked for)
    function supportsInterface(bytes4 _interfaceId)
        public
        pure
        virtual
        returns (bool)
    {
        return _interfaceId == 0x80ac58cd;
    }

    modifier tokenIdExists(uint256 _tokenId) {
        require(owners[_tokenId] != address(0), "TokenId does not exist");
        _;
    }
}
