import api from './api';
import type {
  AllocateGoalAmountPayload,
  BankAccount,
  CreateBankAccountPayload,
  UpdateBankAccountPayload,
  CreateCategoryPayload,
  UpdateCategoryPayload,
  CreateFinancialGoalPayload,
  UpdateFinancialGoalPayload,
  CreateTransactionPayload,
  UpdateTransactionPayload,
  Transaction,
  Category,
  DashboardOverview,
  FinancialGoal,
  GoalAllocationOverview,
  DashboardRangeKey,
} from '../types/finance';

export const financeService = {
  listBankAccounts: async (): Promise<BankAccount[]> => {
    const response = await api.get<BankAccount[]>('/finance/bank-accounts');
    return response.data;
  },

  createBankAccount: async (payload: CreateBankAccountPayload): Promise<BankAccount> => {
    const response = await api.post<BankAccount>('/finance/bank-accounts', payload);
    return response.data;
  },

  updateBankAccount: async (id: string, payload: UpdateBankAccountPayload): Promise<BankAccount> => {
    const response = await api.put<BankAccount>(`/finance/bank-accounts/${id}`, payload);
    return response.data;
  },

  deleteBankAccount: async (id: string): Promise<void> => {
    await api.delete(`/finance/bank-accounts/${id}`);
  },

  listCategories: async (): Promise<Category[]> => {
    const response = await api.get<Category[]>('/finance/categories');
    return response.data;
  },

  createCategory: async (payload: CreateCategoryPayload): Promise<Category> => {
    const response = await api.post<Category>('/finance/categories', payload);
    return response.data;
  },

  updateCategory: async (id: string, payload: UpdateCategoryPayload): Promise<Category> => {
    const response = await api.put<Category>(`/finance/categories/${id}`, payload);
    return response.data;
  },

  deleteCategory: async (id: string): Promise<void> => {
    await api.delete(`/finance/categories/${id}`);
  },

  listTransactions: async (): Promise<Transaction[]> => {
    const response = await api.get<Transaction[]>('/finance/transactions');
    return response.data;
  },

  createTransaction: async (payload: CreateTransactionPayload): Promise<Transaction> => {
    const response = await api.post<Transaction>('/finance/transactions', payload);
    return response.data;
  },

  updateTransaction: async (id: string, payload: UpdateTransactionPayload): Promise<Transaction> => {
    const response = await api.put<Transaction>(`/finance/transactions/${id}`, payload);
    return response.data;
  },

  deleteTransaction: async (id: string): Promise<void> => {
    await api.delete(`/finance/transactions/${id}`);
  },

  listFinancialGoals: async (): Promise<FinancialGoal[]> => {
    const response = await api.get<FinancialGoal[]>('/finance/goals');
    return response.data;
  },

  createFinancialGoal: async (payload: CreateFinancialGoalPayload): Promise<FinancialGoal> => {
    const response = await api.post<FinancialGoal>('/finance/goals', payload);
    return response.data;
  },

  updateFinancialGoal: async (
    id: string,
    payload: UpdateFinancialGoalPayload
  ): Promise<FinancialGoal> => {
    const response = await api.put<FinancialGoal>(`/finance/goals/${id}`, payload);
    return response.data;
  },

  deleteFinancialGoal: async (id: string): Promise<void> => {
    await api.delete(`/finance/goals/${id}`);
  },

  getDashboardOverview: async (params?: {
    year?: number;
    month?: number;
    range?: DashboardRangeKey;
  }): Promise<DashboardOverview> => {
    const response = await api.get<DashboardOverview>('/finance/dashboard/overview', {
      params,
    });
    return response.data;
  },

  getGoalAllocationOverview: async (
    range?: DashboardRangeKey
  ): Promise<GoalAllocationOverview> => {
    const response = await api.get<GoalAllocationOverview>('/finance/goals/allocation', {
      params: range ? { range } : undefined,
    });
    return response.data;
  },

  allocateGoalAmount: async (
    goalId: string,
    payload: AllocateGoalAmountPayload
  ): Promise<FinancialGoal> => {
    const response = await api.post<FinancialGoal>(`/finance/goals/${goalId}/allocate`, payload);
    return response.data;
  },
};

export default financeService;
