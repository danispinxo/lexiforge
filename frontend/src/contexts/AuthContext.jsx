import { useState, useEffect } from "react";
import { AuthContext } from "./AuthContext";
import { authAPI } from "../services/api";

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAuthStatus();
  }, []);

  const checkAuthStatus = async () => {
    try {
      const response = await authAPI.getCurrentUser();
      if (response.data.success) setUser(response.data.user);
    } catch {
      setUser(null);
    } finally {
      setLoading(false);
    }
  };

  const login = async (credentials) => {
    try {
      const response = await authAPI.login(credentials);
      if (response.data.success) {
        setUser(response.data.user);
        return { success: true };
      } else {
        return {
          success: false,
          message: response.data.message || "Login failed",
        };
      }
    } catch (error) {
      return {
        success: false,
        message: error.response?.data?.message || "Login failed",
      };
    }
  };

  const register = async (userData) => {
    try {
      const response = await authAPI.register(userData);

      if (response.data.success) {
        setUser(response.data.user);
        return { success: true };
      } else {
        return {
          success: false,
          message:
            response.data.message || response.data.errors?.join(", ") || "Registration failed",
        };
      }
    } catch (error) {
      return {
        success: false,
        message:
          error.response?.data?.message ||
          error.response?.data?.errors?.join(", ") ||
          "Registration failed",
      };
    }
  };

  const logout = async () => {
    try {
      await authAPI.logout();
      setUser(null);
      return { success: true };
    } catch {
      setUser(null);
      return { success: true };
    }
  };

  const updateUser = (userData) => setUser(userData);

  const value = {
    user,
    loading,
    login,
    register,
    logout,
    updateUser,
    isAuthenticated: !!user,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
