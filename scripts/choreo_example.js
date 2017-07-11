// example flow of executing the "Choreo" contract
var cho = null;
Choreo.deploy([web3.eth.accounts[0], web3.eth.accounts[1]], { gas: 4500000 }).then(c => {cho = c;
  cho.If().then(e => console.log(e.event)); cho.ExecuteNext().then(e => console.log(e.event));
  cho.TransitionE().then(e => console.log(e));  cho.DoStep0().then(e => console.log(e.event)); 
  cho.DoStep2().then(e => console.log(e.event));  cho.Done().then(e => console.log(e.event));
  cho.NextSender().then(console.log); cho.Length().then(console.log); cho.LastStep().then(console.log);
});
var acc0 = web3.eth.accounts[0];
var acc1 = web3.eth.accounts[1];
cho.executeNext(acc0, {gas:400000}).then(console.log);
cho.step0Done().then(console.log);
// etc
