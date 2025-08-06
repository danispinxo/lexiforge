import axios from "axios";

const API_BASE_URL = "http://localhost:3000/api";

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
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
  create: (poemData) => api.post("/poems", poemData),
  generateCutUp: (sourceTextId, options = {}) =>
    api.post(`/source_texts/${sourceTextId}/generate_cut_up`, options),
  generateErasure: (sourceTextId, options = {}) =>
    api.post(`/source_texts/${sourceTextId}/generate_erasure`, options),
  generateSnowball: (sourceTextId, options = {}) =>
    api.post(`/source_texts/${sourceTextId}/generate_snowball`, options),
};

export default api;
