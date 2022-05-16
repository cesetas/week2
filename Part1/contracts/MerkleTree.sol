//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root
    //uint256[] public nodes;
    using PoseidonT3 for uint256;

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        hashes = [0,0,0,0,0,0,0,0];  
        for(uint i = 0; i < 7; i++) {
            hashes.push(PoseidonT3.poseidon([hashes[i*2], hashes[i*2+1]]));
        }
        root = hashes[14];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        // hashes.push(hashedLeaf);
        // root = PoseidonT3.poseidon([hashes[(hashes.length-2)],hashedLeaf]);
        // hashes.push(root);
        // return root;
        //hashes = [0,0,0,0,0,0,0,0]; 
        hashes[index] = hashedLeaf;
        if(index < 7){
            index += 1;
        } else {
            index = 0;
        }
        for(uint i = 0; i < 7; i++) {
            hashes[i+8] = PoseidonT3.poseidon([hashes[i*2], hashes[i*2+1]]);
        }
        root = hashes[14];
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (inputValues[input.length-1] == root) {
            return true;
        } else {
            return false;
        }       
    }
}
