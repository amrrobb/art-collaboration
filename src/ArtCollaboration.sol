// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ArtCollaboration {
    address public owner;
    uint256 public artPieceCounter;

    enum Theme {
        Abstract,
        Realism,
        Surrealism,
        Impressionism,
        Expressionism,
        Other
    }
    enum Medium {
        Painting,
        Sculpture,
        DigitalArtwork,
        Other
    }
    enum Dimensions {
        Small,
        Medium,
        Large,
        Other
    }
    enum Ownership {
        Joint,
        Individual
    }

    struct ArtPiece {
        string description;
        address[] artists;
        mapping(address => uint256) ownership; // 1 = owned; 0 = not owned
        uint256 saleProceeds;
        bool completed;
        Theme theme;
        Medium medium;
        Dimensions dimensions;
        Ownership ownershipType;
    }

    struct Dispute {
        string description;
        address artist1;
        address artist2;
        string evidence;
        address arbitrator;
        address decision;
    }

    struct Milestone {
        string description;
        uint256 deadline;
        bool completed;
    }

    mapping(uint256 artPieceId => ArtPiece) public artPieces;
    mapping(uint256 artPieceId => uint256) public disputesCount;
    mapping(uint256 artPieceId => mapping(uint256 disputeId => Dispute)) public disputes;
    mapping(uint256 artPieceId => Milestone[]) public milestones;
    mapping(uint256 artPieceId => mapping(address => bool)) public artistSigned; // Mapping to track artist signatures per art piece

    event ArtPieceCreated(
        uint256 artPieceId,
        string description,
        address[] artists,
        Theme theme,
        Medium medium,
        Dimensions dimensions,
        Ownership ownershipType
    );
    event ArtPieceCompleted(uint256 artPieceId, string description);
    event OwnershipRightsEstablished(uint256 artPieceId, Ownership ownershipType);

    event SaleProceedsDistributed(uint256 artPieceId, uint256 amount);
    event DisputeInitiated(
        uint256 artPieceId, uint256 disputeId, string description, address artist1, address artist2, string evidence
    );
    event DisputeResolved(
        uint256 artPieceId, uint256 disputeId, string description, address arbitrator, address decision
    );
    event MilestoneSet(uint256 artPieceId, uint256 milestoneId, string description, uint256 deadline);
    event MilestoneCompleted(uint256 artPieceId, uint256 milestoneId, string description);

    event ArtistSigned(uint256 artPieceId, address artist);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function.");
        _;
    }

    modifier allArtistsSigned(uint256 _artPieceId) {
        require(artistSigned[_artPieceId][msg.sender], "Artist has not signed the contract for this art piece.");
        _;
    }

    constructor() {
        owner = msg.sender;
        artPieceCounter = 1;
    }

    function createArtPiece(
        string memory _description,
        address[] memory _artists,
        Theme _theme,
        Medium _medium,
        Dimensions _dimensions,
        Ownership _ownershipType
    ) public onlyOwner {
        ArtPiece storage newArtPiece = artPieces[artPieceCounter];
        newArtPiece.description = _description;
        newArtPiece.artists = _artists;
        for (uint256 i = 0; i < _artists.length; i++) {
            newArtPiece.ownership[_artists[i]] = 1;
        }
        newArtPiece.theme = _theme;
        newArtPiece.medium = _medium;
        newArtPiece.dimensions = _dimensions;
        newArtPiece.ownershipType = _ownershipType;

        artPieceCounter++;

        emit ArtPieceCreated(artPieceCounter, _description, _artists, _theme, _medium, _dimensions, _ownershipType);
        emit OwnershipRightsEstablished(artPieceCounter, _ownershipType);
    }

    function completeArtPiece(uint256 _artPieceId) public onlyOwner {
        require(artPieces[_artPieceId].artists.length > 0, "Art piece with this ID does not exist.");
        require(!artPieces[_artPieceId].completed, "Art piece is already completed.");

        artPieces[_artPieceId].completed = true;

        emit ArtPieceCompleted(_artPieceId, artPieces[_artPieceId].description);
    }

    function distributeProceeds(uint256 _artPieceId, uint256[] memory _contributions) public onlyOwner {
        require(artPieces[_artPieceId].completed, "Art piece must be completed before distributing proceeds.");
        require(_contributions.length == artPieces[_artPieceId].artists.length, "Invalid number of contributions.");

        uint256 totalProceeds = artPieces[_artPieceId].saleProceeds;
        uint256 totalContributions = 0;
        for (uint256 i = 0; i < _contributions.length; i++) {
            totalContributions += _contributions[i];
        }
        require(totalProceeds >= totalContributions, "Insufficient proceeds to distribute.");

        for (uint256 i = 0; i < artPieces[_artPieceId].artists.length; i++) {
            address artist = artPieces[_artPieceId].artists[i];
            uint256 share = (totalProceeds * _contributions[i]) / totalContributions;
            payable(artist).transfer(share);
        }

        emit SaleProceedsDistributed(_artPieceId, totalProceeds);
    }

    function initiateDispute(
        uint256 _artPieceId,
        string memory _description,
        address _artist1,
        address _artist2,
        string memory _evidence
    ) public onlyOwner {
        require(artPieces[_artPieceId].artists.length > 0, "Art piece with this ID does not exist.");

        // Increment dispute count
        incrementDisputeCount(_artPieceId);

        // Use the current dispute count as the dispute ID
        uint256 disputeId = getDisputesCount(_artPieceId);
        disputes[_artPieceId][disputeId] = Dispute(_description, _artist1, _artist2, _evidence, owner, address(0));

        emit DisputeInitiated(_artPieceId, disputeId, _description, _artist1, _artist2, _evidence);
    }

    function resolveDispute(uint256 _artPieceId, uint256 _disputeId, address _decision) public onlyOwner {
        require(disputes[_artPieceId][_disputeId].arbitrator == msg.sender, "Only arbitrator can resolve dispute.");

        disputes[_artPieceId][_disputeId].decision = _decision;

        emit DisputeResolved(
            _artPieceId, _disputeId, disputes[_artPieceId][_disputeId].description, msg.sender, _decision
        );
    }

    function setMilestone(uint256 _artPieceId, string memory _description, uint256 _deadline) public onlyOwner {
        milestones[_artPieceId].push(Milestone(_description, _deadline, false));

        emit MilestoneSet(_artPieceId, milestones[_artPieceId].length - 1, _description, _deadline);
    }

    function markMilestoneCompleted(uint256 _artPieceId, uint256 _milestoneId) public onlyOwner {
        require(_milestoneId < milestones[_artPieceId].length, "Invalid milestone ID.");

        Milestone storage milestone = milestones[_artPieceId][_milestoneId];
        milestone.completed = true;

        emit MilestoneCompleted(_artPieceId, _milestoneId, milestone.description);
    }

    function signContract(uint256 _artPieceId) public {
        require(artPieceCounter > 0, "No art pieces created yet.");
        require(artPieces[_artPieceId].artists.length > 0, "Art piece with this ID does not exist.");

        artistSigned[_artPieceId][msg.sender] = true;

        emit ArtistSigned(_artPieceId, msg.sender);
    }

    // Helper function
    function incrementDisputeCount(uint256 _artPieceId) internal {
        disputesCount[_artPieceId]++;
    }

    function getDisputesCount(uint256 _artPieceId) public view returns (uint256) {
        return disputesCount[_artPieceId];
    }
}
