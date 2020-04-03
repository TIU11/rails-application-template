document.addEventListener("DOMContentLoaded", function(event) {

  // Works with `link_to_add_fields` view helper.
  function addNestedFields(event) {
    var unique_id = new Date().getTime();
    var regexp = new RegExp($(this).data('id'), 'g');
    var fields_html = $(this).data('fields').replace(regexp, unique_id);

    $(this).before(fields_html); // append fields
    event.preventDefault(); // don't follow the link
  }

  // Works with `link_to_remove_fields` view helper.
  function removeNestedFields(event) {
    var container = $(this).closest('.nested-fields, .fields');
    container.find('input[type=hidden][id$=_destroy]').val('1'); // mark for delete
    container.hide();
    event.preventDefault(); // don't follow the link
  }

  // Bind 'Add' Listener
  $('form').on('click', '.add-nested-fields', addNestedFields);

  // Bind 'Remove' Listener
  // TODO: handle keyboard navigation
  // * keypress ok?
  // * event.key == 'Enter' vs event.which
  // * add guard clause
  //   return if (event.type == 'keypress' && event.key != 'Enter')
  $('form').on('click', '.remove-nested-fields', removeNestedFields);
});
