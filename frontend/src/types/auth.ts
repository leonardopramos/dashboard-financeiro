// Interfaces para autenticação
export interface User {
  id: string;
  cpf?: string;
  name: string;
  email: string;
  role?: string;
  street?: string;
  number?: number;
  neighborhood?: string;
  complement?: string;
  city?: string;
  state?: string;
  zipCode?: string;
  active?: boolean;
  emailVerified?: boolean;
  registeredAt?: string;
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
  role?: string;
  street?: string;
  number?: number;
  neighborhood?: string;
  complement?: string;
  city?: string;
  state?: string;
  zipCode?: string;
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

export interface UpdateUserRequest {
  cpf: string;
  name: string;
  street?: string;
  number?: number;
  neighborhood?: string;
  complement?: string;
  city?: string;
  state?: string;
  zipCode?: string;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  tokenType: string;
  user: User;
}

export interface ApiError {
  message: string;
  status: number;
}

export interface VerifyEmailPayload {
  email: string;
  code: string;
}

export interface ResendVerificationPayload {
  email: string;
}
