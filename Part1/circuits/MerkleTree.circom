pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    // [assignment] insert your code here to calculate the Merkle root from 2^n leaves

    var merkleTree[2*(2**n)-1];
    component hashNodes[2**n-1];

    for (var i = 0; i < 2**n; i++) {
        merkleTree[i] = leaves[i];
    }

    for (var i = 0; i < 2**n-1; i++) {
        hashNodes[i] = Poseidon(2);
        hashNodes[i].inputs[0] <== merkleTree[2*i];
        hashNodes[i].inputs[1] <== merkleTree[2*i+1];
        merkleTree[i+2**n] = hashNodes[i].out;
    }

    root <== hashNodes[2**n-2].out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    // [assignment] insert your code here to compute the root from a leaf and elements along the path

    component hashes[n];
    component switcher[n];

    var merkleTree[n+1];
    merkleTree[0] = leaf;

    for (var i = 0; i < n; i++) {

        hashes[i] = Poseidon(2);
        switcher[i] = Switcher();
        
        switcher[i].sel <== path_index[i];
        switcher[i].L <== merkleTree[i];       
        switcher[i].R <== path_elements[i];

        hashes[i].inputs[0] <== switcher[i].outL;
        hashes[i].inputs[1] <== switcher[i].outR;

        merkleTree[i+1] = hashes[i].out;
    }

    root <== hashes[n-1].out;
}