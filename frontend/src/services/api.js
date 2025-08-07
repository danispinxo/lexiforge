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
  generateCutUp: (sourceTextId) =>
    api.post(`/source_texts/${sourceTextId}/generate_cut_up`),
  generateErasure: (sourceTextId) =>
    api.post(`/source_texts/${sourceTextId}/generate_erasure`),
  generateSnowball: (sourceTextId) =>
    api.post(`/source_texts/${sourceTextId}/generate_snowball`),
  generateMesostic: (sourceTextId) =>
    api.post(`/source_texts/${sourceTextId}/generate_mesostic`),
};

export const authAPI = {
  register: (userData) => api.post("/users", userData),
  login: (credentials) => api.post("/users/sign_in", credentials),
  logout: () => api.delete("/users/sign_out"),
  getCurrentUser: () => api.get("/current_user"),
};

export default api;
