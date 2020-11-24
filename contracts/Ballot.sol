// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/// @title Voting
contract Ballot {

    // 投票者
    struct Voter {
        uint256 weight;
        bool voted;
        address delegate;
        uint voteIndex;
    }

    // 提案
    struct Proposal {
        bytes32 name;
        uint256 voteCount;
    }

    // 主席地址
    address public chairperson;
    // 投票
    mapping(address => Voter) public voters;
    // 提案集合
    Proposal[] public proposals;

    // 构造函数, 需要传入草案的简介名称
    constructor(bytes32[] memory _proposalNames) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        for (uint i = 0; i < _proposalNames.length; i++) {
            proposals.push(Proposal({
                name: _proposalNames[i],
                voteCount: 0
            }));
        }
    }

    // 给投票者授权
    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(
            voters[voter].weight == 0,
            ""
        );
        voters[voter].weight = 1;
    }

    // 将投票权委托给其他地址
    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(
            !sender.voted,
            "You Already vote"
        );
        require(
            to != msg.sender,
            "Self-delegation is disallowed."
        );
        while(voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(
                to != msg.sender,
                ""
            );
        }
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // 如果已经投票了，直接将委托者的投票累加到指定的草案上
            proposals[delegate_.voteIndex].voteCount = sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    // 投票给草案
    function vote(uint256 _proposal) public {
        Voter storage sender = voters[msg.sender];
        require(
            sender.weight != 0,
            "Has no right to vote"
        );
        require(
            !sender.voted,
            "Already voted"
        );
        sender.voted = true;
        sender.voteIndex = _proposal;
        // 超出索引会自动将交易回滚
        proposals[_proposal].voteCount += sender.weight;
    }

    // 查看哪个投票数最多
    function winningProposal() public view returns (uint winningProposal_) {
        uint256 winningVoteCount = 0;
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposal_ = i;
            }
        }
    }

    // 提案结果的名字
    function winnerName() public view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }
}