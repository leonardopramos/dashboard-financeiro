export type AccountType = 'CHECKING' | 'SAVINGS' | 'INVESTMENT' | 'CREDIT_CARD';

export interface BankAccount {
  id: string;
  userId: string;
  institutionName: string;
  branchNumber: string;
  accountNumber: string;
  accountDigit?: string;
  accountType: AccountType;
  nickname?: string;
  currentBalance: number;
  createdAt: string;
  updatedAt: string;
}

export type DashboardRangeKey = '12M' | '6M' | '1M' | '1W';

export interface CreateBankAccountPayload {
  institutionName: string;
  branchNumber: string;
  accountNumber: string;
  accountDigit?: string;
  accountType: AccountType;
  nickname?: string;
  initialBalance?: number;
}

export interface UpdateBankAccountPayload {
  institutionName: string;
  branchNumber: string;
  accountNumber: string;
  accountDigit?: string;
  accountType: AccountType;
  nickname?: string;
}

export type TransactionType = 'INCOME' | 'EXPENSE' | 'TRANSFER_IN' | 'TRANSFER_OUT';

export interface Transaction {
  id: string;
  userId: string;
  bankAccountId: string;
  type: TransactionType;
  amount: number;
  transactionDate: string;
  description: string;
  category?: CategorySummary;
  notes?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CategorySummary {
  id: string;
  name: string;
  type: string;
  color?: string;
  icon?: string;
}

export interface CreateTransactionPayload {
  bankAccountId: string;
  type: TransactionType;
  amount: number;
  transactionDate: string;
  description: string;
  categoryId?: string;
  notes?: string;
}

export interface UpdateTransactionPayload {
  bankAccountId: string;
  type: TransactionType;
  amount: number;
  transactionDate: string;
  description: string;
  categoryId?: string;
  notes?: string;
}

export type CategoryType = 'INCOME' | 'EXPENSE' | 'TRANSFER';

export interface CreateCategoryPayload {
  name: string;
  type: CategoryType;
  color?: string;
  icon?: string;
}

export interface UpdateCategoryPayload {
  name: string;
  type: CategoryType;
  color?: string;
  icon?: string;
  active: boolean;
}

export interface Category {
  id: string;
  userId: string;
  name: string;
  type: CategoryType;
  color?: string;
  icon?: string;
  active: boolean;
  createdAt: string;
  updatedAt: string;
}

export type GoalType = 'SAVINGS' | 'EXPENSE_LIMIT';

export type GoalStatus = 'IN_PROGRESS' | 'ACHIEVED' | 'EXCEEDED' | 'EXPIRED';

export interface FinancialGoal {
  id: string;
  userId: string;
  name: string;
  type: GoalType;
  category?: Category;
  targetAmount: number;
  currentAmount: number;
  startDate: string;
  endDate?: string;
  status: GoalStatus;
  description?: string;
  active: boolean;
  notifyOnAchieve: boolean;
  notifyOnExceed: boolean;
  achievedAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateFinancialGoalPayload {
  name: string;
  type: GoalType;
  categoryId?: string;
  targetAmount: number;
  startDate: string;
  endDate?: string;
  description?: string;
  notifyOnAchieve: boolean;
  notifyOnExceed: boolean;
}

export interface UpdateFinancialGoalPayload {
  name: string;
  type: GoalType;
  categoryId?: string;
  targetAmount: number;
  startDate: string;
  endDate?: string;
  description?: string;
  notifyOnAchieve: boolean;
  notifyOnExceed: boolean;
  active: boolean;
}

export interface DashboardOverview {
  timeRange?: {
    startDate: string;
    endDate: string;
    label?: string;
  } | null;
  appliedRange?: DashboardRangeKey | null;
  period?: {
    year: number;
    month: number;
  };
  totalIncome: number;
  totalExpenses: number;
  netBalance: number;
  totalBalance: number;
  categoryBreakdown: CategoryAggregation[];
  monthlyTrend: MonthlyTrendPoint[];
  goals: GoalsSnapshot;
}

export interface CategoryAggregation {
  categoryId: string;
  name: string;
  type: string;
  color?: string;
  totalIncome: number;
  totalExpenses: number;
}

export interface MonthlyTrendPoint {
  year: number;
  month: number;
  income: number;
  expenses: number;
  net: number;
}

export interface GoalsSnapshot {
  total: number;
  achieved: number;
  exceeded: number;
  expired: number;
  activeGoals: GoalProgress[];
}

export interface GoalProgress {
  id: string;
  name: string;
  status: GoalStatus;
  currentAmount: number;
  targetAmount: number;
  progressPercentage: number;
}

export interface GoalAllocationOverview {
  timeRange: {
    startDate: string;
    endDate: string;
    label?: string;
  };
  appliedRange: DashboardRangeKey;
  accumulated: number;
  allocated: number;
  available: number;
  goals: GoalAllocationItem[];
}

export interface GoalAllocationItem {
  goalId: string;
  name: string;
  status: GoalStatus;
  targetAmount: number;
  currentAmount: number;
  remainingAmount: number;
  endDate?: string;
}

export interface AllocateGoalAmountPayload {
  amount: number;
  description?: string;
}
