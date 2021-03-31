"SPDX-License-Identifier: UNLICENSED"
pragma solidity ^0.8.0;
// pragma solidity >=0.5.0 <0.6.0;

contract ZombieFactory {
    // declare our event here
    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    // declare mappings here
        // keeps track of the address that owns a zombie; lookup by zombie id
    mapping(uint => address) public zombieToOwner;
        // keeps track of how many zombies an owner has
    mapping(address => uint) ownerZombieCount;

    function _createZombie(string memory _name, uint _dna) internal {
        // returns a uint of the new length of array; use for the id
        uint id = zombies.push(Zombie(_name, _dna)) - 1;

        // after we get back the new zombie's id, let's update our zombieToOwner mapping to store msg.sender under that id
        zombieToOwner[id] = msg.sender;
        // increase ownerZombieCount for this msg.sender
        ownerZombieCount[msg.sender]++;

        // and fire it here
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string memory _str) private view returns (uint) {
        // type casting from keccak to uint
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        // make sure this function only gets executed one time per user, when they create their first zombie
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}
