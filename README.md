# Art Collaboration Smart Contract

## Description

This smart contract facilitates collaboration between artists for creating art pieces.

## Usage

1. **Build the Contract**:

   - Execute the following command in your terminal to build the ArtCollaboration smart contract:
     ```
     make build
     ```

2. **Start Local Development Environment**:

   - Run the following command in your terminal to start the local development environment:
     ```
     make anvil
     ```

3. **Deploy the Contract**:
   - Open a new terminal window, then execute the following command to deploy the ArtCollaboration smart contract:
     ```
     make deploy
     ```

# Functions

## Art Piece Creation

### createArtPiece Function

- **Purpose**: Creates a new art piece and initializes its details.
- **Explanation**:
  - This function allows the contract owner to create a new art piece by specifying its description, artists involved, theme, medium, dimensions, and ownership type.
  - It initializes the ownership of the art piece, sets it as incomplete, and emits an event to notify the creation of the art piece.

## Art Piece Completion

### completeArtPiece Function

- **Purpose**: Marks an art piece as completed.
- **Explanation**:
  - This function allows the contract owner to mark an art piece as completed once the collaboration is finished.
  - It prevents further modifications to the art piece and emits an event to notify its completion.

## Proceeds Distribution

### distributeProceeds Function

- **Purpose**: Distributes proceeds from the sale or exhibition of an art piece among the collaborating artists.
- **Explanation**:
  - This function calculates and distributes proceeds based on the contributions of each artist.
  - It ensures that the art piece is completed before distribution and emits an event to notify proceeds distribution.

## Dispute Management

### initiateDispute Function

- **Purpose**: Initiates a dispute related to an art piece.
- **Explanation**:
  - This function allows the contract owner to initiate a dispute between artists regarding the collaboration or ownership.
  - It increments the dispute count for the art piece and emits an event to notify the initiation of the dispute.

### resolveDispute Function

- **Purpose**: Resolves a dispute related to an art piece.
- **Explanation**:
  - This function allows the contract owner (arbitrator) to resolve a dispute between artists.
  - It updates the decision regarding the dispute and emits an event to notify the resolution.

## Milestone Management

### setMilestone Function

- **Purpose**: Sets a milestone for an art piece collaboration.
- **Explanation**:
  - This function allows the contract owner to set a milestone for the progress of the collaboration.
  - It adds a milestone with a description and timestamp to the art piece and emits an event to notify milestone setting.

### markMilestoneCompleted Function

- **Purpose**: Marks a milestone as completed.
- **Explanation**:
  - This function allows the contract owner to mark a milestone as completed once it's achieved.
  - It updates the status of the milestone and emits an event to notify milestone completion.

## Digital Signature

### signContract Function

- **Purpose**: Allows artists to digitally sign the contract.
- **Explanation**:
  - This function allows each artist to sign the contract indicating their agreement to the terms and conditions.
  - It tracks artist signatures for each art piece and emits an event to notify artist signing.
