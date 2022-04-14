import { useState, useEffect } from "react";

import Body from "./components/Body";
import Navbar from "./components/Navbar";

import Web3 from "web3";
import { newKitFromWeb3 } from "@celo/contractkit";
import BigNumber from "bignumber.js";

import floral from "./contracts/floral.abi.json";
import ierc from "./contracts/ierc.abi.json";

function App() {
  const ERC20_DECIMALS = 18;

  const contractAddress = "0xc1fd49bA5FB5bC03b08F937e56b0BEF27660A72F";
  const cUSDContractAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1";
  const [contract, setcontract] = useState(null);
  const [address, setAddress] = useState(null);
  const [kit, setKit] = useState(null);
  const [balance, setBalance] = useState(0);
  const [flowers, setFlowers] = useState([]);

  const connectToCelo = async () => {
    if (window.celo) {
      try {
        await window.celo.enable();
        const web3 = new Web3(window.celo);
        let kit = newKitFromWeb3(web3);

        const accounts = await kit.web3.eth.getAccounts();
        const user_address = accounts[0];

        kit.defaultAccount = user_address;

        await setAddress(user_address);
        await setKit(kit);
        console.log(user_address);
      } catch (error) {
        console.log(error);
      }
    } else {
      console.log("Error");
    }
  };

  const getBalance = async () => {
    try {
      const balance = await kit.getTotalBalance(address);
      const USDBalance = balance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2);

      const contract = new kit.web3.eth.Contract(floral, contractAddress);
      setcontract(contract);
      setBalance(USDBalance);
    } catch (error) {
      console.log(error);
    }
  };

  const addFlower = async (name, image, description, quantity, _amount) => {
    const amount = new BigNumber(_amount).shiftedBy(ERC20_DECIMALS).toString();
    try {
      await contract.methods
        .createArt(name, image, description, amount, quantity)
        .send({ from: address });
    } catch (error) {
      console.log(error);
    } finally {
      getFlowers();
    }
  };

  useEffect(() => {
    connectToCelo();
  }, []);

  useEffect(() => {
    if (kit && address) {
      getBalance();
    } else {
      console.log("no kit");
    }
  }, [kit, address]);

  const getFlowers = async () => {
    const artLength = await contract.methods.getArtLength().call();
    const _flowers = [];

    for (let index = 0; index < artLength; index++) {
      let _flower = new Promise(async (resolve, reject) => {
        let flower = await contract.methods.getArt(index).call();
        resolve({
          index: index,
          owner: flower[0],
          name: flower[1],
          image: flower[2],
          description: flower[3],
          amount: flower[4],
          quantity: flower[5],
        });
      });
      _flowers.push(_flower);
    }
    const flowers = await Promise.all(_flowers);
    setFlowers(flowers);
  };

  useEffect(() => {
    if (contract) {
      getFlowers();
    }
  }, [contract]);

  const buyFlower = async (_index) => {
    const cUSDContract = new kit.web3.eth.Contract(ierc, cUSDContractAddress);
    try {
      await cUSDContract.methods
        .approve(contractAddress, flowers[_index].amount)
        .send({ from: address });
      await contract.methods.buyArt(_index).send({ from: address });
    } catch (error) {
      console.log(error);
    } finally {
      getBalance();
      getFlowers();
    }
  };

  const editQuantity = async (index, quantity) => {
    try {
      await contract.methods
        .editQuantity(index, quantity)
        .send({ from: address });
    } catch (error) {
      console.log(error);
    } finally {
      getFlowers();
    }
  };
  return (
    <>
      <Navbar balance={balance} />
      <Body
      address = {address}
        addFlower={addFlower}
        flowers={flowers}
        buyFlowers={buyFlower}
        editQuantity={editQuantity}
      />
    </>
  );
}

export default App;
