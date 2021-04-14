pragma solidity >=0.5.0 <0.6.0;

import "./zombieattack.sol";
import "./erc721.sol";

/// @title A contract that manages transferring zombie ownership
/// @author Seth
/// @dev Compliant with OpenZeppelin's implementation of the ERC721 spec draft
contract ZombieOwnership is ZombieAttack, ERC721 {
    // make sure only the owner or the approved address of a token/zombie can transfer it
    mapping(uint => address) zombieApprovals;

    function balanceOf(address _owner) external view returns (uint256) {
        // 1. Return the number of zombies `_owner` has here
        return ownerZombieCount[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        // 2. Return the owner of `_tokenId/zombieId` here
        return zombieToOwner[_tokenId];
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        // 1. Replace with SafeMath's `add`
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        // 2. Replace with SafeMath's `sub`
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);

        zombieToOwner[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        // 2. Add the require statement here
        require(zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
        // 3. Call _transfer
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
        zombieApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }
}
