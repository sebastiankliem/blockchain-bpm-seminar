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
    $('#send_bearings').on('click', function(e) {
        e.preventDefault();
        sendBearings();
    });
    $('#send_fee').on('click', function(e) {
        e.preventDefault();
        sendFee();
    });

    getContractId().then(function() {
        contract = new EmbarkJS.Contract({ abi: BearingsExchange.abi, address: contractId });
        //console.log(contract);
        contract.ContractSent().then(e => {
            showContractSection(e.args);
            contract.executeNext({gas:400000});
        });
        contract.PaymentReceived().then(e => showPaymentReceivedSection(e.args));
        contract.FineRequestSent().then(e => showFineRequestSentSection(e.args));
        contract.FinePayed().then(e => {
            showFinePayedSection(e.args);
            contract.executeNext({gas: 400000});
        });
        contract.ConfirmationSent().then(e => showConfirmationSentSection(e.args));
        contract.CancellationSent().then(e => showContractCancelledSection(e.args));
        contract.ProcessFinished().then(e => showProcessFinished(e.args));
    });

});

function setAddress(_address) {
    address = _address;
    web3.eth.defaultAccount = _address;
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

function showContractSection(args) {
    $('#incoming_contract_section').removeClass("hidden");
    $('#manufacturer_address').text(args.sender);
    $('#contract_address').text(contract.address);
    $('#data').text(args.text);
}

function sendSignedContract() {
    contract.signContract("signed contract", {gas:400000}).then(function(transaction) {
        $('#incoming_contract_section textarea, #incoming_contract_section button').prop("disabled", true)
    })
}

function sendBearings() {
    contract.executeNext({gas:400000}).then(function(transaction) {
      $('#send_bearings').prop('disabled', true);
    });
}

function showPaymentReceivedSection(args) {
    $('#payment_received_section').removeClass('hidden');
    $('#send_bearings_section').removeClass('hidden');
}

function showConfirmationSentSection() {
    $('#confirmation_sent_section').removeClass('hidden');
}

var fine;
function showFineRequestSentSection(args) {
    $('#fine_request_amount').text(args.percentage);
    fine = args.percentage;
    $('#fine_request_sent_section').removeClass('hidden');
}

function sendFee() {
    console.log("sending fee", fine);
    // use valueOf() because of a bug in web3 0.19
    // https://github.com/ethereum/web3.js/issues/925
    contract.payFine(fine.valueOf(), {gas: 400000}).then(transaction => {
        console.log("fee sent");
        $('#send_fee').prop('disabled', true);
    });
}

function showFinePayedSection() {
    $('#fine_payed_section').removeClass('hidden');
}

function showContractCancelledSection() {
    $('#contract_cancelled_section').removeClass('hidden');
}

function showProcessFinished() {
    $('#process_finished_section').removeClass('hidden');
}
