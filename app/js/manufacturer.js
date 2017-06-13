var address;
var contractId;
var contract;

whenEnvIsLoaded(function() {
    address = web3.eth.accounts[0]

    $('#send_contract').on('click', function(e) {
        e.preventDefault();
        sendContract();
    });
});

function sendContract() {
    let supplier_address = $('#supplier_address').val();
    console.log("sending contract");
    this.BearingsExchange.deploy([address, supplier_address, "init"], {}).then(function(bearingsexchange) {
        var transaction = web3.eth.sendTransaction({to: supplier_address, data: bearingsexchange.address}); // web3.toAscii(data)});
        contractId = bearingsexchange.address;
        console.log("new contract at", contractId);
        contract = bearingsexchange;
        bearingsexchange.sendContract("Lorem Ipsum");
        bearingsexchange.ContractSigned().then(e => showSignedContractSection(e.args));
    });
}

function showSignedContractSection(args) {
    $('#manufacturer>.section:first').removeClass("hidden");
    $('#manufacturer__signer').text(args.supplierAddress);
    $('#manufacturer__data').text(args.contractText);
}