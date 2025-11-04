import { Component, type ErrorInfo, type ReactNode } from 'react';

interface ChartErrorBoundaryProps {
  fallback?: ReactNode;
  children: ReactNode;
}

interface ChartErrorBoundaryState {
  hasError: boolean;
  message?: string;
}

class ChartErrorBoundary extends Component<ChartErrorBoundaryProps, ChartErrorBoundaryState> {
  public state: ChartErrorBoundaryState = { hasError: false, message: undefined };

  static getDerivedStateFromError(error: Error): ChartErrorBoundaryState {
    return { hasError: true, message: error.message };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error('Erro ao renderizar gráfico:', error, info);
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback ?? (
          <div className="mt-4 rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
            <p>Não foi possível carregar este gráfico. Recarregue a página ou tente novamente mais tarde.</p>
            {this.state.message ? (
              <p className="mt-1 text-xs text-red-500/80">Detalhes técnicos: {this.state.message}</p>
            ) : null}
          </div>
        )
      );
    }

    return this.props.children;
  }
}

export default ChartErrorBoundary;
