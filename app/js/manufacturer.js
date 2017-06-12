var address;
var contractId;

whenEnvIsLoaded(function() {
    address = web3.eth.accounts[0]

    $('#send_contract').on('click', function(e) {
        e.preventDefault();
        sendContract();
    });
});

function sendContract() {
    let supplier_address = $('#supplier_address').val();
    this.BearingsExchange.deploy([address, supplier_address], {}).then(function(bearingsexchange) {
        var transaction = web3.eth.sendTransaction({to: supplier_address, data: bearingsexchange.address}); // web3.toAscii(data)});
        contractId = bearingsexchange.address;
        //Supplier.ContractReceived().then(function(e) {x
        //    showContractSection(e.args);
        //});
        bearingsexchange.sendContract("Lorem Ipsum");
    });
}

function showSignedContractSection(args) {
    $('#manufacturer>.section:first').removeClass("hidden");
    $('#manufacturer__signer').text(args.supplierAddress);
    $('#manufacturer__data').text(JSON.stringify(JSON.parse(args.data), null, 2));
}