import axios from "axios";

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL || "http://localhost:3000/api";

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
  withCredentials: true,
});

export const sourceTextsAPI = {
  getAll: () => api.get("/source_texts"),
  getById: (id) => api.get(`/source_texts/${id}`),
  importFromGutenberg: (gutenbergId) =>
    api.post("/source_texts/import_from_gutenberg", {
      gutenberg_id: gutenbergId,
    }),
};

export const poemsAPI = {
  getAll: () => api.get("/poems"),
  getById: (id) => api.get(`/poems/${id}`),
  generateCutUp: (sourceTextId, options) =>
    api.post(`/source_texts/${sourceTextId}/generate_cut_up`, options),
  generateErasure: (sourceTextId, options) =>
    api.post(`/source_texts/${sourceTextId}/generate_erasure`, options),
  generateSnowball: (sourceTextId, options) =>
    api.post(`/source_texts/${sourceTextId}/generate_snowball`, options),
  generateMesostic: (sourceTextId, options) =>
    api.post(`/source_texts/${sourceTextId}/generate_mesostic`, options),
};

export const authAPI = {
  register: (userData) => api.post("/users", userData),
  login: (credentials) => api.post("/users/sign_in", credentials),
  logout: () => api.delete("/users/sign_out"),
  getCurrentUser: () => api.get("/user/current"),
};

export default api;
