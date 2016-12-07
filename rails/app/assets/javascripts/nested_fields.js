$(function() {

  // Works with `link_to_add_fields` view helper.
  function addNestedFields(event) {
    unique_id = new Date().getTime();
    regexp = new RegExp($(this).data('id'), 'g');
    fields_html = $(this).data('fields').replace(regexp, unique_id);

    $(this).before(fields_html); // append fields
    event.preventDefault();
  }

  // Bind 'Add' Listener
  $('form').on('click', '.add-nested-fields', addNestedFields);

});
