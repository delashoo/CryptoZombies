// SPDX-License-Identifier: GPL 3.0

pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

/// @title PigaKura - A voting contract.
/// @author Xamdimek

contract PigaKura {

    /**
     * @notice A struct representing a single voter.
     * @dev Weight is accumulated by delegation, 
     *      voted is a boolean variable that checks if the address has already cast a vote or not,
     *      delegate is an address of the person to whom they have been granted the opportunity to vote on behalf of the voter
     *      vote is an unsigned integer representing the index of the proposal the voter is supporting.
     */
    struct Voter {
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }

    /**
     * @notice A struct representing a single proposal
     * @dev Name is for the proposal's name.
     *      voteCount is an unsigned integer for the number of accumulated votes the particular proposal received.
     */
    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    /**
     * @notice Other state variables to be used in this contract.
     * @dev An address of the person conducting the elections
     *      A mapping of address to the Voter struct, mapping every external account's address to the Voter struct.
     *      An array of the Proposal structs. [The choices to be voted on.]
     */
    address public electionOfficer;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    /**
     * @notice A constructor
     * @param proposalNames, an array of proposal names submitted
     *      For each proposal name, constructor code creates a new proposal object [The struct], with the name given and initialized voteCount of zero[0].
     *      This object is then pushed onto the end of proposals array.
     */
    constructor(bytes32[] memory proposalNames) {
        electionOfficer = msg.sender;
        voters[electionOfficer].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal[
                name: proposalNames[i],
                voteCount: 0
            ]);
        }
    }

    /**
     * @notice An external function called by the electionOfficer to give rights to vote to voters, 
     *          ie. A process similar to registering voters in a non-electronic process.
     * Why is the function external?
     * @param address of the Voter.
     * @dev 1st Require statement checks that only the electionOfficer can provide rights to vote.
     *      2nd Require statement checks that the Voter in question has not voted. The struct of Voter has a 'voted' aspect that's boolean.
     *      3rd Require statement confirms that the voter's address has not been delegated to vote before, this is by checking their voter's weight.
     *      Afterwards, the Voter's weight is set to 1, from zero, allowing them to vote.
     * Require statements used to use up all the gas but things are different with the new EVM versions, How?
     */
    function giveVotingRights(address voter) external {
        require(msg.sender == electionOfficer, "Sorry, you are not the election officer!");
        require(!voters[voter].voted, "Relax, you have already voted!");
        require(voters[voter].weight == 0);

        voters[voter].weight = 1;
    }

    /**
     * @notice An external function to delegate the rights to vote to someone else. Remember, people in this case are represented with their wallet's address.
     *          This address is derived from their public key but you probably know that.
     * @dev Assign reference of the function caller to the voters mapping
     *      3 require statements: The first one checks if the msg.sender of the function actually has rights to vote given to them.
     *                            The second one checks that msg.sender has not already voted.
     *                            The third one checks that the msg.sender is not delegating the voting rights to themselves.
     *      Self-delegation causes a loop that leads to the contract being stuck completely. All block's gas ends up being used up without achieving anything.
     *      while loop to do the delegation process, checks the delegated to address is not a zero address and actually has rights to vote before they vote.
     *      
     */
    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Omo, you can't vote nau!");
        require(!sender.voted, "Stop being stupid, you can't delegate what you have already done. Are you normal?");
        require(to != msg.sender, "What are you doing? Self-delegation is disallowed");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            require(to != msg.sender, "You cannot self-delegate, nini mbaya na wewe?");
        }

        Voter storage _delegate = voters[to];

        require(_delegate.weight >= 1, "Sorry, the address you delegating to, has no voting rights!");

        sender.voted = true;
        sender.delegate = to;

        if (_delegate.voted) {
            proposals[_delegate.vote].voteCount += sender.weight;
        } else {
            _delegate.weight += sender.weight;
        }
    }

    /**
     * @notice An external function to give a vote, including the ones delegated to you.
     * @param proposal, an unsigned integer of the proposal's name that you are supporting.
     *      Checks: That the address' weight is 1 or above one, otherwise they have no rights to vote,
     *              That the address owner has not voted yet.
     */
    function vote(uint proposal) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight >= 1, "No voting rights assigned!");
        require(!sender.voted, "Relax, you have already voted");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

    /**
     * @notice Computes wining proposal by taking all previous votes into account.
     * @dev Initialize the winning vote count variable, 
     */
    function winningProposal() public view returns(uint _winningProposal) {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposal[p].voteCount > winningVoteCount) {
                winningVoteCount = proposal[p].voteCount;
                _winningProposal = p;
            }
        }
    }

    /**
     * @notice Calls the above function to get the index of the winner from the proposal array and returns the name of winner.
     */
    function winnerName() external view returns(bytes32 _winnerName) {
        _winnerName = proposals[winningProposal()].name;
    }

    /**
     * This contract need improvements to work on two proposals that have tied number of votes, also many transactions are made to grant voters rights to vote.
     * 
     */
}
