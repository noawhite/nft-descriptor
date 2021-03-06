import { ethers } from 'hardhat'
import { Erc721Token } from "typechain/Erc721Token"
import { NftDescriptor } from "typechain/NftDescriptor"

const main = async () => {
  const account1 = "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266";
  const account2 = "0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc";
  const signer = await ethers.provider.getSigner(account1)

  const Lib = await ethers.getContractFactory("NFTDescriptor")
  const lib = (await Lib.connect(signer).deploy()) as NftDescriptor
  await lib.deployed()
  console.log('NftDescriptor txHash:', lib.deployTransaction.hash);
  console.log('NftDescriptor address:', lib.address);

  const Contract = await ethers.getContractFactory(
    "ERC721Token",
    { libraries:
      {
        NFTDescriptor: lib.address
      }
    }
  );
  var contract: Erc721Token
  contract = (await Contract.connect(signer).deploy()) as Erc721Token
  console.log('Erc721Token txHash:', contract.deployTransaction.hash);
  console.log('Erc721Token address:', contract.address);

  const tx = await contract.tokenURI(1);
  console.log(tx);

  return
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });