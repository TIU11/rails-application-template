$(function() {
  /*
   * Date Picker
   */
  $("[data-behavior~='datepicker']").datepicker({
    format: "yyyy-mm-dd",
    autoclose: true,
    todayHighlight: true
  });
});
