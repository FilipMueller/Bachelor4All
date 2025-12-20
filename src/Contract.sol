// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProjectRegistry {
    address public admin;
    uint256 public nextId;

    struct Project {
        uint256 id;
        address submitter;
        string title;
        string ipfsHash; // link to project files (IPFS CID)
        uint256 createdAt;
        bool approved;
        uint256 totalScore; // sum of scores
        uint256 numReviews;
    }

    // project id => Project
    mapping(uint256 => Project) public projects;
    // project id => reviewer => bool (prevent double reviews)
    mapping(uint256 => mapping(address => bool)) public hasReviewed;

    event ProjectCreated(uint256 indexed id, address indexed submitter, string title, string ipfsHash);
    event ProjectUpdated(uint256 indexed id, string title, string ipfsHash);
    event ProjectApproved(uint256 indexed id, address indexed admin);
    event ProjectReviewed(uint256 indexed id, address indexed reviewer, uint8 score);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    modifier onlySubmitter(uint256 _id) {
        require(projects[_id].submitter == msg.sender, "Only submitter");
        _;
    }

    constructor(address _admin) {
        admin = _admin == address(0) ? msg.sender : _admin;
        nextId = 1;
    }

    /// @notice Submit a new project
    function createProject(string calldata _title, string calldata _ipfsHash) external returns (uint256) {
        uint256 id = nextId++;
        projects[id] = Project({
            id: id,
            submitter: msg.sender,
            title: _title,
            ipfsHash: _ipfsHash,
            createdAt: block.timestamp,
            approved: false,
            totalScore: 0,
            numReviews: 0
        });

        emit ProjectCreated(id, msg.sender, _title, _ipfsHash);
        return id;
    }

    /// @notice Submitter can update title/ipfsHash before approval
    function updateProject(uint256 _id, string calldata _title, string calldata _ipfsHash) external onlySubmitter(_id) {
        require(!projects[_id].approved, "Already approved");
        projects[_id].title = _title;
        projects[_id].ipfsHash = _ipfsHash;
        emit ProjectUpdated(_id, _title, _ipfsHash);
    }

    /// @notice Admin approves project, allowing reviews
    function approveProject(uint256 _id) external onlyAdmin {
        require(projects[_id].submitter != address(0), "No such project");
        projects[_id].approved = true;
        emit ProjectApproved(_id, msg.sender);
    }

    /// @notice Add a review score (1..5) if project is approved and not reviewed before by sender
    function addReview(uint256 _id, uint8 _score) external {
        require(_score >= 1 && _score <= 5, "Score 1-5");
        Project storage p = projects[_id];
        require(p.submitter != address(0), "No such project");
        require(p.approved, "Not approved");
        require(msg.sender != p.submitter, "Submitter cannot review own project");
        require(!hasReviewed[_id][msg.sender], "Already reviewed");

        hasReviewed[_id][msg.sender] = true;
        p.totalScore += _score;
        p.numReviews += 1;

        emit ProjectReviewed(_id, msg.sender, _score);
    }

    /// @notice View average score (0 if no reviews)
    function averageScore(uint256 _id) public view returns (uint256) {
        Project storage p = projects[_id];
        if (p.numReviews == 0) return 0;
        return p.totalScore / p.numReviews;
    }

    /// @notice Convenience getter for project metadata (avoid returning nested mappings)
    function getProject(uint256 _id)
    external
    view
    returns (
        uint256 id,
        address submitter,
        string memory title,
        string memory ipfsHash,
        uint256 createdAt,
        bool approved,
        uint256 totalScore,
        uint256 numReviews
    )
    {
        Project storage p = projects[_id];
        return (p.id, p.submitter, p.title, p.ipfsHash, p.createdAt, p.approved, p.totalScore, p.numReviews);
    }
}
