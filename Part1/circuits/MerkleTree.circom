pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template HashingLayer(n) {
    var numLeaves = 2**n;
    signal input ins[numLeaves];
    signal output outs[numLeaves/2];

    component hash[numLeaves/2];
    for (var i = 0; i < numLeaves/2; i++) {
        hash[i] = Poseidon(2);
        ins[i*2] ==> hash[i].inputs[0];
        ins[i*2+1] ==> hash[i].inputs[1];
        hash[i].out ==> outs[i];
    }
}

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    component hasher[n];
    for (var i = n-1; i >= 0; i--) {
        hasher[i] = HashingLayer(i);
        for (var j = 0; j < 2**(i+1); j++) {
            hasher[i].ins[j] <== i == n - 1 ? leaves[j] : hasher[i+1].outs[j];
        }
    }       
    n > 0 ? hasher[0].outs[0] : leaves[0] ==> root;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component hash[n];
    component switcher[n];

    for (var i = 0; i < n; i++) {
        switcher[i] = Switcher();
        switcher[i].L <== i == 0 ? leaf : hash[i - 1].out;
        switcher[i].R <== path_elements[i];
        switcher[i].sel <== path_index[i];

        hash[i] = Poseidon(2); 
        switcher[i].outL ==> hash[i].inputs[0];
        switcher[i].outR ==> hash[i].inputs[1];
    }

    hash[n-1].out ==> root;
}