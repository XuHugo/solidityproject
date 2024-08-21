import * as fs from 'fs'
import {StandardMerkleTree} from '@openzeppelin/merkle-tree'

// 1. build a tree
const elements = [
    ['0x0000000000000000000000000000000000000001', 1],
    ['0x0000000000000000000000000000000000000002', 2],
    ['0x0000000000000000000000000000000000000003', 3],
    ['0x0000000000000000000000000000000000000004', 4],
    ['0x0000000000000000000000000000000000000005', 5],
    ['0x0000000000000000000000000000000000000006', 6],
    ['0x0000000000000000000000000000000000000007', 7],
    ['0x0000000000000000000000000000000000000008', 8],
]

let merkleTree = StandardMerkleTree.of(elements, ['address', 'uint256'])
const root = merkleTree.root
const tree = merkleTree.dump()
console.log(merkleTree.render());
fs.writeFileSync('tree.json', JSON.stringify(tree))
fs.writeFileSync('root.json', JSON.stringify({root:root}))

// get proof
const proofs = []
const mtree = StandardMerkleTree.load(JSON.parse(fs.readFileSync("tree.json", "utf8")));
for (const [i, v] of mtree.entries()) {
  proofs.push({'account':v[0], 'amount':v[1],'proof':mtree.getProof(i)})
  if (v[0] === '0x0000000000000000000000000000000000000001') {
    const proof = mtree.getProof(i);
    console.log('Value:', v);
    console.log('Proof:', proof);
  }
}
fs.writeFileSync('proofs.json', JSON.stringify(proofs))
