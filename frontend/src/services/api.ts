import axios from 'axios';
import type {
  AuthResponse,
  CreateUserRequest,
  LoginRequest,
  UpdateUserRequest,
  User,
  VerifyEmailPayload,
  ResendVerificationPayload,
} from '../types/auth';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8089/api';

export const ACCESS_TOKEN_KEY = 'dashboard-financeiro/accessToken';
export const REFRESH_TOKEN_KEY = 'dashboard-financeiro/refreshToken';
export const PENDING_EMAIL_KEY = 'dashboard-financeiro/pendingEmail';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 20000,
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem(ACCESS_TOKEN_KEY);
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem(ACCESS_TOKEN_KEY);
      localStorage.removeItem(REFRESH_TOKEN_KEY);
      if (!window.location.pathname.startsWith('/login')) {
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

export const authService = {
  login: async (credentials: LoginRequest): Promise<AuthResponse> => {
    const response = await api.post<AuthResponse>('/auth/login', credentials);
    return response.data;
  },

  refresh: async (refreshToken: string): Promise<AuthResponse> => {
    const response = await api.post<AuthResponse>('/auth/refresh', { refreshToken });
    return response.data;
  },

  register: async (userData: CreateUserRequest): Promise<User> => {
    const response = await api.post<User>('/users', userData);
    return response.data;
  },

  getCurrentUser: async (): Promise<User> => {
    const response = await api.get<User>('/auth/me');
    return response.data;
  },

  updateUser: async (userId: string, payload: UpdateUserRequest): Promise<User> => {
    const response = await api.put<User>(`/users/${userId}`, payload);
    return response.data;
  },

  logout: async (refreshToken?: string): Promise<void> => {
    if (refreshToken) {
      await api.post('/auth/logout', { refreshToken });
    }
  },

  verifyEmail: async (payload: VerifyEmailPayload): Promise<string> => {
    const response = await api.post<{ message: string }>('/auth/verify-email', payload);
    return response.data.message;
  },

  resendVerification: async (payload: ResendVerificationPayload): Promise<string> => {
    const response = await api.post<{ message: string }>('/auth/verify-email/resend', payload);
    return response.data.message;
  },
};

export default api;
