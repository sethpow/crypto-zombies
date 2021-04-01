pragma solidity >=0.5.0 <0.6.0;

import "./zombiefeeding.sol";

// adding helper methods; zombies can gain special abilities after reaching certain levels
contract ZombieHelper is ZombieFeeding {

    modifier aboveLevel(uint _level, uint _zombieId){
        require(zombies[_zombieId].level >= _level);
        _;
    }

    // Start here
    // calldata is similar to memory, but only available to external functions
    function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].name = _newName;
    }

    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].dna = _newDna;
    }

    // return users entire zombie army; can call from web3.js to display users profile page w/ entire army
    function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
        /*
            You can use the memory keyword with arrays to create a new array inside a function without needing
            to write anything to storage. The array will only exist until the end of the function call, and this
            is a lot cheaper gas-wise than updating an array in storage — free if it's a view function called
            externally.
        */
        uint[] memory result = new uint[](ownerZombieCount[_owner]);

        /*
            iterates through all the zombies in our DApp, compares their owner to see if we have a match,
            and pushes them to our result array before returning it
        */
        uint counter = 0;
        for(uint i = 0; i < zombies.length; i++){
            if(zombieToOwner[i] == _owner){
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }

}