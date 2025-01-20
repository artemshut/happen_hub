# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "flatpickr" # @4.6.13
pin "tui-calendar" # @1.15.3
pin "tui-code-snippet" # @1.5.2
pin "tui-date-picker" # @4.3.3
pin "tui-time-picker" # @2.1.6
