var address;
var contractId;
var contract;
var manufacturer;

whenEnvIsLoaded(function() {
    address = web3.eth.accounts[1];

    $('#my_address').text(address);

    $('#sign_contract').on('click', function(e) {
        e.preventDefault();
        sendSignedContract();
    });

    let setContractId = () => {
        let tx = getLastContractIdTransaction(address);
        if (!tx) {
            setTimeout(setContractId, 1000); // do polling on the contract id
        } else {
            contractId = tx.contractId;
            manufacturer = tx.manufacturer;
        }
    };
    setContractId();

    contract = new EmbarkJS.Contract({ abi: BearingsExchange.abi, address: contractId });
    console.log(contract);
    contract.ContractSent().then(e => showContractSection(e.args));
});

function sendSignedContract() {
    contract.signContract(manufacturer, address, $('#data').text()).then(function(transaction) {
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
    console.log("Searching in block " + i);
    var block = web3.eth.getBlock(i, true);
    if (block != null && block.transactions != null) {
        for (var j = 0; j < block.transactions.length; j++) {
            var transaction = block.transactions[j];
            if (myaccount == transaction.to) {
                console.log("Last Contract ID: " + transaction.input);
                return {
                    contractId: transaction.input,
                    manufacturer: transaction.from
                };
            }
        }
    }
  }
  return null; // contract not found
}