import { ethers } from 'hardhat'
import { Erc721TokenPayableMint } from "typechain/Erc721TokenPayableMint"
import { NftDescriptor } from "typechain/NftDescriptor"

const main = async () => {
  const account1 = "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266";
  const account2 = "0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc";
  const signer = await ethers.provider.getSigner(account1)
  const signer2 = await ethers.provider.getSigner(account2)

  const Lib = await ethers.getContractFactory("NFTDescriptor")
  const lib = (await Lib.connect(signer).deploy()) as NftDescriptor
  await lib.deployed()
  console.log('NftDescriptor txHash:', lib.deployTransaction.hash);
  console.log('NftDescriptor address:', lib.address);

  const Contract = await ethers.getContractFactory(
    "ERC721TokenPayableMint",
    { libraries:
      {
        NFTDescriptor: lib.address
      }
    }
  );
  var contract: Erc721TokenPayableMint
  contract = (await Contract.connect(signer).deploy()) as Erc721TokenPayableMint
  console.log('Erc721Token txHash:', contract.deployTransaction.hash);
  console.log('Erc721Token address:', contract.address);

  const contract2 = (await ethers.getContractAt("ERC721TokenPayableMint", contract.address, signer2)) as Erc721TokenPayableMint
  const txMint = await contract2.mintPayable(1, {
    value: ethers.utils.parseEther("1.0")
  }); 
  console.log(txMint);

  const txTokenOwner = await contract2.ownerOf(1);
  console.log(txTokenOwner);

  const txTokenUri = await contract.tokenURI(1);
  console.log(txTokenUri);

  const txMint2 = await contract2.mintPayable(2, {
    value: ethers.utils.parseEther("0.1")
  });
  console.log(txMint2);

  return
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });