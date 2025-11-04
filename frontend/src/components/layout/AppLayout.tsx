import { Outlet, useLocation } from 'react-router-dom';
import { useEffect, useState } from 'react';
import Sidebar from './Sidebar';
import { useAuth } from '../../contexts/AuthContext';
import { LogOut } from 'lucide-react';
import {
  DashboardRangeProvider,
  useDashboardRange,
} from '../../contexts/DashboardRangeContext';

const RangeSelector = () => {
  const { selectedRange, setSelectedRange, rangeOptions } = useDashboardRange();
  const { pathname } = useLocation();

  const pathsWithoutRange = ['/app/contas', '/app/categorias', '/app/perfil'];

  if (pathsWithoutRange.some((path) => pathname.startsWith(path))) {
    return null;
  }

  return (
    <div className="mt-3 flex flex-wrap gap-2">
      <div className="flex rounded-full border border-orange-100 bg-orange-50 p-1">
        {rangeOptions.map((option) => {
          const isActive = selectedRange === option.value;
          return (
            <button
              key={option.value}
              type="button"
              onClick={() => setSelectedRange(option.value)}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition ${
                isActive
                  ? 'bg-orange-500 text-white shadow-sm shadow-orange-400/40'
                  : 'bg-white text-orange-500 hover:bg-orange-50'
              }`}
              aria-pressed={isActive}
            >
              {option.label}
            </button>
          );
        })}
      </div>
    </div>
  );
};

const AppLayoutContent = () => {
  const { user, logout } = useAuth();
  const firstName = user?.name?.split(' ')[0] ?? 'Usuário';
  const [isHeaderCondensed, setIsHeaderCondensed] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsHeaderCondensed(window.scrollY > 32);
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => {
      window.removeEventListener('scroll', handleScroll);
    };
  }, []);

  return (
    <div className="flex min-h-screen bg-gradient-to-br from-orange-50 via-white to-white">
      <Sidebar />
      <div className="flex flex-1 flex-col">
        <header
          className={`sticky top-0 z-40 border-b border-orange-100 bg-white/90 backdrop-blur-sm shadow-md shadow-orange-100/40 transition-all duration-300 ${
            isHeaderCondensed ? 'py-2' : 'py-6'
          }`}
        >
          <div className="flex flex-col gap-4 px-8 md:flex-row md:items-center md:justify-between">
            <div
              className={`transition-all duration-300 ${
                isHeaderCondensed ? 'pointer-events-none h-0 overflow-hidden opacity-0' : 'opacity-100'
              }`}
            >
              <p className="text-sm font-medium uppercase tracking-wider text-orange-400">
                Olá, {firstName} 👋
              </p>
              <h1 className="text-2xl font-semibold text-gray-900">
                Bem-vindo ao seu painel financeiro
              </h1>
            </div>

            <div className="flex flex-col items-start gap-3 md:flex-row md:items-center md:gap-6">
              <RangeSelector />

              <div
                className={`flex items-center gap-3 rounded-2xl border border-orange-100 bg-orange-50 px-4 py-2 shadow-sm transition-all duration-300 ${
                  isHeaderCondensed ? 'scale-90' : 'scale-100'
                }`}
              >
                <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-br from-orange-500 to-orange-400 text-lg font-bold text-white shadow-md">
                  {user?.name ? user.name.charAt(0).toUpperCase() : 'U'}
                </div>
                <div className="hidden text-right md:block">
                  <p className="text-sm font-semibold text-gray-900">{user?.name}</p>
                  <p className="text-xs text-gray-500">{user?.email}</p>
                </div>
                <button
                  type="button"
                  onClick={logout}
                  className="ml-2 inline-flex items-center gap-2 rounded-xl bg-white px-3 py-2 text-xs font-semibold text-red-500 shadow-inner shadow-orange-100 transition hover:bg-red-50 hover:text-red-600"
                >
                  <LogOut className="h-4 w-4" />
                  <span className="hidden sm:inline">Sair</span>
                </button>
              </div>
            </div>
          </div>
        </header>

        <main className="flex-1 overflow-y-auto px-6 py-8">
          <div className="mx-auto max-w-6xl">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
};

const AppLayout = () => (
  <DashboardRangeProvider>
    <AppLayoutContent />
  </DashboardRangeProvider>
);

export default AppLayout;
