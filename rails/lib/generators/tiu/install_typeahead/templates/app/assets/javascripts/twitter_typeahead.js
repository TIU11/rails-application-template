// Assumes twitter-typeahead-rails
// TODO:
// * extract view helper for DRYness and to guarantee view structure (e.g. class names)
//
// Expected View Structure:
// <div class="autocomplete-list" data-tt-options="{ [your input-specific option overrides here] }">
//   <%= text_field_tag :user_id, nil, class: 'assignee-typeahead form-control', placeholder: 'Search by Name', autocomplete: 'off' %>
//   <ul class="autocomplete-selections">
//     <li class="item">
//       <span class="item-text">John Smith</span>
//       <i class="fa fa-times"></i>
//       <input type="hidden" name="..." value="...">
//     </li>
//   </ul>
// </div>
$(function() {

  // Apply the selection, then clear the input for the next query
  // May select a match via keyboard or mouse, or autocomplete the first match via <Tab>.
  $(document).on('typeahead:selected typeahead:autocompleted', '.autocomplete-list .tt-input', function(event, suggestion, dataset_name) {
    var container = $(this).closest('.autocomplete-list');
    selectItem(suggestion, container);
    $(this).typeahead('val', ''); // clear input
  });

  // Prevent form submission on <Enter>, unless the input is empty.
  // This saves users from submitting when they accept a hinted value.
  // Instead emits a <Tab> key to autocomplete to the first match, which is probably what we wanted.
  $(document).on('keypress', '.autocomplete-list .tt-input', function(event) {
    if( event.which == 13 && $(this).val() !== '') {
      $(this).trigger(jQuery.Event('keydown', {which: 9, keyCode: 9}));
      event.preventDefault();
    }
  });

  // Select this item, appending it to .autocomplete-selections
  // Appended markup duplicates that of AutocompleteHelper::autocomplete_selections
  function selectItem(item, container) {
    var options = $(container).data('tt-options');
    if (inSelection(item[options.display_field], container, true)) { return; } // cannot select/add duplicates to list
    var li = $('<li class="item"></li>')
    .append('<span class="item-text">' + item[options.display_field] + '</span>')
    .append('<i class="pull-right fa fa-times" title="Click to remove"></i>')
    .append('<input type="hidden" name="' + options.input_name + '" value="' + item[options.input_value_field] + '">');

    $(container).find('.autocomplete-selections').append(li);
    animateItem(li);
  }

  // @return true if topic in the list
  function inSelection(item_text, container, animate) {
    var matches = $(container).find('ul.autocomplete-selections > li.item > .item-text').filter(function() {
      return $(this).text().toLowerCase() === item_text.toLowerCase();
    });
    if( matches.length > 0 && animate) {
      animateItem(matches);
    }
    return matches.length > 0;
  }

  function animateItem(element) {
      $(element).animate({'font-size': '110%'}, 300)
                .animate({'font-size': '100%'}, 300, function complete() {
                  $(this).removeAttr('style');
                });
  }

  // Un-select Item
  $(document).on('click', '.autocomplete-list ul.autocomplete-selections .fa.fa-times', function(event) {
    $(this).parent('li.item').remove(); //remove li
  });

  // TwitterTypeahead.initialize('input.user-autocomplete', {url: 'options.json', key: 'name'})
  //
  // After initialization, active options are written to the container:
  //    `<div class="autocomplete-list" data-tt-options="{name: 'users', ...}">`
  window.TwitterTypeahead = (function() {
    var default_options = {
      display_field: 'name',
      input_value_field: 'id',
      ttl: 1000 // cache in local storage for 1 second
    };
    var typeaheads = [];

    // Public methods
    return {
      // options:
      // * name: 'users'            // name of this autocomplete
      // * url: '/users.json'       // where to fetch autocomplete values
      // * display_field: 'name'    // attribute name to read from fetched autocomplete results
      // * input_value_field: 'id'
      // * input_name: 'user_ids[]'
      // * ttl: 6000                // milliseconds until cached autocomplete values expire
      initialize: function(input, options) {
        $(input).each(function() {
          var $container = $(this).closest('.autocomplete-list');

          // Apply options in order of precedence. Later options override earlier.
          options = _.extend(
            {}, // extend new object for this TT instance
            default_options,
            options,
            {placeholder: $(this).attr('placeholder')},
            $container.data('tt-options')
          );
          // Save options, where they will be accessed in event handlers
          $container.data('tt-options', options);

          var engine = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.obj.whitespace(options.display_field),
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            prefetch: {
              url: options.url,
              ttl: options.ttl,
              ajax: {
                // While waiting for preload, disable .tt-input and show a spinner.
                // TODO: consider updating after https://github.com/twitter/typeahead.js/issues/166
                beforeSend: function(xhr) {
                  setTimeout(function() {
                    $(input).prop('disabled', true);
                    $(input).attr('placeholder', 'Loading...');
                    $container.find('.form-control-feedback').removeClass('hidden');
                  }, 0);
                },
                // After preload, re-enable .tt-input and hide the spinner.
                complete: function(xhr) {
                  $(input).prop('disabled', false);
                  $(input).attr('placeholder', options.placeholder);
                  $container.find('.form-control-feedback').addClass('hidden');
                }
              }
            }
          });
          engine.initialize();

          $(input).typeahead(
            { highlight: true },
            { name: options.name,
              source: engine.ttAdapter(),
              displayKey: options.display_field
            }
          );
        });
      }, // initialize()
      // return all instances
      all: function() {
        throw("Not Implemented");
        return typeaheads;
      } // all()
    };
  })();

});
