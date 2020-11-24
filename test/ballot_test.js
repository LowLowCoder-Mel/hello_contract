const Ballot = artifacts.require('Ballot');

contract("Ballot Test", ([alice, bob, carol, song, yuan]) => {
  beforeEach(async() => {
    let proposals = [web3.utils.asciiToHex("proposal_yes"), web3.utils.asciiToHex("proposa_no")];
    this.ballot = await Ballot.new(proposals, {from: alice});
  });

  xit('查看第一个提案', async() => {
    console.log(await this.ballot.proposals(0));
  });

  it('给第一个提案投票', async() => {
    let before_prop = await this.ballot.proposals(0);
    console.log('before vote ', before_prop.voteCount);
    // 先给bob授权可以投票
    await this.ballot.giveRightToVote(bob, {from: alice});
    await this.ballot.vote(0, {from: bob});
    let after_prop = await this.ballot.proposals(0);
    console.log('after vote ', after_prop.voteCount);
    assert.equal(after_prop.voteCount, 0);
  });

  it('委托给其他人投票', async() => {
    // 先给授权
    await this.ballot.giveRightToVote(bob, {from: alice});
    await this.ballot.giveRightToVote(carol, {from: alice});
    // 委托投票权给song
    await this.ballot.delegate(song, {from: bob});
    // 开始投票
    let before_prop = await this.ballot.proposals(0);
    console.log('before vote ', before_prop.voteCount);
    await this.ballot.vote(0, {from: carol});
    await this.ballot.vote(0, {from: song});
    // 查看结果
    let after_prop = await this.ballot.proposals(0);
    console.log('after vote ', after_prop.voteCount);
  });
});