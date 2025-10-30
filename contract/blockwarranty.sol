// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title ProofOfProductCoverage
/// @notice Simple contract to register products and store verifiable coverage proofs (e.g., IPFS URI + proof hash).
/// @dev Beginner-friendly. No external imports to keep single-file. Extend with access control or upgradeability as needed.
contract ProofOfProductCoverage {
    uint256 private productCounter;

    struct Product {
        uint256 id;
        address owner;
        string metadataURI; // optional product metadata (IPFS/URL)
        bool exists;
    }

    struct Coverage {
        address reporter;    // who added the coverage (could be owner or third-party)
        string proofURI;     // human-readable URI (IPFS, Arweave, or link to evidence)
        bytes32 proofHash;   // keccak256 hash of the canonical proof string/file
        uint256 timestamp;
        string note;         // optional short note
    }

    // productId => Product
    mapping(uint256 => Product) public products;

    // productId => list of coverage records
    mapping(uint256 => Coverage[]) private coverages;

    /* EVENTS */
    event ProductRegistered(uint256 indexed productId, address indexed owner, string metadataURI);
    event CoverageAdded(uint256 indexed productId, uint256 indexed coverageIndex, address indexed reporter, bytes32 proofHash, string proofURI);

    /* MODIFIERS */
    modifier productExists(uint256 productId) {
        require(products[productId].exists, "Product does not exist");
        _;
    }

    modifier onlyProductOwner(uint256 productId) {
        require(products[productId].owner == msg.sender, "Not product owner");
        _;
    }

    /* CONSTRUCTOR */
    constructor() {
        productCounter = 0;
    }

    /// @notice Register a new product. Returns the new productId.
    /// @param metadataURI optional pointer to product metadata (IPFS/URL)
    function registerProduct(string calldata metadataURI) external returns (uint256) {
        uint256 newId = ++productCounter;
        products[newId] = Product({
            id: newId,
            owner: msg.sender,
            metadataURI: metadataURI,
            exists: true
        });

        emit ProductRegistered(newId, msg.sender, metadataURI);
        return newId;
    }

    /// @notice Add a coverage proof for a product.
    /// @dev The proofHash should be keccak256 of the canonical proof bytes/string (e.g. keccak256(abi.encodePacked(fileBytes))).
    /// @param productId id of the product
    /// @param proofURI optional URI (IPFS link, etc.) pointing to the proof file/details
    /// @param proofHash keccak256 hash of the canonical proof content
    /// @param note optional short note
    function addCoverage(
        uint256 productId,
        string calldata proofURI,
        bytes32 proofHash,
        string calldata note
    ) external productExists(productId) {
        // Allow anyone to submit coverage (reporter recorded). If you want only owner, add onlyProductOwner modifier.
        Coverage memory c = Coverage({
            reporter: msg.sender,
            proofURI: proofURI,
            proofHash: proofHash,
            timestamp: block.timestamp,
            note: note
        });

        coverages[productId].push(c);
        uint256 index = coverages[productId].length - 1;
        emit CoverageAdded(productId, index, msg.sender, proofHash, proofURI);
    }

    /// @notice Get number of coverage records for product
    function getCoverageCount(uint256 productId) external view productExists(productId) returns (uint256) {
        return coverages[productId].length;
    }

    /// @notice Retrieve one coverage record
    function getCoverage(uint256 productId, uint256 index) external view productExists(productId) returns (
        address reporter,
        string memory proofURI,
        bytes32 proofHash,
        uint256 timestamp,
        string memory note
    ) {
        require(index < coverages[productId].length, "Coverage index out of range");
        Coverage storage c = coverages[productId][index];
        return (c.reporter, c.proofURI, c.proofHash, c.timestamp, c.note);
    }

    /// @notice Verify a claimed proof against stored proof hash
    /// @dev Caller provides the original proof content (or canonical string). The function computes keccak256 and compares.
    /// @param productId id of the product
    /// @param index coverage index to verify
    /// @param claimedProof the original proof data as string/bytes (use same canonical serialization used when storing proofHash)
    /// @return isValid true if keccak256(claimedProof) equals stored proofHash
    function verifyProof(uint256 productId, uint256 index, string calldata claimedProof) external view productExists(productId) returns (bool isValid, bytes32 storedHash, bytes32 computedHash) {
        require(index < coverages[productId].length, "Coverage index out of range");
        storedHash = coverages[productId][index].proofHash;
        computedHash = keccak256(abi.encodePacked(claimedProof));
        isValid = (computedHash == storedHash);
        return (isValid, storedHash, computedHash);
    }

    /* OPTIONAL: helper for product owner to update metadata */
    function updateProductMetadata(uint256 productId, string calldata newMetadataURI) external productExists(productId) onlyProductOwner(productId) {
        products[productId].metadataURI = newMetadataURI;
    }
}
