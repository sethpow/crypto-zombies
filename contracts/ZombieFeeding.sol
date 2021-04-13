"SPDX-License-Identifier: UNLICENSED"
pragma solidity ^0.8.0;

import "./ZombieFeeding.sol";

// Create KittyInterface here
// allows us to interact with another contract (cryptoKitties); zombies can eat the cats
contract KittyInterface {
    function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
}

contract ZombieFeeding is ZombieFactory {

    // address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;

    // Initialize kittyContract here using `ckAddress` from above
    // KittyInterface kittyContract = KittyInterface(ckAddress);
    KittyInterface kittyContract;

    modifier onlyOwnerOf(uint _zombieId){
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }

    // in case cryptoKitties becomes obsolite
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    // 1. Define `_triggerCooldown` function here
    // Feeding triggers a zombies cooldown; pass storage pointer to Zombie struct
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime);
    }

    // 2. Define `_isReady` function here
    // Zombies cant feed on kitties until their CD period has passed
    function _isReady(Zombie storage _zombie) internal view returns(bool) {
        return (_zombie.readyTime <= now);
    }

    /*  make sure we own this zombie. Add a require statement to verify that msg.sender is equal to this
        zombie's owner (similar to how we did in the createRandomZombie function) */
    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombieId) {
        // declare a local Zombie named myZombie (which will be a storage pointer). Set this variable to be equal to index _zombieId in our zombies array
        Zombie storage myZombie = zombies[_zombieId];

        // check if zombies CD time is over
        require(_isReady(myZombie));

        // ensure _targetDna isnt longer than 16 digits
        _targetDna = _targetDna % dnaModulus;
        // newDna average of myZombie and target; dna for the infected target
        uint newDna = (myZombie.dna + _targetDna) / 2;
        // create kitty zombie
        if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            // replace last 2 digits of DNA with 99
            // Assume newDna is 334455. Then newDna % 100 is 55, so newDna - newDna % 100 is 334400. Finally add 99 to get 334499
            newDna = newDna - newDna % 100 + 99;
        }
        // create the new zombie
        _createZombie("NoName", newDna);

        // feeding triggers the zombies CD time
        _triggerCooldown(myZombie);
    }

    // get kitty genes from contract
    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }

}