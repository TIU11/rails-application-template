# TODO: https://jira.tiu11.org/browse/EITAGBYS-32
# HOWTO: http://stackoverflow.com/a/25857095
ActionView::Base.field_error_proc = proc { |html_tag, _instance|
  "<div class=\"has-error\">#{html_tag}</div>".html_safe
}
