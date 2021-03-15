const Purchase = artifacts.require('Purchase');

contract("Purchase Contract Test", ([alice, bob, carol, song]) => {

  beforeEach(async() => {
    purchase = await Purchase.new({from: alice, value: 10});
  });

  it("test constructor", async() => {
    let curValue = await this.purchase.value();
    console.log(curValue);
  });

});