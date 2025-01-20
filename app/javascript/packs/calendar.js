import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import interactionPlugin from '@fullcalendar/interaction';
import "flatpickr/dist/flatpickr.css";
import flatpickr from "flatpickr";

// Initialize FullCalendar
const initCalendar = () => {
  const calendarEl = document.getElementById('calendar');
  if (calendarEl) {
    const calendar = new Calendar(calendarEl, {
      plugins: [dayGridPlugin, interactionPlugin],
      initialView: 'dayGridMonth',
      events: '/api/events', // Fetch events from backend
      eventDidMount: (info) => {
        info.el.style.backgroundColor = info.event.extendedProps.color;
      },
      eventClick: function(info) {
        window.location.href = info.event.url;
      },
    });
    calendar.render();
  }
};

const initDatePicker = () => {
  flatpickr(".datepicker", {
    enableTime: true,
    dateFormat: "Y-m-d H:i",
  });
};

document.addEventListener('turbo:load', initDatePicker);
document.addEventListener('turbo:load', initCalendar);