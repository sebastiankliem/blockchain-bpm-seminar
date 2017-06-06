var address;
var contractId;

whenEnvIsLoaded(function() {
    address = web3.eth.accounts[1];

    //Manufacturer.ContractSent().then(function(e) {
    //    console.log(e.args);
    //    showContractSection(e.args);
    //});

    //Manufacturer.SignedContractReceived().then(function(e) {
    //    console.log(e.args);
    //    showSignedContractSection(e.args);
    //});

    $('#sign_contract').on('click', function(e) {
        e.preventDefault();
        sendSignedContract();
    });

    //TODO: loop!
    contractId = getLastContractId(address);
});

function sendSignedContract() {
    let contractData = JSON.parse($('#supplier__data').text());
    contractData.signed = true;
    Supplier.signContract(Manufacturer.address, JSON.stringify(contractData)).then(function(transaction) {
        $('#supplier>.section:first textarea, #supplier>.section:first button').prop("disabled", true)
        $('#supplier>.section:first').append('<div class="status">sent to manufacturer</div>');
    })
}

function showContractSection(args) {
    $('#supplier>.section:first').removeClass("hidden");
    $('#manufacturer_address').text(args.manufacturerAddress);
    $('#data').text(args.contractText);
}

function getLastContractId(myaccount) {
  for (var i = web3.eth.blockNumber - 1; i >= 0; i--) {
    console.log("Searching for block " + i)
    var block = web3.eth.getBlock(i, true);
    if (block != null && block.transactions != null) {
        for (var i = 0; i < block.transactions.length; i++) {
            var transaction = block.transactions[i];
            if (myaccount == transaction.to) {
                console.log("Last Contract ID: " + transaction.input);
                return transaction.input;
            }
        }
    }
  }
}