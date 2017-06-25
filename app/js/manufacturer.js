var address;
var contract;

whenEnvIsLoaded(function() {
    address = web3.eth.accounts[0]

    $('#my_address').text(address);
    getPossibleReceivers();

    $('#send_contract').on('click', function(e) {
        e.preventDefault();
        sendContract();
    });
    $('#send_payment').on('click', function(e) {
        e.preventDefault();
        sendPayment();
    });
    $('#send_analysis').on('click', function(e) {
        e.preventDefault();
        sendAnalysis();
    });
});

function getPossibleReceivers() {
    let select = $('#supplier_address');
    web3.eth.accounts.forEach(function(recvAddress, i) {
        if (recvAddress != address) {
            let opt = document.createElement('option');
            opt.value = recvAddress;
            opt.innerHTML = recvAddress;
            select.append(opt);
        }
    });
}

function sendContract() {
    let supplier_address = $('#supplier_address').val();
    console.log("sending contract");
    this.BearingsExchange.deploy([address, supplier_address, "Lorem Ipsum"], {}).then(function(bearingsexchange) {
        var transaction = web3.eth.sendTransaction({to: supplier_address, data: bearingsexchange.address});
        contract = bearingsexchange;
        console.log("new contract at", contract.address);
        contract.executeNext();
        contract.ContractSigned().then(e => showSignedContractSection(e.args));
        $('#send_contract, #supplier_address').prop("disabled", true);

        contract.BearingsSent().then(e => showBearingsSentSection(e.args));
        contract.ConfirmationSent().then(e => showConfirmationSentSection(e.args));
        contract.FineRequestSent().then(e => showFineRequestSentSection(e.args));
        contract.CancellationSent().then(e => showContractCancelledSection(e.args));
    });
}

function showSignedContractSection(args) {
    $('#contract_signed_section').removeClass("hidden");
    $('#manufacturer__signer').text(args.supplierAddress);

    $('#pay_supplier_section').removeClass('hidden');
}

function sendPayment() {
    contract.executeNext();
    $('#send_payment').prop("disabled", true);
}

function showBearingsSentSection() {
    $('#bearings_sent_section').removeClass('hidden');
}

function sendAnalysis() {
    contract.setFine($('#fine_amount').val()).then(function(transaction) {
        contract.executeNext();
    })
    $('#fine_amount, #send_analysis').prop("disabled", true);
}

function showConfirmationSentSection() {
    $('#confirmation_sent_section').removeClass('hidden');
}

function showFineRequestSentSection() {
    $('#fine_request_sent_section').removeClass('hidden');
}

function showContractCancelledSection() {
    $('#contract_cancelled_section').removeClass('hidden');
}

