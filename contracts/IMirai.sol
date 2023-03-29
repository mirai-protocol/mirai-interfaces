// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;
pragma abicoder v2;


/// @notice Main storage contract for the Mirai system
interface IMirai {
    /// @notice Lookup the current implementation contract for a module
    /// @param moduleId Fixed constant that refers to a module type (ie MODULEID__MTOKEN)
    /// @return An internal address specifies the module's implementation code
    function moduleIdToImplementation(uint moduleId) external view returns (address);

    /// @notice Lookup a proxy that can be used to interact with a module (only valid for single-proxy modules)
    /// @param moduleId Fixed constant that refers to a module type (ie MODULEID__MARKETS)
    /// @return An address that should be cast to the appropriate module interface, ie IMiraiMarkets(moduleIdToProxy(2))
    function moduleIdToProxy(uint moduleId) external view returns (address);

    /// @notice Mirai-related configuration for an asset
    struct AssetConfig {
        address mTokenAddress;
        bool borrowIsolated;
        uint32 collateralFactor;
        uint32 borrowFactor;
        uint24 twapWindow;
    }
}


/// @notice Activating and querying markets, and maintaining entered markets lists
interface IMiraiMarkets {
    /// @notice Create an Mirai pool and associated MToken and DToken addresses.
    /// @param underlying The address of an ERC20-compliant token. There must be an initialised uniswap3 pool for the underlying/reference asset pair.
    /// @return The created MToken, or the existing MToken if already activated.
    function activateMarket(address underlying) external returns (address);

    /// @notice Create a pToken and activate it on Mirai. pTokens are protected wrappers around assets that prevent borrowing.
    /// @param underlying The address of an ERC20-compliant token. There must already be an activated market on Mirai for this underlying, and it must have a non-zero collateral factor.
    /// @return The created pToken, or an existing one if already activated.
    function activatePToken(address underlying) external returns (address);

    /// @notice Given an underlying, lookup the associated MToken
    /// @param underlying Token address
    /// @return MToken address, or address(0) if not activated
    function underlyingToMToken(address underlying) external view returns (address);

    /// @notice Given an underlying, lookup the associated DToken
    /// @param underlying Token address
    /// @return DToken address, or address(0) if not activated
    function underlyingToDToken(address underlying) external view returns (address);

    /// @notice Given an underlying, lookup the associated PToken
    /// @param underlying Token address
    /// @return PToken address, or address(0) if it doesn't exist
    function underlyingToPToken(address underlying) external view returns (address);

    /// @notice Looks up the Mirai-related configuration for a token, and resolves all default-value placeholders to their currently configured values.
    /// @param underlying Token address
    /// @return Configuration struct
    function underlyingToAssetConfig(address underlying) external view returns (IMirai.AssetConfig memory);

    /// @notice Looks up the Mirai-related configuration for a token, and returns it unresolved (with default-value placeholders)
    /// @param underlying Token address
    /// @return config Configuration struct
    function underlyingToAssetConfigUnresolved(address underlying) external view returns (IMirai.AssetConfig memory config);

    /// @notice Given an MToken address, looks up the associated underlying
    /// @param mToken MToken address
    /// @return underlying Token address
    function mTokenToUnderlying(address mToken) external view returns (address underlying);

    /// @notice Given a DToken address, looks up the associated underlying
    /// @param dToken DToken address
    /// @return underlying Token address
    function dTokenToUnderlying(address dToken) external view returns (address underlying);

    /// @notice Given an MToken address, looks up the associated DToken
    /// @param mToken MToken address
    /// @return dTokenAddr DToken address
    function mTokenToDToken(address mToken) external view returns (address dTokenAddr);

    /// @notice Looks up an asset's currently configured interest rate model
    /// @param underlying Token address
    /// @return Module ID that represents the interest rate model (IRM)
    function interestRateModel(address underlying) external view returns (uint);

    /// @notice Retrieves the current interest rate for an asset
    /// @param underlying Token address
    /// @return The interest rate in yield-per-second, scaled by 10**27
    function interestRate(address underlying) external view returns (int96);

    /// @notice Retrieves the current interest rate accumulator for an asset
    /// @param underlying Token address
    /// @return An opaque accumulator that increases as interest is accrued
    function interestAccumulator(address underlying) external view returns (uint);

    /// @notice Retrieves the reserve fee in effect for an asset
    /// @param underlying Token address
    /// @return Amount of interest that is redirected to the reserves, as a fraction scaled by RESERVE_FEE_SCALE (4e9)
    function reserveFee(address underlying) external view returns (uint32);

    /// @notice Retrieves the pricing config for an asset
    /// @param underlying Token address
    /// @return pricingType (1=pegged, 2=uniswap3, 3=forwarded, 4=chainlink)
    /// @return pricingParameters If uniswap3 pricingType then this represents the uniswap pool fee used, if chainlink pricing type this represents the fallback uniswap pool fee or 0 if none
    /// @return pricingForwarded If forwarded pricingType then this is the address prices are forwarded to, otherwise address(0)
    function getPricingConfig(address underlying) external view returns (uint16 pricingType, uint32 pricingParameters, address pricingForwarded);

    /// @notice Retrieves the Chainlink price feed config for an asset
    /// @param underlying Token address
    /// @return chainlinkAggregator Chainlink aggregator proxy address
    function getChainlinkPriceFeedConfig(address underlying) external view returns (address chainlinkAggregator);

    /// @notice Retrieves the list of entered markets for an account (assets enabled for collateral or borrowing)
    /// @param account User account
    /// @return List of underlying token addresses
    function getEnteredMarkets(address account) external view returns (address[] memory);

    /// @notice Add an asset to the entered market list, or do nothing if already entered
    /// @param subAccountId 0 for primary, 1-255 for a sub-account
    /// @param newMarket Underlying token address
    function enterMarket(uint subAccountId, address newMarket) external;

    /// @notice Remove an asset from the entered market list, or do nothing if not already present
    /// @param subAccountId 0 for primary, 1-255 for a sub-account
    /// @param oldMarket Underlying token address
    function exitMarket(uint subAccountId, address oldMarket) external;
}


/// @notice Definition of callback method that deferLiquidityCheck will invoke on your contract
interface IDeferredLiquidityCheck {
    function onDeferredLiquidityCheck(bytes memory data) external;
}

/// @notice Batch executions, liquidity check deferrals, and interfaces to fetch prices and account liquidity
interface IMiraiExec {
    /// @notice Liquidity status for an account, either in aggregate or for a particular asset
    struct LiquidityStatus {
        uint collateralValue;
        uint liabilityValue;
        uint numBorrows;
        bool borrowIsolated;
    }

    /// @notice Aggregate struct for reporting detailed (per-asset) liquidity for an account
    struct AssetLiquidity {
        address underlying;
        LiquidityStatus status;
    }

    /// @notice Single item in a batch request
    struct MiraiBatchItem {
        bool allowError;
        address proxyAddr;
        bytes data;
    }

    /// @notice Single item in a batch response
    struct MiraiBatchItemResponse {
        bool success;
        bytes result;
    }

    /// @notice Error containing results of a simulated batch dispatch
    error BatchDispatchSimulation(MiraiBatchItemResponse[] simulation);

    /// @notice Compute aggregate liquidity for an account
    /// @param account User address
    /// @return status Aggregate liquidity (sum of all entered assets)
    function liquidity(address account) external view returns (LiquidityStatus memory status);

    /// @notice Compute detailed liquidity for an account, broken down by asset
    /// @param account User address
    /// @return assets List of user's entered assets and each asset's corresponding liquidity
    function detailedLiquidity(address account) external view returns (AssetLiquidity[] memory assets);

    /// @notice Retrieve Mirai's view of an asset's price
    /// @param underlying Token address
    /// @return twap Time-weighted average price
    /// @return twapPeriod TWAP duration, either the twapWindow value in AssetConfig, or less if that duration not available
    function getPrice(address underlying) external view returns (uint twap, uint twapPeriod);

    /// @notice Retrieve Mirai's view of an asset's price, as well as the current marginal price on uniswap
    /// @param underlying Token address
    /// @return twap Time-weighted average price
    /// @return twapPeriod TWAP duration, either the twapWindow value in AssetConfig, or less if that duration not available
    /// @return currPrice The current marginal price on uniswap3 (informational: not used anywhere in the Mirai protocol)
    function getPriceFull(address underlying) external view returns (uint twap, uint twapPeriod, uint currPrice);

    /// @notice Defer liquidity checking for an account, to perform rebalancing, flash loans, etc. msg.sender must implement IDeferredLiquidityCheck
    /// @param account The account to defer liquidity for. Usually address(this), although not always
    /// @param data Passed through to the onDeferredLiquidityCheck() callback, so contracts don't need to store transient data in storage
    function deferLiquidityCheck(address account, bytes memory data) external;

    /// @notice Execute several operations in a single transaction
    /// @param items List of operations to execute
    /// @param deferLiquidityChecks List of user accounts to defer liquidity checks for
    function batchDispatch(MiraiBatchItem[] calldata items, address[] calldata deferLiquidityChecks) external;

    /// @notice Call batch dispatch, but instruct it to revert with the responses, before the liquidity checks.
    /// @param items List of operations to execute
    /// @param deferLiquidityChecks List of user accounts to defer liquidity checks for
    /// @dev During simulation all batch items are executed, regardless of the `allowError` flag
    function batchDispatchSimulate(MiraiBatchItem[] calldata items, address[] calldata deferLiquidityChecks) external;

    /// @notice Enable average liquidity tracking for your account. Operations will cost more gas, but you may get additional benefits when performing liquidations
    /// @param subAccountId subAccountId 0 for primary, 1-255 for a sub-account. 
    /// @param delegate An address of another account that you would allow to use the benefits of your account's average liquidity (use the null address if you don't care about this). The other address must also reciprocally delegate to your account.
    /// @param onlyDelegate Set this flag to skip tracking average liquidity and only set the delegate.
    function trackAverageLiquidity(uint subAccountId, address delegate, bool onlyDelegate) external;

    /// @notice Disable average liquidity tracking for your account and remove delegate
    /// @param subAccountId subAccountId 0 for primary, 1-255 for a sub-account
    function unTrackAverageLiquidity(uint subAccountId) external;

    /// @notice Retrieve the average liquidity for an account
    /// @param account User account (xor in subAccountId, if applicable)
    /// @return The average liquidity, in terms of the reference asset, and post risk-adjustment
    function getAverageLiquidity(address account) external returns (uint);

    /// @notice Retrieve the average liquidity for an account or a delegate account, if set
    /// @param account User account (xor in subAccountId, if applicable)
    /// @return The average liquidity, in terms of the reference asset, and post risk-adjustment
    function getAverageLiquidityWithDelegate(address account) external returns (uint);

    /// @notice Retrieve the account which delegates average liquidity for an account, if set
    /// @param account User account (xor in subAccountId, if applicable)
    /// @return The average liquidity delegate account
    function getAverageLiquidityDelegateAccount(address account) external view returns (address);

    /// @notice Transfer underlying tokens from sender's wallet into the pToken wrapper. Allowance should be set for the mirai address.
    /// @param underlying Token address
    /// @param amount The amount to wrap in underlying units
    function pTokenWrap(address underlying, uint amount) external;

    /// @notice Transfer underlying tokens from the pToken wrapper to the sender's wallet.
    /// @param underlying Token address
    /// @param amount The amount to unwrap in underlying units
    function pTokenUnWrap(address underlying, uint amount) external;

    /// @notice Apply EIP2612 signed permit on a target token from sender to mirai contract
    /// @param token Token address
    /// @param value Allowance value
    /// @param deadline Permit expiry timestamp
    /// @param v secp256k1 signature v
    /// @param r secp256k1 signature r
    /// @param s secp256k1 signature s
    function usePermit(address token, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    /// @notice Apply DAI like (allowed) signed permit on a target token from sender to mirai contract
    /// @param token Token address
    /// @param nonce Sender nonce
    /// @param expiry Permit expiry timestamp
    /// @param allowed If true, set unlimited allowance, otherwise set zero allowance
    /// @param v secp256k1 signature v
    /// @param r secp256k1 signature r
    /// @param s secp256k1 signature s
    function usePermitAllowed(address token, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;

    /// @notice Apply allowance to tokens expecting the signature packed in a single bytes param
    /// @param token Token address
    /// @param value Allowance value
    /// @param deadline Permit expiry timestamp
    /// @param signature secp256k1 signature encoded as rsv
    function usePermitPacked(address token, uint256 value, uint256 deadline, bytes calldata signature) external;

    /// @notice Execute a staticcall to an arbitrary address with an arbitrary payload.
    /// @param contractAddress Address of the contract to call
    /// @param payload Encoded call payload
    /// @return result Encoded return data
    /// @dev Intended to be used in static-called batches, to e.g. provide detailed information about the impacts of the simulated operation.
    function doStaticCall(address contractAddress, bytes memory payload) external view returns (bytes memory);
}


/// @notice Tokenised representation of assets
interface IMiraiMToken {
    /// @notice Pool name, ie "Mirai Pool: DAI"
    function name() external view returns (string memory);

    /// @notice Pool symbol, ie "eDAI"
    function symbol() external view returns (string memory);

    /// @notice Decimals, always normalised to 18.
    function decimals() external pure returns (uint8);

    /// @notice Address of underlying asset
    function underlyingAsset() external view returns (address);

    /// @notice Sum of all balances, in internal book-keeping units (non-increasing)
    function totalSupply() external view returns (uint);

    /// @notice Sum of all balances, in underlying units (increases as interest is earned)
    function totalSupplyUnderlying() external view returns (uint);

    /// @notice Balance of a particular account, in internal book-keeping units (non-increasing)
    function balanceOf(address account) external view returns (uint);

    /// @notice Balance of a particular account, in underlying units (increases as interest is earned)
    function balanceOfUnderlying(address account) external view returns (uint);

    /// @notice Balance of the reserves, in internal book-keeping units (non-increasing)
    function reserveBalance() external view returns (uint);

    /// @notice Balance of the reserves, in underlying units (increases as interest is earned)
    function reserveBalanceUnderlying() external view returns (uint);

    /// @notice Convert an mToken balance to an underlying amount, taking into account current exchange rate
    /// @param balance mToken balance, in internal book-keeping units (18 decimals)
    /// @return Amount in underlying units, (same decimals as underlying token)
    function convertBalanceToUnderlying(uint balance) external view returns (uint);

    /// @notice Convert an underlying amount to an mToken balance, taking into account current exchange rate
    /// @param underlyingAmount Amount in underlying units (same decimals as underlying token)
    /// @return mToken balance, in internal book-keeping units (18 decimals)
    function convertUnderlyingToBalance(uint underlyingAmount) external view returns (uint);

    /// @notice Updates interest accumulator and totalBorrows, credits reserves, re-targets interest rate, and logs asset status
    function touch() external;

    /// @notice Transfer underlying tokens from sender to the Mirai pool, and increase account's mTokens
    /// @param subAccountId 0 for primary, 1-255 for a sub-account
    /// @param amount In underlying units (use max uint256 for full underlying token balance)
    function deposit(uint subAccountId, uint amount) external;

    /// @notice Transfer underlying tokens from Mirai pool to sender, and decrease account's mTokens
    /// @param subAccountId 0 for primary, 1-255 for a sub-account
    /// @param amount In underlying units (use max uint256 for full pool balance)
    function withdraw(uint subAccountId, uint amount) external;

    /// @notice Mint mTokens and a corresponding amount of dTokens ("self-borrow")
    /// @param subAccountId 0 for primary, 1-255 for a sub-account
    /// @param amount In underlying units
    function mint(uint subAccountId, uint amount) external;

    /// @notice Pay off dToken liability with mTokens ("self-repay")
    /// @param subAccountId 0 for primary, 1-255 for a sub-account
    /// @param amount In underlying units (use max uint256 to repay the debt in full or up to the available underlying balance)
    function burn(uint subAccountId, uint amount) external;

    /// @notice Allow spender to access an amount of your mTokens in sub-account 0
    /// @param spender Trusted address
    /// @param amount Use max uint256 for "infinite" allowance
    function approve(address spender, uint amount) external returns (bool);

    /// @notice Allow spender to access an amount of your mTokens in a particular sub-account
    /// @param subAccountId 0 for primary, 1-255 for a sub-account
    /// @param spender Trusted address
    /// @param amount Use max uint256 for "infinite" allowance
    function approveSubAccount(uint subAccountId, address spender, uint amount) external returns (bool);

    /// @notice Retrieve the current allowance
    /// @param holder Xor with the desired sub-account ID (if applicable)
    /// @param spender Trusted address
    function allowance(address holder, address spender) external view returns (uint);

    /// @notice Transfer mTokens to another address (from sub-account 0)
    /// @param to Xor with the desired sub-account ID (if applicable)
    /// @param amount In internal book-keeping units (as returned from balanceOf).
    function transfer(address to, uint amount) external returns (bool);

    /// @notice Transfer the full mToken balance of an address to another
    /// @param from This address must've approved the to address, or be a sub-account of msg.sender
    /// @param to Xor with the desired sub-account ID (if applicable)
    function transferFromMax(address from, address to) external returns (bool);

    /// @notice Transfer mTokens from one address to another
    /// @param from This address must've approved the to address, or be a sub-account of msg.sender
    /// @param to Xor with the desired sub-account ID (if applicable)
    /// @param amount In internal book-keeping units (as returned from balanceOf).
    function transferFrom(address from, address to, uint amount) external returns (bool);
}


/// @notice Definition of callback method that flashLoan will invoke on your contract
interface IFlashLoan {
    function onFlashLoan(bytes memory data) external;
}

/// @notice Tokenised representation of debts
interface IMiraiDToken {
    /// @notice Debt token name, ie "Mirai Debt: DAI"
    function name() external view returns (string memory);

    /// @notice Debt token symbol, ie "dDAI"
    function symbol() external view returns (string memory);

    /// @notice Decimals of underlying
    function decimals() external view returns (uint8);

    /// @notice Address of underlying asset
    function underlyingAsset() external view returns (address);

    /// @notice Sum of all outstanding debts, in underlying units (increases as interest is accrued)
    function totalSupply() external view returns (uint);

    /// @notice Sum of all outstanding debts, in underlying units normalized to 27 decimals (increases as interest is accrued)
    function totalSupplyExact() external view returns (uint);

    /// @notice Debt owed by a particular account, in underlying units
    function balanceOf(address account) external view returns (uint);

    /// @notice Debt owed by a particular account, in underlying units normalized to 27 decimals
    function balanceOfExact(address account) external view returns (uint);

    /// @notice Transfer underlying tokens from the Mirai pool to the sender, and increase sender's dTokens
    /// @param subAccountId 0 for primary, 1-255 for a sub-account
    /// @param amount In underlying units (use max uint256 for all available tokens)
    function borrow(uint subAccountId, uint amount) external;

    /// @notice Transfer underlying tokens from the sender to the Mirai pool, and decrease sender's dTokens
    /// @param subAccountId 0 for primary, 1-255 for a sub-account
    /// @param amount In underlying units (use max uint256 for full debt owed)
    function repay(uint subAccountId, uint amount) external;

    /// @notice Request a flash-loan. A onFlashLoan() callback in msg.sender will be invoked, which must repay the loan to the main Mirai address prior to returning.
    /// @param amount In underlying units
    /// @param data Passed through to the onFlashLoan() callback, so contracts don't need to store transient data in storage
    function flashLoan(uint amount, bytes calldata data) external;

    /// @notice Allow spender to send an amount of dTokens to a particular sub-account
    /// @param subAccountId 0 for primary, 1-255 for a sub-account
    /// @param spender Trusted address
    /// @param amount In underlying units (use max uint256 for "infinite" allowance)
    function approveDebt(uint subAccountId, address spender, uint amount) external returns (bool);

    /// @notice Retrieve the current debt allowance
    /// @param holder Xor with the desired sub-account ID (if applicable)
    /// @param spender Trusted address
    function debtAllowance(address holder, address spender) external view returns (uint);

    /// @notice Transfer dTokens to another address (from sub-account 0)
    /// @param to Xor with the desired sub-account ID (if applicable)
    /// @param amount In underlying units. Use max uint256 for full balance.
    function transfer(address to, uint amount) external returns (bool);

    /// @notice Transfer dTokens from one address to another
    /// @param from Xor with the desired sub-account ID (if applicable)
    /// @param to This address must've approved the from address, or be a sub-account of msg.sender
    /// @param amount In underlying units. Use max uint256 for full balance.
    function transferFrom(address from, address to, uint amount) external returns (bool);
}


/// @notice Liquidate users who are in collateral violation to protect lenders
interface IMiraiLiquidation {
      /// @notice struct to save information on a potential liquidation opportunity
    struct LiquidationChance {
        uint256 repayAmount;
        uint256 yieldAmount;
        uint256 healthFactor;
        // Below fields are only updated if repayAmount > 0 i.e. there is a liquidation chance
        uint256 baseDiscount;
        uint256 discount;
        uint256 conversionRate;
    }

    /// @notice Checks to see if a liquidation would be profitable, without actually doing anything
    /// @param liquidator Address that will initiate the liquidation
    /// @param violator Address that may be in collateral violation
    /// @param underlying Token that is to be repayed
    /// @param collateral Token that is to be seized
    /// @return liqChance The details about the liquidation opportunity
    function checkLiquidation(address liquidator, address violator, address underlying, address collateral) external returns (LiquidationChance memory liqChance) ;


    /// @notice Attempts to perform a liquidation
    /// @param _violator Address that may be in violation and with low health factor
    /// @param _underlying Asset that is to be repayed
    /// @param _collateral Asset that is to be seized
    /// @param _repayAmount The amount of underlying DTokens to be sent from violator to sender, in units of underlying
    /// @param _minYieldAmount The min acceptable amount of collateral MTokens to be sent from violator to sender, in units of collateral
    function liquidate(
        address _violator,
        address _underlying,
        address _collateral,
        uint256 _repayAmount,
        uint256 _minYieldAmount
    ) external;
}


/// @notice Trading assets on Uniswap V3 and 1Inch V4 DEXs
interface IMiraiSwap {
    /// @notice Params for Uniswap V3 exact input trade on a single pool
    /// @param subAccountIdIn subaccount id to trade from
    /// @param subAccountIdOut subaccount id to trade to
    /// @param underlyingIn sold token address
    /// @param underlyingOut bought token address
    /// @param amountIn amount of token to sell
    /// @param amountOutMinimum minimum amount of bought token
    /// @param deadline trade must complete before this timestamp
    /// @param fee uniswap pool fee to use
    /// @param sqrtPriceLimitX96 maximum acceptable price
    struct SwapUniExactInputSingleParams {
        uint subAccountIdIn;
        uint subAccountIdOut;
        address underlyingIn;
        address underlyingOut;
        uint amountIn;
        uint amountOutMinimum;
        uint deadline;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Params for Uniswap V3 exact input trade routed through multiple pools
    /// @param subAccountIdIn subaccount id to trade from
    /// @param subAccountIdOut subaccount id to trade to
    /// @param underlyingIn sold token address
    /// @param underlyingOut bought token address
    /// @param amountIn amount of token to sell
    /// @param amountOutMinimum minimum amount of bought token
    /// @param deadline trade must complete before this timestamp
    /// @param path list of pools to use for the trade
    struct SwapUniExactInputParams {
        uint subAccountIdIn;
        uint subAccountIdOut;
        uint amountIn;
        uint amountOutMinimum;
        uint deadline;
        bytes path; // list of pools to hop - constructed with uni SDK 
    }

    /// @notice Params for Uniswap V3 exact output trade on a single pool
    /// @param subAccountIdIn subaccount id to trade from
    /// @param subAccountIdOut subaccount id to trade to
    /// @param underlyingIn sold token address
    /// @param underlyingOut bought token address
    /// @param amountOut amount of token to buy
    /// @param amountInMaximum maximum amount of sold token
    /// @param deadline trade must complete before this timestamp
    /// @param fee uniswap pool fee to use
    /// @param sqrtPriceLimitX96 maximum acceptable price
    struct SwapUniExactOutputSingleParams {
        uint subAccountIdIn;
        uint subAccountIdOut;
        address underlyingIn;
        address underlyingOut;
        uint amountOut;
        uint amountInMaximum;
        uint deadline;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Params for Uniswap V3 exact output trade routed through multiple pools
    /// @param subAccountIdIn subaccount id to trade from
    /// @param subAccountIdOut subaccount id to trade to
    /// @param underlyingIn sold token address
    /// @param underlyingOut bought token address
    /// @param amountOut amount of token to buy
    /// @param amountInMaximum maximum amount of sold token
    /// @param deadline trade must complete before this timestamp
    /// @param path list of pools to use for the trade
    struct SwapUniExactOutputParams {
        uint subAccountIdIn;
        uint subAccountIdOut;
        uint amountOut;
        uint amountInMaximum;
        uint deadline;
        bytes path;
    }

    /// @notice Params for 1Inch trade
    /// @param subAccountIdIn subaccount id to trade from
    /// @param subAccountIdOut subaccount id to trade to
    /// @param underlyingIn sold token address
    /// @param underlyingOut bought token address
    /// @param amount amount of token to sell
    /// @param amountOutMinimum minimum amount of bought token
    /// @param payload call data passed to 1Inch contract
    struct Swap1InchParams {
        uint subAccountIdIn;
        uint subAccountIdOut;
        address underlyingIn;
        address underlyingOut;
        uint amount;
        uint amountOutMinimum;
        bytes payload;
    }

    /// @notice Execute Uniswap V3 exact input trade on a single pool
    /// @param params struct defining trade parameters
    function swapUniExactInputSingle(SwapUniExactInputSingleParams memory params) external;

    /// @notice Execute Uniswap V3 exact input trade routed through multiple pools
    /// @param params struct defining trade parameters
    function swapUniExactInput(SwapUniExactInputParams memory params) external;

    /// @notice Execute Uniswap V3 exact output trade on a single pool
    /// @param params struct defining trade parameters
    function swapUniExactOutputSingle(SwapUniExactOutputSingleParams memory params) external;

    /// @notice Execute Uniswap V3 exact output trade routed through multiple pools
    /// @param params struct defining trade parameters
    function swapUniExactOutput(SwapUniExactOutputParams memory params) external;

    /// @notice Trade on Uniswap V3 single pool and repay debt with bought asset
    /// @param params struct defining trade parameters (amountOut is ignored)
    /// @param targetDebt amount of debt that is expected to remain after trade and repay (0 to repay full debt)
    function swapAndRepayUniSingle(SwapUniExactOutputSingleParams memory params, uint targetDebt) external;

    /// @notice Trade on Uniswap V3 through multiple pools pool and repay debt with bought asset
    /// @param params struct defining trade parameters (amountOut is ignored)
    /// @param targetDebt amount of debt that is expected to remain after trade and repay (0 to repay full debt)
    function swapAndRepayUni(SwapUniExactOutputParams memory params, uint targetDebt) external;

    /// @notice Execute 1Inch V4 trade
    /// @param params struct defining trade parameters
    function swap1Inch(Swap1InchParams memory params) external;
}


/// @notice Common logic for executing and processing trades through external swap handler contracts
interface IMiraiSwapHub {
    /// @notice Params defining a swap request
    struct SwapParams {
        address underlyingIn;
        address underlyingOut;
        uint mode;
        uint amountIn;
        uint amountOut;
        uint exactOutTolerance;
        bytes payload;
    }

    /// @notice Execute a trade using the requested swap handler
    /// @param subAccountIdIn sub-account holding the sold token. 0 for primary, 1-255 for a sub-account
    /// @param subAccountIdOut sub-account to receive the bought token. 0 for primary, 1-255 for a sub-account
    /// @param swapHandler address of a swap handler to use
    /// @param params struct defining the requested trade
    function swap(uint subAccountIdIn, uint subAccountIdOut, address swapHandler, SwapParams memory params) external;

    /// @notice Repay debt by selling another deposited token
    /// @param subAccountIdIn sub-account holding the sold token. 0 for primary, 1-255 for a sub-account
    /// @param subAccountIdOut sub-account to receive the bought token. 0 for primary, 1-255 for a sub-account
    /// @param swapHandler address of a swap handler to use
    /// @param params struct defining the requested trade
    /// @param targetDebt how much debt should remain after calling the function
    function swapAndRepay(uint subAccountIdIn, uint subAccountIdOut, address swapHandler, SwapParams memory params, uint targetDebt) external;
}


/// @notice Protected Tokens are simple wrappers for tokens, allowing you to use tokens as collateral without permitting borrowing
interface IMiraiPToken {
    /// @notice PToken name, ie "Mirai Protected DAI"
    function name() external view returns (string memory);

    /// @notice PToken symbol, ie "pDAI"
    function symbol() external view returns (string memory);

    /// @notice Number of decimals, which is same as the underlying's
    function decimals() external view returns (uint8);

    /// @notice Address of the underlying asset
    function underlying() external view returns (address);

    /// @notice Balance of an account's wrapped tokens
    function balanceOf(address who) external view returns (uint);

    /// @notice Sum of all wrapped token balances
    function totalSupply() external view returns (uint);

    /// @notice Retrieve the current allowance
    /// @param holder Address giving permission to access tokens
    /// @param spender Trusted address
    function allowance(address holder, address spender) external view returns (uint);

    /// @notice Transfer your own pTokens to another address
    /// @param recipient Recipient address
    /// @param amount Amount of wrapped token to transfer
    function transfer(address recipient, uint amount) external returns (bool);

    /// @notice Transfer pTokens from one address to another. The mirai address is automatically granted approval.
    /// @param from This address must've approved the to address
    /// @param recipient Recipient address
    /// @param amount Amount to transfer
    function transferFrom(address from, address recipient, uint amount) external returns (bool);

    /// @notice Allow spender to access an amount of your pTokens. It is not necessary to approve the mirai address.
    /// @param spender Trusted address
    /// @param amount Use max uint256 for "infinite" allowance
    function approve(address spender, uint amount) external returns (bool);

    /// @notice Convert underlying tokens to pTokens
    /// @param amount In underlying units (which are equivalent to pToken units)
    function wrap(uint amount) external;

    /// @notice Convert pTokens to underlying tokens
    /// @param amount In pToken units (which are equivalent to underlying units)
    function unwrap(uint amount) external;

    /// @notice Claim any surplus tokens held by the PToken contract. This should only be used by contracts.
    /// @param who Beneficiary to be credited for the surplus token amount
    function claimSurplus(address who) external;
}


library MiraiAddrsMainnet {
    IMirai public constant mirai = IMirai(0x27182842E098f60e3D576794A5bFFb0777E025d3);
    IMiraiMarkets public constant markets = IMiraiMarkets(0x3520d5a913427E6F0D6A83E07ccD4A4da316e4d3);
    IMiraiLiquidation public constant liquidation = IMiraiLiquidation(0xf43ce1d09050BAfd6980dD43Cde2aB9F18C85b34);
    IMiraiExec public constant exec = IMiraiExec(0x59828FdF7ee634AaaD3f58B19fDBa3b03E2D9d80);
    IMiraiSwap public constant swap = IMiraiSwap(0x7123C8cBBD76c5C7fCC9f7150f23179bec0bA341);
}

library MiraiAddrsGoerli {
    IMirai public constant mirai = IMirai(0x931172BB95549d0f29e10ae2D079ABA3C63318B3);
    IMiraiMarkets public constant markets = IMiraiMarkets(0x3EbC39b84B1F856fAFE9803A9e1Eae7Da016Da36);
    IMiraiLiquidation public constant liquidation = IMiraiLiquidation(0x66326c072283feE63E1C3feF9BD024F8697EC1BB);
    IMiraiExec public constant exec = IMiraiExec(0x4b62EB6797526491eEf6eF36D3B9960E5d66C394);
    // swap module not available on Goerli
}
