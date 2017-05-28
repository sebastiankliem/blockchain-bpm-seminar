$(function() {
  console.log("hallo welt");
  console.log(MyStack);
  showStack();

  $('#button__add_number').on('click', () => {
    addToStack($('#input__add_number').val());
  });
  $('#button__pop_stack').on('click', () => {
    popStack();
  });
});

function showStack() {
  $('#stack_value').text('');
  MyStack.getAll().then(function(stackValue) {
    console.log(stackValue);
    stackValue.forEach(function(element) {
      $('#stack_value').prepend(element + '<br>');
    }, this);
  });
}

function addToStack(number) {
  MyStack.push(number).then((transaction) => {
    showStack();
    $('#input__add_number').val('');
  });
}

function popStack() {
  MyStack.pop().then((transaction) => {
    showStack();
  });
}