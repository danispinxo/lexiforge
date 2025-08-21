import axios from "axios";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:3000/api";

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
  withCredentials: true,
});

api.interceptors.request.use(
  (config) => {
    if (import.meta.env.DEV) {
      console.log(`API Request: ${config.method?.toUpperCase()} ${config.url}`);
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (import.meta.env.DEV) {
      console.error("API Error:", error.response?.data || error.message);
    }
    return Promise.reject(error);
  }
);

export const sourceTextsAPI = {
  getAll: () => api.get("/source_texts"),
  getMine: () => api.get("/source_texts/my_source_texts"),
  getById: (id) => api.get(`/source_texts/${id}`),
  importFromGutenberg: (gutenbergId, isPublic = true) =>
    api.post("/source_texts/import_from_gutenberg", {
      gutenberg_id: gutenbergId,
      is_public: isPublic,
    }),
};

export const poemsAPI = {
  getAll: () => api.get("/poems"),
  getMine: () => api.get("/poems/my_poems"),
  getById: (id) => api.get(`/poems/${id}`),
  generatePoem: (sourceTextId, options) =>
    api.post(`/source_texts/${sourceTextId}/generate_poem`, options),
};

export const authAPI = {
  register: (userData) => api.post("/users", userData),
  login: (credentials) => api.post("/users/sign_in", credentials),
  logout: () => api.delete("/users/sign_out"),
  getCurrentUser: () => api.get("/user/current"),
  updateProfile: (profileData) => api.put("/user/profile", { user: profileData }),
  changePassword: (passwordData) => api.put("/user/password", { password_change: passwordData }),
};

export default api;
