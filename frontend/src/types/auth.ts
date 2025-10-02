// Interfaces para autenticação
export interface User {
  id: string;
  email: string;
  name: string;
  role?: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterCredentials {
  name: string;
  email: string;
  password: string;
  cpf: string;
}

// Interfaces para requisições da API (mantidas para compatibilidade futura)
export interface LoginRequest {
  email: string;
  password: string;
}

export interface CreateUserRequest {
  cpf: string;
  name: string;
  email: string;
  password: string;
  role?: string;
  street?: string;
  number?: number;
  neighborhood?: string;
  complement?: string;
  city?: string;
  state?: string;
  zipCode?: string;
}

export interface AuthResponse {
  token: string;
  user: User;
}

export interface ApiError {
  message: string;
  status: number;
}