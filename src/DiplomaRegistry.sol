// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DiplomaRegistry {
    address public issuer;
    uint256 public nextId;

    struct Diploma {
        uint256 id;
        address student;
        bytes32 documentHash;
        uint256 issuedAt;
        string institution;
        bool revoked;
    }

    mapping(uint256 => Diploma) public diplomas;

    event DiplomaIssued(
        uint256 indexed id,
        address indexed student,
        bytes32 documentHash
    );

    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only issuer");
        _;
    }

    constructor(address _issuer) {
        issuer = _issuer;
        nextId = 1;
    }

    function issueDiploma(
        address student,
        bytes32 documentHash,
        string calldata institution
    ) external onlyIssuer returns (uint256) {
        uint256 id = nextId++;

        diplomas[id] = Diploma({
            id: id,
            student: student,
            documentHash: documentHash,
            issuedAt: block.timestamp,
            institution: institution,
            revoked: false
        });

        emit DiplomaIssued(id, student, documentHash);
        return id;
    }

    function verifyDiploma(uint256 id, bytes32 documentHash)
    external
    view
    returns (bool)
    {
        return diplomas[id].documentHash == documentHash && !diplomas[id].revoked;
    }

    event DiplomaRevoked(uint256 indexed id);

    function revokeDiploma(uint256 id) external onlyIssuer {
        require(diplomas[id].id != 0, "Diploma does not exist");
        require(!diplomas[id].revoked, "Already revoked");

        diplomas[id].revoked = true;

        emit DiplomaRevoked(id);
    }
}
