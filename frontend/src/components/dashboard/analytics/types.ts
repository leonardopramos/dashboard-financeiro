export interface DailyFlowPoint {
  date: string;
  income: number;
  expense: number;
}

export interface AccountDistributionItem {
  type: string;
  label: string;
  balance: number;
}

export interface GoalSnapshotStats {
  total: number;
  achieved: number;
  exceeded: number;
  expired: number;
}
