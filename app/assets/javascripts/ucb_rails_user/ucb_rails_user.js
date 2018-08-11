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

$( window ).on("load", function() {
  // the datatable calling was failing intermittently, but adding the timeout
  // seemed to fix it, so ¯\_(ツ)_/¯
  window.setTimeout(addDatatablesToUsersTable, 100)

  $('.user-search-form').on('submit', function() {
    $('.search-results').hide()
    $('.ucb-rails-user-loader').show()
  })
})

