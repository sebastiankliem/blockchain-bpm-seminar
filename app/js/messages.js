whenEnvIsLoaded(function() {
    Manufacturer.ContractSent().then(function(e) {
        
    });

    Supplier.ContractReceived().then(function(e) {
        console.log(e.args);
        showContractSection(e.args);
    });

    Manufacturer.SignedContractReceived().then(function(e) {
        console.log(e.args);
        showSignedContractSection(e.args);
    });

    $('#send_contract').on('click', function(e) {
        e.preventDefault();
        sendContract();
    });

    $('#sign_contract').on('click', function(e) {
        e.preventDefault();
        sendSignedContract();
    });
});

function sendContract() {
    let contractText = $('#contract_text').val();
    Manufacturer.sendContract(Supplier.address, JSON.stringify({text: contractText, signed: false})).then(function(transaction) {
        $('#manufacturer>.section:last textarea, #manufacturer>.section:last button').prop("disabled", true)
        $('#manufacturer>.section:last').append('<div class="status">sent to supplier</div>');
    })
}

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
    $('#supplier__manufacturer_address').text(args.manufacturerAddress);
    $('#supplier__data').text(JSON.stringify(JSON.parse(args.data), null, 2));
}

function showSignedContractSection(args) {
    $('#manufacturer>.section:first').removeClass("hidden");
    $('#manufacturer__signer').text(args.supplierAddress);
    $('#manufacturer__data').text(JSON.stringify(JSON.parse(args.data), null, 2));
}