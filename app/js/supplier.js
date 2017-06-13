var address;
var contractId;
var contract;

whenEnvIsLoaded(function() {
    address = web3.eth.accounts[1];

    $('#sign_contract').on('click', function(e) {
        e.preventDefault();
        sendSignedContract();
    });

    //TODO: i need to refresh to work properly
    let getContractId = () => {
        contractId = getLastContractIdTransaction(address);
        if (!contractId) {
            setTimeout(getContractId, 1000); // do polling on the contract id
        }
    };
    getContractId();

    contract = new EmbarkJS.Contract({ abi: BearingsExchange.abi, address: contractId });
    console.log(contract);
    contract.ContractSent().then(e => showContractSection(e.args));
});

function sendSignedContract() {
    contract.executeNext().then(function(transaction) {
        $('#supplier>.section:first textarea, #supplier>.section:first button').prop("disabled", true)
        $('#supplier>.section:first').append('<div class="status">sent to manufacturer</div>');
    })
}

function showContractSection(args) {
    $('#supplier>.section:first').removeClass("hidden");
    $('#manufacturer_address').text(args.manufacturerAddress);
    $('#data').text(args.contractText);
}

function getLastContractIdTransaction(myaccount) {
  for (var i = web3.eth.blockNumber - 1; i >= 0; i--) {
    var block = web3.eth.getBlock(i, true);
    if (block != null && block.transactions != null) {
        for (var j = 0; j < block.transactions.length; j++) {
            var transaction = block.transactions[j];
            if (myaccount == transaction.to) {
                console.log("Last Contract ID: " + transaction.input);
                return transaction.input;
            }
        }
    }
  }
  return null; // contract not found
}