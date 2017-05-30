whenEnvIsLoaded(function() {
    $("#sendA").on("click", function(e) {
        Choreo.send($("#inputA").val()).then(function(transaction) {
            $("#inputA").val("");
        });
    });
    $("#sendB").on("click", function(e) {
        let hash = $("#chat>.msg-a:first-child").data("hash");
        Choreo.sendAnswer(hash, $("#inputB").val()).then(function(transaction) {
            $("#inputB").val("");
        });
    });

    Choreo.NewMessage().then(function(event) {
        handleNewMessage(event);
    });
    Choreo.MessageAnswered().then(function(event) {
        handleMessageAnswered(event);
    });
});

function handleNewMessage(event) {
    // console.log("New Message");
    // console.log(event);
    let newMessage = newMessageDiv("sender", event.args.message);
    newMessage.dataset.hash = event.args.messageHash;
    $("#chat").prepend(newMessage);
}
function handleMessageAnswered(event) {
    // console.log("Message Answered");
    // console.log(event);
    $("#chat").prepend(newMessageDiv("receiver", event.args.answer));
}

function newMessageDiv(type, message) {
    let div = document.createElement("div");
    div.classList.add("msg");
    div.classList.add(type == "sender" ? "msg-a" : "msg-b");
    div.innerHTML = message;
    return div;
}