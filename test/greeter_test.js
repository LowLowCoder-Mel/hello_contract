const Greeter = artifacts.require('Greeter');

contract("Greeter Test", ([alice, bob, carol]) => {
  xit('first test', async() => {
      const greeter = await Greeter.new({from: alice});
      console.log('before greeting', (await greeter.greet()));
      let result = await greeter.setGreeting(1);
      console.log(result);
      // 获取事件
      console.log('Event: ', result.logs[0].event);
      console.log(result.logs[0].args);
      console.log('Event: ', result.logs[1].event);
      console.log(result.logs[1].args);
      console.log('after greeting', (await greeter.greet()));
  });
});