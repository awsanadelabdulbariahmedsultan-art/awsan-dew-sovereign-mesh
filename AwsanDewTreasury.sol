// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title AwsanDewTreasury
 * @notice Enterprise Omnichain Sovereign Treasury, LayerZero v2 Cross-Chain Settlement,
 *         and Asset/Voucher Tokenization Engine for Awsan Dew Protocol & Ecosystem.
 * 
 * ==============================================================================
 * Creator & Sole Legal Owner: Eng. Awsan Adel Abdulbari Ahmed Sultan
 * Republic of Yemen | National ID: 01010305468 | Phone: +967 777 852 433
 * Official Royalty Vault: 0x22848f7963Ea954771120d842BD658f12D4Abb43
 * Supported Networks: Avalanche C-Chain, BNB Smart Chain, Ethereum, Polygon,
 *                     Arbitrum One, Optimism, Base, and LayerZero OFTv2 Mesh.
 * Policy: UNCAPPED_BLOCKCHAIN_LIQUIDITY (سقوف مالية مفتوحة بلا حدود قصوى للمعاملات)
 * ==============================================================================
 */

// --- Interfaces ---

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/// @notice LayerZero v2 Messaging Structures
struct MessagingParams {
    uint32 dstEid;
    bytes32 receiver;
    bytes message;
    bytes options;
    bool payInLzToken;
}

struct MessagingReceipt {
    bytes32 guid;
    uint64 nonce;
    MessagingFee fee;
}

struct MessagingFee {
    uint256 nativeFee;
    uint256 lzTokenFee;
}

struct Origin {
    uint32 srcEid;
    bytes32 sender;
    uint64 nonce;
}

interface ILayerZeroEndpointV2 {
    function send(
        MessagingParams calldata _params,
        address _refundAddress
    ) external payable returns (MessagingReceipt memory receipt);

    function quote(
        MessagingParams calldata _params,
        address _sender
    ) external view returns (MessagingFee memory fee);
}

// --- Base Security Contracts ---

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        require(initialOwner != address(0), "Ownable: new owner is zero address");
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private uintStatus;

    constructor() {
        uintStatus = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(uintStatus != _ENTERED, "ReentrancyGuard: reentrant call");
        uintStatus = _ENTERED;
        _;
        uintStatus = _NOT_ENTERED;
    }
}

// --- Main Omnichain Treasury & Tokenization Contract ---

contract AwsanDewTreasury is Ownable, ReentrancyGuard {

    // --- Official Creator, Vault & Identity Parameters ---
    address public constant OFFICIAL_VAULT = 0x22848f7963Ea954771120d842BD658f12D4Abb43;
    string public constant CREATOR_NAME = "Eng. Awsan Adel Abdulbari Ahmed Sultan";
    string public constant CREATOR_NATIONAL_ID = "01010305468";
    string public constant CREATOR_COUNTRY = "Republic of Yemen";
    address public royaltyReceiver;

    // --- Protocol Fee Schedule (1.5% Total) ---
    uint256 public constant BASIS_POINTS_DIVISOR = 10000;
    uint256 public constant CREATOR_ROYALTY_BPS = 100; // 1.0% Hard-coded Creator Royalty
    uint256 public constant INVESTOR_YIELD_BPS = 30;   // 0.3% Liquidity Providers / Investors
    uint256 public constant CLEARING_FEE_BPS = 20;     // 0.2% Clearing Switch Fee
    uint256 public constant TOTAL_FEE_BPS = 150;       // 1.5% Gross Total Fee
    uint256 public constant PARTNER_NET_BPS = 9850;    // 98.5% Net Payout to Partner

    // --- Liquidity Policy ---
    string public constant LIQUIDITY_POLICY = "UNCAPPED_BLOCKCHAIN_LIQUIDITY";
    bool public constant CEILINGS_ENFORCED = false;

    // --- LayerZero v2 Cross-Chain Settings ---
    ILayerZeroEndpointV2 public lzEndpoint;
    mapping(uint32 => bytes32) public trustedRemotePeers; // dstEid => remote treasury address

    // --- Tokenization Engine: Structures ---

    /// @notice State of an on-chain tokenized voucher or asset
    enum VoucherState { ACTIVE, REDEEMED, CANCELLED }

    /// @notice Tokenized Purchase Voucher / Gift Code Representation
    struct TokenizedVoucher {
        bytes32 voucherId;       // Unique on-chain token identifier
        bytes32 commitmentHash;  // keccak256(code, pin, salt)
        address token;           // address(0) for Native, or ERC20 (USDT, ADT, etc.)
        uint256 faceValue;       // Value locked on-chain
        uint256 createdAt;       // Issuance timestamp
        uint256 expiresAt;       // Expiry timestamp (24h default)
        VoucherState state;      // Current lifecycle state
        address issuer;          // Entity that locked the liquidity
        string currencyCode;     // "YER_SAN", "YER_ADE", "SAR", "USD", etc.
    }

    /// @notice Tokenized Settlement Receipt (ISO 20022 pacs.008 Compliance)
        /// @notice Real Estate Property Tokenization & Fractional Multi-Ownership
    struct TokenizedProperty {
        bytes32 propertyId;
        string propertyTitle;
        string location;
        uint256 totalValuationUsd;
        uint256 totalTokens;
        uint256 tokenPrice;
        uint256 tokensSold;
        uint256 rentalYieldBps; // e.g. 1250 = 12.5% APY
        address propertyManager;
        bool isActive;
    }

    mapping(bytes32 => TokenizedProperty) public properties;
    mapping(bytes32 => mapping(address => uint256)) public propertyHoldings; // propertyId => investor => tokenCount

    event PropertyTokenized(bytes32 indexed propertyId, string title, uint256 totalValuationUsd, uint256 totalTokens, uint256 tokenPrice);
    event PropertyTokensPurchased(bytes32 indexed propertyId, address indexed buyer, uint256 tokenCount, uint256 totalPaid, uint256 royaltyDeducted);

    struct SettlementReceipt {
        bytes32 orderId;
        address payer;
        address partnerRecipient;
        address token;
        uint256 grossAmount;
        uint256 royaltyAmount;
        uint256 netAmount;
        uint256 timestamp;
        uint256 chainId;
    }

    // Storage Mappings
    mapping(bytes32 => TokenizedVoucher) public vouchers;
    mapping(bytes32 => SettlementReceipt) public settlementReceipts;
    mapping(bytes32 => bool) public processedOrderIds;
    
    // Total Volume Counters across life of contract
    uint256 public totalSettledVolumeUsdEquivalent;
    uint256 public totalRoyaltiesRouted;

    // --- Events ---

    event PaymentSettled(
        bytes32 indexed orderId,
        address indexed token,
        address indexed payer,
        address partnerRecipient,
        uint256 grossAmount,
        uint256 creatorRoyalty,
        uint256 investorYield,
        uint256 clearingFee,
        uint256 netPartnerAmount,
        uint256 chainId
    );

    event VoucherTokenized(
        bytes32 indexed voucherId,
        bytes32 commitmentHash,
        address indexed issuer,
        address token,
        uint256 faceValue,
        string currencyCode,
        uint256 expiresAt
    );

    event VoucherRedeemed(
        bytes32 indexed voucherId,
        address indexed recipient,
        uint256 grossAmount,
        uint256 netPaidOut,
        uint256 creatorRoyalty
    );

    event OmnichainMessageDispatched(
        bytes32 indexed guid,
        uint32 indexed dstEid,
        bytes32 receiver,
        bytes message,
        uint256 nativeFeePaid
    );

    event OmnichainMessageReceived(
        uint32 indexed srcEid,
        bytes32 indexed sender,
        bytes32 guid,
        bytes message
    );

    event RoyaltyReceiverUpdated(address indexed previousReceiver, address indexed newReceiver);
    event LayerZeroEndpointUpdated(address indexed previousEndpoint, address indexed newEndpoint);
    event EmergencyFundsWithdrawn(address indexed token, address indexed to, uint256 amount);

    // --- Constructor ---

    constructor(address _lzEndpoint) Ownable(OFFICIAL_VAULT) {
        royaltyReceiver = OFFICIAL_VAULT;
        if (_lzEndpoint != address(0)) {
            lzEndpoint = ILayerZeroEndpointV2(_lzEndpoint);
        }
    }

    receive() external payable {
        // Automatically route 1.0% royalty for direct native coin deposits
        if (msg.value > 0) {
            uint256 royalty = (msg.value * CREATOR_ROYALTY_BPS) / BASIS_POINTS_DIVISOR;
            if (royalty > 0) {
                (bool sent, ) = royaltyReceiver.call{value: royalty}("");
                require(sent, "Royalty transfer failed");
                totalRoyaltiesRouted += royalty;
            }
        }
    }

    // --- Multi-Chain Discovery Helpers ---

    /// @notice Returns current chain ID
    function getChainId() public view returns (uint256) {
        return block.chainid;
    }

    /// @notice Returns network name based on chain ID
    function getNetworkName() public view returns (string memory) {
        uint256 id = block.chainid;
        if (id == 43114) return "Avalanche C-Chain";
        if (id == 56) return "BNB Smart Chain (BSC)";
        if (id == 1) return "Ethereum Mainnet";
        if (id == 137) return "Polygon PoS";
        if (id == 42161) return "Arbitrum One";
        if (id == 10) return "Optimism";
        if (id == 8453) return "Base Network";
        if (id == 11155111) return "Sepolia Testnet";
        if (id == 43113) return "Avalanche Fuji Testnet";
        if (id == 97) return "BSC Testnet";
        return "Universal EVM Chain";
    }

    // --- Core Settlement Functions (Uncapped Liquidity) ---

    /**
     * @notice Settles ERC20 Token Payments with Uncapped Liquidity and Transparent Fee Splitting
     * @param token Address of the ERC20 token (e.g. USDT, ADT, USDC)
     * @param grossAmount Total payment amount in token units (no artificial maximum limits)
     * @param orderId Unique reference identifier for the transaction/order
     * @param partnerRecipient Beneficiary partner/merchant address receiving the 98.5% net amount
     */
    function settleTokenPayment(
        address token,
        uint256 grossAmount,
        bytes32 orderId,
        address partnerRecipient
    ) external nonReentrant returns (bool) {
        require(grossAmount > 0, "Amount must be greater than zero");
        require(partnerRecipient != address(0), "Partner address cannot be zero");
        require(!processedOrderIds[orderId], "Transaction orderId already processed");

        IERC20 tokenContract = IERC20(token);
        
        // Transfer gross amount from payer to contract
        require(
            tokenContract.transferFrom(msg.sender, address(this), grossAmount),
            "Token transferFrom failed"
        );

        // Calculate fee splits
        uint256 creatorRoyalty = (grossAmount * CREATOR_ROYALTY_BPS) / BASIS_POINTS_DIVISOR;
        uint256 investorYield = (grossAmount * INVESTOR_YIELD_BPS) / BASIS_POINTS_DIVISOR;
        uint256 clearingFee = (grossAmount * CLEARING_FEE_BPS) / BASIS_POINTS_DIVISOR;
        uint256 netPartnerAmount = grossAmount - creatorRoyalty - investorYield - clearingFee;

        // Route Creator Royalty (1.0%) to Official Vault
        if (creatorRoyalty > 0) {
            require(tokenContract.transfer(royaltyReceiver, creatorRoyalty), "Royalty transfer failed");
            totalRoyaltiesRouted += creatorRoyalty;
        }

        // Route Net Amount (98.5%) to Partner
        require(tokenContract.transfer(partnerRecipient, netPartnerAmount), "Partner transfer failed");

        processedOrderIds[orderId] = true;

        // Tokenize Settlement Receipt
        settlementReceipts[orderId] = SettlementReceipt({
            orderId: orderId,
            payer: msg.sender,
            partnerRecipient: partnerRecipient,
            token: token,
            grossAmount: grossAmount,
            royaltyAmount: creatorRoyalty,
            netAmount: netPartnerAmount,
            timestamp: block.timestamp,
            chainId: block.chainid
        });

        emit PaymentSettled(
            orderId,
            token,
            msg.sender,
            partnerRecipient,
            grossAmount,
            creatorRoyalty,
            investorYield,
            clearingFee,
            netPartnerAmount,
            block.chainid
        );

        return true;
    }

    /**
     * @notice Settles Native Coin Payments (AVAX, BNB, ETH) with Uncapped Liquidity
     * @param orderId Unique reference identifier for the transaction/order
     * @param partnerRecipient Beneficiary partner/merchant address receiving the 98.5% net amount
     */
    function settleNativePayment(
        bytes32 orderId,
        address partnerRecipient
    ) external payable nonReentrant returns (bool) {
        uint256 grossAmount = msg.value;
        require(grossAmount > 0, "Native amount must be greater than zero");
        require(partnerRecipient != address(0), "Partner address cannot be zero");
        require(!processedOrderIds[orderId], "Transaction orderId already processed");

        // Calculate fee splits
        uint256 creatorRoyalty = (grossAmount * CREATOR_ROYALTY_BPS) / BASIS_POINTS_DIVISOR;
        uint256 investorYield = (grossAmount * INVESTOR_YIELD_BPS) / BASIS_POINTS_DIVISOR;
        uint256 clearingFee = (grossAmount * CLEARING_FEE_BPS) / BASIS_POINTS_DIVISOR;
        uint256 netPartnerAmount = grossAmount - creatorRoyalty - investorYield - clearingFee;

        // Route Creator Royalty (1.0%) to Official Vault
        if (creatorRoyalty > 0) {
            (bool sentVault, ) = royaltyReceiver.call{value: creatorRoyalty}("");
            require(sentVault, "Native royalty transfer failed");
            totalRoyaltiesRouted += creatorRoyalty;
        }

        // Route Net Amount (98.5%) to Partner
        (bool sentPartner, ) = partnerRecipient.call{value: netPartnerAmount}("");
        require(sentPartner, "Native partner transfer failed");

        processedOrderIds[orderId] = true;

        // Tokenize Settlement Receipt
        settlementReceipts[orderId] = SettlementReceipt({
            orderId: orderId,
            payer: msg.sender,
            partnerRecipient: partnerRecipient,
            token: address(0),
            grossAmount: grossAmount,
            royaltyAmount: creatorRoyalty,
            netAmount: netPartnerAmount,
            timestamp: block.timestamp,
            chainId: block.chainid
        });

        emit PaymentSettled(
            orderId,
            address(0),
            msg.sender,
            partnerRecipient,
            grossAmount,
            creatorRoyalty,
            investorYield,
            clearingFee,
            netPartnerAmount,
            block.chainid
        );

        return true;
    }

    // --- Tokenization Engine: Purchase Vouchers & Gift Codes ---

    /**
     * @notice Tokenizes and locks funds on-chain for an instant Purchase Voucher
     * @param voucherId Unique identifier of the voucher (e.g. hash of code string)
     * @param commitmentHash keccak256(code, pin, salt) to ensure non-forgeability
     * @param token Address of ERC20 token or address(0) for Native
     * @param faceValue Total monetary value of the voucher
     * @param currencyCode Currency representation (e.g. "YER_SAN", "YER_ADE", "SAR", "USD")
     */
    function tokenizePurchaseVoucher(
        bytes32 voucherId,
        bytes32 commitmentHash,
        address token,
        uint256 faceValue,
        string calldata currencyCode
    ) external payable nonReentrant returns (bool) {
        require(vouchers[voucherId].faceValue == 0, "Voucher already tokenized");
        require(faceValue > 0, "Face value must be positive");

        if (token == address(0)) {
            require(msg.value == faceValue, "Incorrect native currency sent");
        } else {
            require(msg.value == 0, "Do not send native coins for token voucher");
            require(
                IERC20(token).transferFrom(msg.sender, address(this), faceValue),
                "Token deposit failed"
            );
        }

        uint256 expiresAt = block.timestamp + 1 days; // 24 Hours default validity

        vouchers[voucherId] = TokenizedVoucher({
            voucherId: voucherId,
            commitmentHash: commitmentHash,
            token: token,
            faceValue: faceValue,
            createdAt: block.timestamp,
            expiresAt: expiresAt,
            state: VoucherState.ACTIVE,
            issuer: msg.sender,
            currencyCode: currencyCode
        });

        emit VoucherTokenized(voucherId, commitmentHash, msg.sender, token, faceValue, currencyCode, expiresAt);
        return true;
    }

    /**
     * @notice Redeems a tokenized purchase voucher, transferring funds to the recipient with 1.0% royalty routing
     * @param voucherId The voucher identifier
     * @param plainCode Plain text voucher code
     * @param plainPin Secret PIN of the voucher
     * @param salt Salt used during commitment
     * @param recipient Address to receive the redeemed liquidity
     */
    function redeemTokenizedVoucher(
        bytes32 voucherId,
        string calldata plainCode,
        string calldata plainPin,
        bytes32 salt,
        address recipient
    ) external nonReentrant returns (bool) {
        require(recipient != address(0), "Recipient cannot be zero address");

        TokenizedVoucher storage v = vouchers[voucherId];
        require(v.faceValue > 0, "Voucher does not exist");
        require(v.state == VoucherState.ACTIVE, "Voucher is not active or already redeemed");
        require(block.timestamp <= v.expiresAt, "Voucher has expired");

        // Verify cryptographic commitment
        bytes32 computedHash = keccak256(abi.encodePacked(plainCode, plainPin, salt));
        require(computedHash == v.commitmentHash, "Invalid voucher code or PIN");

        v.state = VoucherState.REDEEMED;
        uint256 grossAmount = v.faceValue;

        // Deduct 1.0% Creator Royalty
        uint256 creatorRoyalty = (grossAmount * CREATOR_ROYALTY_BPS) / BASIS_POINTS_DIVISOR;
        uint256 netPaidOut = grossAmount - creatorRoyalty;

        if (v.token == address(0)) {
            // Native Settlement
            if (creatorRoyalty > 0) {
                (bool sentRoyalty, ) = royaltyReceiver.call{value: creatorRoyalty}("");
                require(sentRoyalty, "Royalty transfer failed");
                totalRoyaltiesRouted += creatorRoyalty;
            }
            (bool sentRecipient, ) = recipient.call{value: netPaidOut}("");
            require(sentRecipient, "Recipient transfer failed");
        } else {
            // ERC20 Settlement
            IERC20 tokenContract = IERC20(v.token);
            if (creatorRoyalty > 0) {
                require(tokenContract.transfer(royaltyReceiver, creatorRoyalty), "Royalty transfer failed");
                totalRoyaltiesRouted += creatorRoyalty;
            }
            require(tokenContract.transfer(recipient, netPaidOut), "Recipient transfer failed");
        }

        emit VoucherRedeemed(voucherId, recipient, grossAmount, netPaidOut, creatorRoyalty);
        return true;
    }

    // --- LayerZero v2 Omnichain Cross-Chain Routing ---

    /**
     * @notice Dispatches an Omnichain Settlement Message via LayerZero v2
     * @param dstEid Destination LayerZero Endpoint ID (e.g. 30102 for BSC, 30101 for Ethereum)
     * @param orderId Unique reference of the cross-chain settlement
     * @param payload Encoded cross-chain instructions
     * @param options Additional LayerZero adapter options
     */
    function dispatchOmnichainSettlement(
        uint32 dstEid,
        bytes32 orderId,
        bytes calldata payload,
        bytes calldata options
    ) external payable nonReentrant returns (bytes32 guid) {
        require(address(lzEndpoint) != address(0), "LayerZero Endpoint not configured");
        bytes32 peer = trustedRemotePeers[dstEid];
        require(peer != bytes32(0), "Destination peer not trusted");

        MessagingParams memory params = MessagingParams({
            dstEid: dstEid,
            receiver: peer,
            message: payload,
            options: options,
            payInLzToken: false
        });

        MessagingReceipt memory receipt = lzEndpoint.send{value: msg.value}(params, msg.sender);
        
        emit OmnichainMessageDispatched(receipt.guid, dstEid, peer, payload, msg.value);
        return receipt.guid;
    }

    /**
     * @notice LayerZero v2 Receiver entry point
     */
    function lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address /* _executor */,
        bytes calldata /* _extraData */
    ) external payable {
        require(msg.sender == address(lzEndpoint), "Caller must be LayerZero Endpoint");
        require(trustedRemotePeers[_origin.srcEid] == _origin.sender, "Untrusted peer sender");

        emit OmnichainMessageReceived(_origin.srcEid, _origin.sender, _guid, _message);
    }

    // --- Real Estate Tokenization & Fractional Multi-Owner Functions ---

    /**
     * @notice Tokenizes a real estate property on-chain into fractional investment tokens
     */
    function tokenizeProperty(
        bytes32 propertyId,
        string calldata title,
        string calldata location,
        uint256 valuationUsd,
        uint256 totalTokens,
        uint256 tokenPrice,
        uint256 rentalYieldBps
    ) external onlyOwner returns (bool) {
        require(properties[propertyId].totalTokens == 0, "Property already tokenized");
        require(totalTokens > 0 && tokenPrice > 0, "Invalid token params");

        properties[propertyId] = TokenizedProperty({
            propertyId: propertyId,
            propertyTitle: title,
            location: location,
            totalValuationUsd: valuationUsd,
            totalTokens: totalTokens,
            tokenPrice: tokenPrice,
            tokensSold: 0,
            rentalYieldBps: rentalYieldBps,
            propertyManager: msg.sender,
            isActive: true
        });

        emit PropertyTokenized(propertyId, title, valuationUsd, totalTokens, tokenPrice);
        return true;
    }

    /**
     * @notice Allows multiple investors to purchase fractional tokens of a property
     */
    function buyFractionalPropertyTokens(
        bytes32 propertyId,
        uint256 tokenCount,
        address paymentToken
    ) external payable nonReentrant returns (bool) {
        TokenizedProperty storage prop = properties[propertyId];
        require(prop.isActive, "Property is not active");
        require(prop.tokensSold + tokenCount <= prop.totalTokens, "Insufficient available tokens");

        uint256 totalCost = tokenCount * prop.tokenPrice;
        uint256 creatorRoyalty = (totalCost * CREATOR_ROYALTY_BPS) / BASIS_POINTS_DIVISOR;

        if (paymentToken == address(0)) {
            require(msg.value >= totalCost, "Insufficient native funds");
            if (creatorRoyalty > 0) {
                (bool sentVault, ) = royaltyReceiver.call{value: creatorRoyalty}("");
                require(sentVault, "Royalty transfer failed");
                totalRoyaltiesRouted += creatorRoyalty;
            }
        } else {
            IERC20 tokenContract = IERC20(paymentToken);
            require(tokenContract.transferFrom(msg.sender, address(this), totalCost), "Token payment failed");
            if (creatorRoyalty > 0) {
                require(tokenContract.transfer(royaltyReceiver, creatorRoyalty), "Royalty transfer failed");
                totalRoyaltiesRouted += creatorRoyalty;
            }
        }

        prop.tokensSold += tokenCount;
        propertyHoldings[propertyId][msg.sender] += tokenCount;

        emit PropertyTokensPurchased(propertyId, msg.sender, tokenCount, totalCost, creatorRoyalty);
        r
    // --- P2P Secondary Resale Market & Instant Liquidity Buyback ---

    struct SecondaryResaleListing {
        bytes32 listingId;
        bytes32 propertyId;
        address seller;
        uint256 tokenCount;
        uint256 pricePerToken;
        bool isActive;
    }

    mapping(bytes32 => SecondaryResaleListing) public secondaryListings;

    event SecondaryTokensListed(bytes32 indexed listingId, bytes32 indexed propertyId, address indexed seller, uint256 tokenCount, uint256 pricePerToken);
    event SecondaryTokensPurchased(bytes32 indexed listingId, bytes32 indexed propertyId, address indexed buyer, address indexed seller, uint256 tokenCount, uint256 totalPaid, uint256 royaltyDeducted, string subDeedId);
    event InstantBuybackExecuted(bytes32 indexed propertyId, address indexed investor, uint256 tokenCount, uint256 payoutAmount, uint256 liquidityDiscount);
    event SubDeedRegistered(string subDeedId, string parentDeedId, address indexed newOwner, uint256 tokensCount);

    /**
     * @notice Lists owned fractional property tokens on the P2P Secondary Market
     */
    function listTokensForSecondaryResale(
        bytes32 propertyId,
        uint256 tokenCount,
        uint256 pricePerToken
    ) external nonReentrant returns (bytes32) {
        require(tokenCount > 0, "Token count must be positive");
        require(pricePerToken > 0, "Price per token must be positive");
        require(propertyHoldings[propertyId][msg.sender] >= tokenCount, "Insufficient token holdings");

        // Escrow tokens on-chain
        propertyHoldings[propertyId][msg.sender] -= tokenCount;

        bytes32 listingId = keccak256(abi.encodePacked(propertyId, msg.sender, tokenCount, pricePerToken, block.timestamp));
        secondaryListings[listingId] = SecondaryResaleListing({
            listingId: listingId,
            propertyId: propertyId,
            seller: msg.sender,
            tokenCount: tokenCount,
            pricePerToken: pricePerToken,
            isActive: true
        });

        emit SecondaryTokensListed(listingId, propertyId, msg.sender, tokenCount, pricePerToken);
        return listingId;
    }

    /**
     * @notice Purchases a secondary market listing, transfers tokens to buyer, routes 1.0% royalty, and registers Sub-Deed
     */
    function buySecondaryResaleTokens(
        bytes32 listingId,
        address paymentToken,
        string calldata subDeedId,
        string calldata parentDeedId
    ) external payable nonReentrant returns (bool) {
        SecondaryResaleListing storage listing = secondaryListings[listingId];
        require(listing.isActive, "Listing is not active");
        uint256 totalCost = listing.tokenCount * listing.pricePerToken;
        uint256 creatorRoyalty = (totalCost * CREATOR_ROYALTY_BPS) / 10000; // 1.0%
        uint256 sellerPayout = totalCost - creatorRoyalty; // 99.0%

        if (paymentToken == address(0)) {
            require(msg.value >= totalCost, "Insufficient payment");
            if (creatorRoyalty > 0) {
                (bool sentRoyalty, ) = royaltyReceiver.call{value: creatorRoyalty}("");
                require(sentRoyalty, "Royalty transfer failed");
                totalRoyaltiesRouted += creatorRoyalty;
            }
            (bool sentSeller, ) = listing.seller.call{value: sellerPayout}("");
            require(sentSeller, "Seller transfer failed");
        } else {
            IERC20 tokenContract = IERC20(paymentToken);
            require(tokenContract.transferFrom(msg.sender, address(this), totalCost), "Token payment failed");
            if (creatorRoyalty > 0) {
                require(tokenContract.transfer(royaltyReceiver, creatorRoyalty), "Royalty transfer failed");
                totalRoyaltiesRouted += creatorRoyalty;
            }
            require(tokenContract.transfer(listing.seller, sellerPayout), "Seller payment failed");
        }

        listing.isActive = false;
        propertyHoldings[listing.propertyId][msg.sender] += listing.tokenCount;

        emit SecondaryTokensPurchased(listingId, listing.propertyId, msg.sender, listing.seller, listing.tokenCount, totalCost, creatorRoyalty, subDeedId);
        emit SubDeedRegistered(subDeedId, parentDeedId, msg.sender, listing.tokenCount);
        return true;
    }

    /**
     * @notice Instant Liquidity Buyback executed directly by Treasury Pool at 2% discount (98% payout)
     */
    function executeInstantLiquidityBuyback(
        bytes32 propertyId,
        uint256 tokenCount,
        address payoutToken
    ) external nonReentrant returns (bool) {
        require(propertyHoldings[propertyId][msg.sender] >= tokenCount, "Insufficient token holdings");
        TokenizedProperty storage prop = properties[propertyId];
        require(prop.isActive, "Property is inactive");

        uint256 nominalGross = tokenCount * prop.tokenPrice;
        uint256 discountSpread = (nominalGross * 200) / 10000; // 2.0% total spread
        uint256 netPayout = nominalGross - discountSpread;      // 98.0% payout to investor
        uint256 royaltyFee = discountSpread / 2;                // 1.0% creator royalty
        // Remaining 1.0% remains in treasury contract as liquidity buffer

        propertyHoldings[propertyId][msg.sender] -= tokenCount;

        if (payoutToken == address(0)) {
            require(address(this).balance >= netPayout, "Insufficient contract native liquidity");
            if (royaltyFee > 0) {
                (bool sentRoyalty, ) = royaltyReceiver.call{value: royaltyFee}("");
                require(sentRoyalty, "Royalty transfer failed");
                totalRoyaltiesRouted += royaltyFee;
            }
            (bool sentUser, ) = msg.sender.call{value: netPayout}("");
            require(sentUser, "Payout transfer failed");
        } else {
            IERC20 tokenContract = IERC20(payoutToken);
            require(tokenContract.balanceOf(address(this)) >= netPayout, "Insufficient contract token liquidity");
            if (royaltyFee > 0) {
                require(tokenContract.transfer(royaltyReceiver, royaltyFee), "Royalty transfer failed");
                totalRoyaltiesRouted += royaltyFee;
            }
            require(tokenContract.transfer(msg.sender, netPayout), "Payout transfer failed");
        }

        emit InstantBuybackExecuted(propertyId, msg.sender, tokenCount, netPayout, discountSpread);
        return true;
    }
eturn true;
    }

    // --- Administrative & Governance Functions ---

    /**
     * @notice Sets trusted remote peer for cross-chain LayerZero communication
     */
    function setTrustedPeer(uint32 eid, bytes32 peer) external onlyOwner {
        trustedRemotePeers[eid] = peer;
    }

    /**
     * @notice Configures LayerZero Endpoint v2 address
     */
    function setLayerZeroEndpoint(address _newEndpoint) external onlyOwner {
        address old = address(lzEndpoint);
        lzEndpoint = ILayerZeroEndpointV2(_newEndpoint);
        emit LayerZeroEndpointUpdated(old, _newEndpoint);
    }

    /**
     * @notice Updates the royalty receiver vault address (Restricted to Owner)
     */
    function updateRoyaltyReceiver(address newReceiver) external onlyOwner {
        require(newReceiver != address(0), "Invalid receiver address");
        address old = royaltyReceiver;
        royaltyReceiver = newReceiver;
        emit RoyaltyReceiverUpdated(old, newReceiver);
    }

    /**
     * @notice Emergency withdrawal helper (Restricted to Owner)
     */
    function emergencyWithdraw(address token, address to, uint256 amount) external onlyOwner nonReentrant {
        require(to != address(0), "Invalid destination address");
        if (token == address(0)) {
            (bool success, ) = to.call{value: amount}("");
            require(success, "Native withdrawal failed");
        } else {
            require(IERC20(token).transfer(to, amount), "Token withdrawal failed");
        }
        emit EmergencyFundsWithdrawn(token, to, amount);
    }
}
