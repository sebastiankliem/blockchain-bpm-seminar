// example flow of executing the "Choreo" contract
var cho = null;
var logEvent = e => console.log(e.event, e.args);
var next = a => cho.executeNext(a, {gas:400000}).then(console.log);
Choreo.deploy([web3.eth.accounts[0], web3.eth.accounts[1]], { gas: 4500000 }).then(c => {
  cho = c; console.log("cho loaded");
  cho.If().then(e => console.log(e.event)); cho.ExecuteNext().then(e => console.log(e.event));
  cho.TransitionE().then(e => console.log(e));  cho.DoStep0().then(e => console.log(e.event)); 
  cho.DoStep2().then(e => console.log(e.event));  cho.Done().then(e => console.log(e.event));
  cho.NextSender().then(logEvent); cho.Length().then(logEvent); cho.LastStep().then(logEvent);
  cho.NotEnoughGas().then(logEvent); cho.GasLeft().then(logEvent);
});
var acc0 = web3.eth.accounts[0];
var acc1 = web3.eth.accounts[1];
// execute the steps
next(acc0);
cho.step0Done().then(console.log);
// etc
