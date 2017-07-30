// example flow of executing the "Escrow" contract
var esc = null;
var logEvent = e => console.log(e.event, e.args);
var next = a => esc.executeNext(a, {gas:400000}).then(console.log);
Escrow.deploy([web3.eth.accounts[0], web3.eth.accounts[1]], { gas: 4500000 }).then(c => {
  esc = c; console.log("cho loaded");
  esc.ExecuteNext().then(e => console.log(e.event));
  esc.TransitionE().then(logEvent); esc.Done().then(e => console.log(e.event));
  esc.NextSender().then(logEvent); esc.Length().then(logEvent); esc.LastStep().then(logEvent);
  esc.NotEnoughGas().then(logEvent); esc.GasLeft().then(logEvent);
  esc.SendPayment().then(logEvent); esc.Refunded().then(logEvent); esc.RefundFailed().then(logEvent);
  
});
var acc0 = web3.eth.accounts[0];
var acc1 = web3.eth.accounts[1];
