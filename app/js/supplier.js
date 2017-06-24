var address;
var contractId;
var contract;

whenEnvIsLoaded(function() {
    setAddress(web3.eth.accounts[1]);

    $('#my_address').text(address);

    $('#sign_contract').on('click', function(e) {
        e.preventDefault();
        sendSignedContract();
    });

    getContractId().then(function() {
        contract = new EmbarkJS.Contract({ abi: BearingsExchange.abi, address: contractId });
        //console.log(contract);
        contract.ContractSent().then(e => showContractSection(e.args));
        contract.PaymentReceived().then(e => showPaymentReceivedSection(e.args));
        contract.PaymentRejected().then(e => showPaymentRejectedSection());
        contract.PaymentOK().then(e => showPaymentOKSection());
    });

});

function setAddress(_address) {
    address = _address;
    web3.eth.defaultAccount = _address;
}

function showContractSection(args) {
    $('#incoming_contract').removeClass("hidden");
    $('#manufacturer_address').text(args.manufacturerAddress);
    $('#contract_address').text(contract.address);
    $('#data').text(args.contractText);;
}

function sendSignedContract() {
    contract.executeNext().then(function(transaction) {
        $('#incoming_contract textarea, #incoming_contract button').prop("disabled", true)
    })
}

function getContractId() {
    return new Promise(function (resolve, reject) {
        (function waitForContractID(){
            contractId = getLastContractIdTransaction(address);
            if (contractId) {
                return resolve(contractId);
            }
            setTimeout(waitForContractID, 1000);
        })();
    });
};

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

function showPaymentReceivedSection(args) {
    $('#received_amount').text(args.paymentAmount.c[0]);
    $('#payment_received').removeClass('hidden');
}


function showPaymentRejectedSection() {
    $('#payment_rejected').removeClass("hidden");
}

function showPaymentOKSection() {
    $('#produce_bearings').removeClass("hidden");
}