%{ if flag?(:win32) %}
  require "./windows/uname"
%{ else %}
  require "./unix/uname"
%{ end %}
