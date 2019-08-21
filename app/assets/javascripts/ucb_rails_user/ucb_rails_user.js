// the users table has width set to auto, but the pagination tries to stretch to full width - this
// forces the pagination to match the table
var resizePagination = function () {
  //var paginationDiv = $('.dataTables_info').parents('.row').first()
  //paginationDiv.width($('.dataTable').width())
}

var addDatatablesToSearchResults = function () {
  $('.add-user-search-results-table').dataTable({
    searching: true,
    order: [[ 2, "asc" ]],
    columnDefs: [ {
      targets: 3,
      orderable: false
    }]
  })
  resizePagination()
}

var addDatatablesToUsersTable = function () {
  $('.ucb-rails-users-table').dataTable({
    searching: true,
    order: [[ 3, "asc" ]],
    columnDefs: [ {
      targets: [8, 9],
      orderable: false
    }],
  })
  var addNewHtml = '&nbsp;&nbsp;<a href="/admin/users/new" class="btn btn-primary">Add New</a>'
  $('#DataTables_Table_0_filter').append(addNewHtml)
}

var resetImpersonateButton = function() {
  var targetId = $('#ucb_rails_user_impersonation_target_id').val()
  if (targetId != null && targetId.toString().length > 0) {
    $('input[data-impersonate-button]').removeAttr('disabled')
  } else {
    $('input[data-impersonate-button]').attr('disabled', 'disabled')
  }
}

var clearImpersonateSelection = function() {
  $('#ucb_rails_user_impersonation_target_id').val('')
  resetImpersonateButton()
}

$( window ).on("load", function() {
  // the datatable calling was failing intermittently, but adding the timeout
  // seemed to fix it, so ¯\_(ツ)_/¯
  window.setTimeout(addDatatablesToUsersTable, 100)

  $('.user-search-form').on('submit', function() {
    $('.search-results').hide()
    $('.ucb-rails-user-loader').show()
  })

  var usersSource = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url: '/admin/users/impersonate_search?q=%QUERY',
      wildcard: '%QUERY'
    }
  });

  $('#ucb_rails_user_impersonation_target').typeahead(null, {
    name: 'users',
    source: usersSource,
    display: 'name',
    limit: 7, // any higher than this, and the results don't display properly
    templates: {
      empty: [
        '<div class="empty-message">',
        'No match found',
        '</div>'
      ].join('\n'),
      suggestion: function (data) {
        return '<div><strong>' + data.name + '</strong> (' + data.uid + ')</div>'
      }
    }
  });

  $('#ucb_rails_user_impersonation_target').keyup(function(event) {
    if ($(event.target).val().length == 0) {
      clearImpersonateSelection()
    }
  })

  $('#ucb_rails_user_impersonation_target').bind('typeahead:open', function(event, suggestion) {
    clearImpersonateSelection()
  })

  $('#ucb_rails_user_impersonation_target').bind('typeahead:select', function(event, suggestion) {
    $('#ucb_rails_user_impersonation_target_id').val(suggestion.id)
    resetImpersonateButton()
  })

})

