interface DashboardMetricProps {
  title: string;
  subtitle: string;
  value: string;
  trend: string;
  variant: 'positive' | 'negative' | 'neutral';
}

const DashboardMetric = ({ title, subtitle, value, trend, variant }: DashboardMetricProps) => {
  const variantClasses =
    variant === 'positive'
      ? 'bg-green-50 border-green-200 text-green-700'
      : variant === 'negative'
      ? 'bg-red-50 border-red-200 text-red-600'
      : 'bg-orange-50/60 border-orange-100 text-orange-600';

  return (
    <div className="rounded-3xl border border-orange-100 bg-orange-50/40 p-5 shadow-inner shadow-orange-100">
      <p className="text-xs font-medium uppercase tracking-widest text-orange-400">{subtitle}</p>
      <h4 className="mt-1 text-lg font-semibold text-gray-900">{title}</h4>
      <p className="mt-3 text-2xl font-bold text-gray-900">{value}</p>
      <span className={`mt-4 inline-flex rounded-full px-3 py-1 text-xs font-semibold ${variantClasses}`}>
        {trend}
      </span>
    </div>
  );
};

export default DashboardMetric;
