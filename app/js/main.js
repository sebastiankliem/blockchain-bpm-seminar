$(function() {
  // showStack();

  $('#button__add_number').on('click', () => {
    addToStack($('#input__add_number').val());
  });
  $('#button__pop_stack').on('click', () => {
    popStack();
  });
  MyStack.StackUpdate().then(function(event) {
    $('#stack_value').text('');
    event.args.newStack.forEach(function(element) {
      $('#stack_value').prepend(element + '<br>');
    }, this);
  });
});

function showStack() {
  $('#stack_value').text('');
  MyStack.getAll().then(function(stackValue) {
    stackValue.forEach(function(element) {
      $('#stack_value').prepend(element + '<br>');
      autofocus();
    }, this);
  });
}

function addToStack(number) {
  MyStack.push(number).then((transaction) => {
    // showStack();
    $('#input__add_number').val('');
    autofocus();
  });
}

function popStack() {
  MyStack.pop().then((transaction) => {
    // showStack();
    autofocus();
  });
}

function autofocus() {
  $('#input__add_number').focus();
}