import { LineChart } from '@mui/x-charts/LineChart';

export interface MonthlyMetricTrend {
  labels: string[];
  values: number[];
  firstValue: number | null;
  lastValue: number | null;
  totalChange: number;
  changePercentage: number | null;
}

interface MetricTrendChartProps {
  data: MonthlyMetricTrend | null;
  formatCurrency: (value?: number) => string;
  color: string;
  invertTrend?: boolean;
}

const MetricTrendChart = ({
  data,
  formatCurrency,
  color,
  invertTrend = false,
}: MetricTrendChartProps) => {
  if (!data || data.labels.length === 0 || data.values.length === 0) {
    return (
      <p className="mt-4 text-sm text-gray-500">
        Ainda não há dados suficientes para exibir a evolução deste indicador.
      </p>
    );
  }

  const { labels, values, totalChange, changePercentage } = data;
  const changeIsPositive = invertTrend ? totalChange <= 0 : totalChange >= 0;
  const formattedChange = formatCurrency(Math.abs(totalChange));
  const changePrefix = totalChange >= 0 ? '+' : '-';
  const directionSymbol = totalChange === 0 ? '' : totalChange > 0 ? '↑ ' : '↓ ';
  const formattedPercentage =
    changePercentage !== null
      ? `${changePrefix}${Math.abs(changePercentage).toFixed(1).replace('.', ',')}%`
      : null;
  const changeText =
    totalChange === 0
      ? ''
      : `${directionSymbol}${changePrefix}${formattedChange}${
          formattedPercentage ? ` (${formattedPercentage})` : ''
        }`;
  const changeColorClass = changeIsPositive ? 'text-green-600' : 'text-red-600';

  return (
    <div className="mt-4 space-y-4">
      {changeText && (
        <div className="flex justify-end">
          <span className={`text-sm font-medium ${changeColorClass}`}>{changeText}</span>
        </div>
      )}

      <LineChart
        height={280}
        xAxis={[
          {
            scaleType: 'point',
            data: labels,
          },
        ]}
        series={[
          {
            id: 'metric-trend',
            data: values,
            color,
            showMark: true,
            valueFormatter: (value: number | null) => formatCurrency(value ?? 0),
          },
        ]}
        yAxis={[
          {
            valueFormatter: (value: number) => formatCurrency(value),
            width: 96,
            tickLabelStyle: {
              fill: '#374151',
              fontSize: 12,
            },
          },
        ]}
        sx={{
          '& .MuiLineElement-root': {
            strokeWidth: 2.5,
          },
          '& .MuiChartsLegend-root': {
            display: 'none',
          },
        }}
      />
    </div>
  );
};

export default MetricTrendChart;
