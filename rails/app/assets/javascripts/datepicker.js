$(function() {
  // Initialize Bootstrap Datepicker datepickers
  // (https://github.com/eternicode/bootstrap-datepicker)
  $("[data-behavior~='datepicker']").datepicker({
    format: "yyyy-mm-dd",
    autoclose: true,
    todayHighlight: true
  });
});
