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
        var transaction = web3.eth.sendTransaction({to: supplier_address, data: bearingsexchange.address}); // web3.toAscii(data)});
        contract = bearingsexchange;
        console.log("new contract at", contract.address);
        contract.executeNext();
        contract.ContractSigned().then(e => showSignedContractSection(e.args));
    });
}

function showSignedContractSection(args) {
    $($('#manufacturer>.section')[1]).removeClass("hidden");
    $('#manufacturer__signer').text(args.supplierAddress);
    $('#manufacturer__data').text(args.contractText);
}

function sendPayment() {
    let amount = parseInt($('#payment_amount').val());
    contract.setAmount(amount);
    contract.executeNext();
    contract.PaymentRejected().then(e => showPaymentRejectedSection());
    contract.PaymentOK().then(e => showPaymentOKSection());
}

function showPaymentRejectedSection() {
    $('#payment_rejected').removeClass("hidden");
}

function showPaymentOKSection() {
    $('#bearings_produced').removeClass("hidden");
}

