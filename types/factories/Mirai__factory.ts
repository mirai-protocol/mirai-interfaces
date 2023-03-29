/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { Mirai, MiraiInterface } from "../Mirai";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "admin",
        type: "address",
      },
      {
        internalType: "address",
        name: "installerModule",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "totalBalances",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "totalBorrows",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint96",
        name: "reserveBalance",
        type: "uint96",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "poolSize",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "interestAccumulator",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "int96",
        name: "interestRate",
        type: "int96",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "timestamp",
        type: "uint256",
      },
    ],
    name: "AssetStatus",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "Borrow",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "delegate",
        type: "address",
      },
    ],
    name: "DelegateAverageLiquidity",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "Deposit",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "EnterMarket",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "ExitMarket",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [],
    name: "Genesis",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "recipient",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "GovConvertReserves",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        components: [
          {
            internalType: "address",
            name: "mTokenAddress",
            type: "address",
          },
          {
            internalType: "bool",
            name: "borrowIsolated",
            type: "bool",
          },
          {
            internalType: "uint32",
            name: "collateralFactor",
            type: "uint32",
          },
          {
            internalType: "uint32",
            name: "borrowFactor",
            type: "uint32",
          },
          {
            internalType: "uint24",
            name: "twapWindow",
            type: "uint24",
          },
        ],
        indexed: false,
        internalType: "struct Storage.AssetConfig",
        name: "newConfig",
        type: "tuple",
      },
    ],
    name: "GovSetAssetConfig",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "chainlinkAggregator",
        type: "address",
      },
    ],
    name: "GovSetChainlinkPriceFeed",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "interestRateModel",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "bytes",
        name: "resetParams",
        type: "bytes",
      },
    ],
    name: "GovSetIRM",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint16",
        name: "newPricingType",
        type: "uint16",
      },
      {
        indexed: false,
        internalType: "uint32",
        name: "newPricingParameter",
        type: "uint32",
      },
    ],
    name: "GovSetPricingConfig",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint32",
        name: "newReserveFee",
        type: "uint32",
      },
    ],
    name: "GovSetReserveFee",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "uint256",
        name: "moduleId",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "address",
        name: "moduleImpl",
        type: "address",
      },
      {
        indexed: false,
        internalType: "bytes32",
        name: "moduleGitCommit",
        type: "bytes32",
      },
    ],
    name: "InstallerInstallModule",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "newGovernorAdmin",
        type: "address",
      },
    ],
    name: "InstallerSetGovernorAdmin",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "newUpgradeAdmin",
        type: "address",
      },
    ],
    name: "InstallerSetUpgradeAdmin",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "liquidator",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "violator",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "collateral",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "repay",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "_yield",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "healthScore",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "baseDiscount",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "discount",
        type: "uint256",
      },
    ],
    name: "Liquidation",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "mToken",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "dToken",
        type: "address",
      },
    ],
    name: "MarketActivated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "pToken",
        type: "address",
      },
    ],
    name: "PTokenActivated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "PTokenUnWrap",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "PTokenWrap",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "proxy",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "moduleId",
        type: "uint256",
      },
    ],
    name: "ProxyCreated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "Repay",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "RequestBorrow",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "RequestBurn",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "RequestDeposit",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "RequestDonate",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "liquidator",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "violator",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "collateral",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "repay",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "minYield",
        type: "uint256",
      },
    ],
    name: "RequestLiquidate",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "RequestMint",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "RequestRepay",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "accountIn",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "accountOut",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "underlyingIn",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "underlyingOut",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "swapType",
        type: "uint256",
      },
    ],
    name: "RequestSwap",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "accountIn",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "accountOut",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "underlyingIn",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "underlyingOut",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amountIn",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amountOut",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "mode",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "address",
        name: "swapHandler",
        type: "address",
      },
    ],
    name: "RequestSwapHub",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "accountIn",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "accountOut",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "underlyingIn",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "underlyingOut",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "targetDebt",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "address",
        name: "swapHandler",
        type: "address",
      },
    ],
    name: "RequestSwapHubRepay",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "RequestTransferDToken",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "RequestTransferMToken",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "RequestWithdraw",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "TrackAverageLiquidity",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "UnTrackAverageLiquidity",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "underlying",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "Withdraw",
    type: "event",
  },
  {
    inputs: [],
    name: "dispatch",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "moduleId",
        type: "uint256",
      },
    ],
    name: "moduleIdToImplementation",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "moduleId",
        type: "uint256",
      },
    ],
    name: "moduleIdToProxy",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "name",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
];

export class Mirai__factory {
  static readonly abi = _abi;
  static createInterface(): MiraiInterface {
    return new utils.Interface(_abi) as MiraiInterface;
  }
  static connect(address: string, signerOrProvider: Signer | Provider): Mirai {
    return new Contract(address, _abi, signerOrProvider) as Mirai;
  }
}
