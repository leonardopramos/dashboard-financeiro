import React, { createContext, useContext, useState, useEffect, type ReactNode } from 'react';
import type { User, LoginCredentials, RegisterCredentials, AuthResponse, CreateUserRequest } from '../types/auth';
import { authService, ACCESS_TOKEN_KEY, REFRESH_TOKEN_KEY } from '../services/api';

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (credentials: LoginCredentials) => Promise<void>;
  register: (credentials: RegisterCredentials) => Promise<User>;
  refreshUser: () => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const isAuthenticated = !!user;

  useEffect(() => {
    const initializeAuth = async () => {
      const token = localStorage.getItem(ACCESS_TOKEN_KEY);
      const refreshToken = localStorage.getItem(REFRESH_TOKEN_KEY);
      if (token) {
        try {
          const userData = await authService.getCurrentUser();
          setUser(userData);
        } catch (error) {
          if (refreshToken) {
            try {
              const response = await authService.refresh(refreshToken);
              persistAuth(response);
            } catch (refreshError) {
              console.error('Failed to refresh session:', refreshError);
              clearAuthStorage();
            }
          } else {
            console.error('Failed to get user data:', error);
            clearAuthStorage();
          }
        }
      }
      setIsLoading(false);
    };

    initializeAuth();
  }, []);

  const persistAuth = (response: AuthResponse) => {
    localStorage.setItem(ACCESS_TOKEN_KEY, response.accessToken);
    localStorage.setItem(REFRESH_TOKEN_KEY, response.refreshToken);
    setUser(response.user);
  };

  const clearAuthStorage = () => {
    localStorage.removeItem(ACCESS_TOKEN_KEY);
    localStorage.removeItem(REFRESH_TOKEN_KEY);
    setUser(null);
  };

  const login = async (credentials: LoginCredentials) => {
    try {
      setIsLoading(true);
      const response = await authService.login(credentials);
      persistAuth(response);
    } catch (error) {
      console.error('Login failed:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const register = async (credentials: RegisterCredentials): Promise<User> => {
    try {
      setIsLoading(true);
      const sanitizedData: CreateUserRequest = {
        cpf: credentials.cpf.replace(/\D/g, ''),
        name: credentials.name,
        email: credentials.email,
        password: credentials.password,
        role: credentials.role,
        street: credentials.street,
        number: credentials.number,
        neighborhood: credentials.neighborhood,
        complement: credentials.complement,
        city: credentials.city,
        state: credentials.state,
        zipCode: credentials.zipCode?.replace(/\D/g, ''),
      };
      const createdUser = await authService.register(sanitizedData);
      return createdUser;
    } catch (error) {
      console.error('Registration failed:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    const refreshToken = localStorage.getItem(REFRESH_TOKEN_KEY);
    clearAuthStorage();
    authService.logout(refreshToken ?? undefined).catch(console.error);
  };

  const refreshUser = async () => {
    try {
      const userData = await authService.getCurrentUser();
      setUser(userData);
    } catch (error) {
      console.error('Failed to refresh user data:', error);
      throw error;
    }
  };

  const value: AuthContextType = {
    user,
    isLoading,
    isAuthenticated,
    login,
    register,
    refreshUser,
    logout,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
