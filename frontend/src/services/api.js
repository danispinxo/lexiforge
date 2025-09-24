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
  getAll: (page = 1, perPage = 10, options = {}) => {
    const params = {
      page,
      per_page: perPage,
      ...(options.search && { search: options.search }),
      ...(options.sortBy && { sort_by: options.sortBy }),
      ...(options.sortDirection && { sort_direction: options.sortDirection }),
    };
    return api.get("/source_texts", { params });
  },
  getMine: (page = 1, perPage = 10, options = {}) => {
    const params = {
      page,
      per_page: perPage,
      ...(options.search && { search: options.search }),
      ...(options.sortBy && { sort_by: options.sortBy }),
      ...(options.sortDirection && { sort_direction: options.sortDirection }),
    };
    return api.get("/source_texts/my_source_texts", { params });
  },
  getById: (id) => api.get(`/source_texts/${id}`),
  importFromGutenberg: (gutenbergId, isPublic = true) =>
    api.post("/source_texts/import_from_gutenberg", {
      gutenberg_id: gutenbergId,
      is_public: isPublic,
    }),
  createCustom: (title, content) =>
    api.post("/source_texts/create_custom", {
      title: title,
      content: content,
    }),
  download: (id) => api.get(`/source_texts/${id}/download`, { responseType: "blob" }),
};

export const poemsAPI = {
  getAll: (page = 1, perPage = 10, options = {}) => {
    const params = {
      page,
      per_page: perPage,
      ...(options.search && { search: options.search }),
      ...(options.sortBy && { sort_by: options.sortBy }),
      ...(options.sortDirection && { sort_direction: options.sortDirection }),
    };
    return api.get("/poems", { params });
  },
  getMine: (page = 1, perPage = 10, options = {}) => {
    const params = {
      page,
      per_page: perPage,
      ...(options.search && { search: options.search }),
      ...(options.sortBy && { sort_by: options.sortBy }),
      ...(options.sortDirection && { sort_direction: options.sortDirection }),
    };
    return api.get("/poems/my_poems", { params });
  },
  getById: (id) => api.get(`/poems/${id}`),
  generatePoem: (sourceTextId, options) =>
    api.post(`/source_texts/${sourceTextId}/generate_poem`, options),
  update: (id, poemData) => api.put(`/poems/${id}`, { poem: poemData }),
  delete: (id) => api.delete(`/poems/${id}`),
  download: (id) => api.get(`/poems/${id}/download`, { responseType: "blob" }),
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
