import { createContext, useContext, useMemo, useState, type ReactNode } from 'react';
import type { DashboardRangeKey } from '../types/finance';

type RangeOption = {
  value: DashboardRangeKey;
  label: string;
};

const RANGE_OPTIONS: RangeOption[] = [
  { value: '12M', label: '12 meses' },
  { value: '6M', label: '6 meses' },
  { value: '1M', label: '30 dias' },
  { value: '1W', label: '7 dias' },
];

interface DashboardRangeContextValue {
  selectedRange: DashboardRangeKey;
  setSelectedRange: (value: DashboardRangeKey) => void;
  rangeOptions: RangeOption[];
}

const DashboardRangeContext = createContext<DashboardRangeContextValue | undefined>(undefined);

export const DashboardRangeProvider = ({ children }: { children: ReactNode }) => {
  const [selectedRange, setSelectedRange] = useState<DashboardRangeKey>('1M');

  const value = useMemo(
    () => ({
      selectedRange,
      setSelectedRange,
      rangeOptions: RANGE_OPTIONS,
    }),
    [selectedRange]
  );

  return <DashboardRangeContext.Provider value={value}>{children}</DashboardRangeContext.Provider>;
};

export const useDashboardRange = () => {
  const context = useContext(DashboardRangeContext);
  if (!context) {
    throw new Error('useDashboardRange deve ser utilizado dentro de um DashboardRangeProvider');
  }
  return context;
};

export const DASHBOARD_RANGE_OPTIONS = RANGE_OPTIONS;
