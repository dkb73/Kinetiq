import axios from 'axios';

// Base URL for the API (nginx gateway)
// In production, use empty string for same-origin requests
// In dev mode, Vite will replace import.meta.env.DEV with false
const API_BASE_URL = import.meta.env.DEV === true ? 'http://localhost:8080' : '';

// Create axios instance with default config
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// API service functions
export const eventService = {
  // Get all events
  getAllEvents: async () => {
    try {
      const response = await api.get('/api/events');
      return response.data;
    } catch (error) {
      console.error('Error fetching events:', error);
      throw error;
    }
  },

  // Get event by ID
  getEventById: async (eventId) => {
    try {
      const response = await api.get(`/api/events/${eventId}`);
      return response.data;
    } catch (error) {
      console.error(`Error fetching event ${eventId}:`, error);
      throw error;
    }
  },
};

// Booking service functions
export const bookingService = {
  // Book a seat for an event
  bookSeat: async (eventId, userId, seatId) => {
    try {
      const response = await api.post('/api/book', {
        userId: userId,
        eventId: eventId,
        seatId: seatId
      });
      return response.data;
    } catch (error) {
      console.error('Error booking seat:', error);
      throw error;
    }
  },
};

export default api;
