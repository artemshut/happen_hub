import "@hotwired/turbo-rails"
import "controllers"
import "trix"
import "@rails/actiontext"

document.addEventListener('turbo:load', function () {
  var dateInputs = document.querySelectorAll('.datepicker');

  if (dateInputs.length > 0) {
    dateInputs.forEach(function (input) {
      flatpickr(input, {
        enableTime: true,
        dateFormat: "Y-m-d H:i",
      });
    });
  }
});


document.addEventListener('turbo:load', function() {
  var calendarEl = document.getElementById('calendar');

  if (calendarEl) {
    var calendar = new FullCalendar.Calendar(calendarEl, {
      plugins: [FullCalendar.globalPlugins[7], FullCalendar.globalPlugins[6]],
      initialView: 'dayGridMonth',
      events: '/api/events', // Adjust this endpoint as needed
      editable: true,        // Enable drag-and-drop
      selectable: true,      // Allow date selection
      eventDidMount: (info) => {
        info.el.style.backgroundColor = info.event.extendedProps.color;
      },
      eventClick: function(info) {
        window.location.href = info.event.url;
      },
    });

    calendar.render();
  }
});
