import { useState } from 'react';
import { NavLink } from 'react-router-dom';
import type { LucideIcon } from 'lucide-react';
import {
  LineChart,
  UserRound,
  Landmark,
  ArrowRightLeft,
  Tags,
  Target,
  LogOut,
} from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';

interface NavItem {
  label: string;
  to: string;
  icon: LucideIcon;
}

const navItems: NavItem[] = [
  { label: 'Visão Geral', to: '/app', icon: LineChart },
  { label: 'Contas Bancárias', to: '/app/contas', icon: Landmark },
  { label: 'Categorias', to: '/app/categorias', icon: Tags },
  { label: 'Transações', to: '/app/transacoes', icon: ArrowRightLeft },
  { label: 'Metas', to: '/app/metas', icon: Target },
  { label: 'Perfil', to: '/app/perfil', icon: UserRound },
];

const Sidebar = () => {
  const [isExpanded, setIsExpanded] = useState(false);
  const { logout } = useAuth();

  return (
    <aside
      className={`group relative flex flex-col border-r border-orange-100 bg-white shadow-xl transition-all duration-300 ${
        isExpanded ? 'w-64' : 'w-20'
      }`}
      onMouseEnter={() => setIsExpanded(true)}
      onMouseLeave={() => setIsExpanded(false)}
    >
      <div
        className={`flex items-center py-6 transition-all duration-300 ${
          isExpanded ? 'gap-3 px-4 justify-start' : 'justify-center px-0'
        }`}
      >
        <span className="flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-orange-500 to-orange-400 text-xl font-bold text-white shadow-md">
          DF
        </span>
        <div
          className={`flex flex-col transition-all duration-200 ${
            isExpanded ? 'ml-2 opacity-100' : 'pointer-events-none opacity-0 w-0 overflow-hidden'
          }`}
        >
          <span className="text-sm font-semibold text-gray-500">Dashboard</span>
          <span className="text-lg font-bold text-gray-900 leading-tight">Financeiro</span>
        </div>
      </div>

      <nav className="flex-1 space-y-2 px-3">
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/app'}
              className={({ isActive }) => {
                const baseClasses =
                  'group flex items-center rounded-2xl text-sm font-medium transition-all duration-200';
                const stateClasses = isExpanded
                  ? 'w-full gap-3 px-3 py-3'
                  : 'mx-auto h-12 w-12 justify-center';
                const activeClasses = isActive
                  ? 'bg-gradient-to-r from-orange-500 to-orange-400 text-white shadow-lg'
                  : 'text-gray-600 hover:bg-orange-50 hover:text-orange-500';
                return `${baseClasses} ${stateClasses} ${activeClasses}`;
              }}
              title={item.label}
            >
              <Icon className="h-5 w-5 flex-shrink-0" />
              <span
                className={`transition-all duration-150 ${
                  isExpanded
                    ? 'opacity-100'
                    : 'pointer-events-none w-0 overflow-hidden opacity-0'
                }`}
              >
                {item.label}
              </span>
            </NavLink>
          );
        })}
      </nav>

      <div className="border-t border-orange-100 px-3 py-4">
        <button
          type="button"
          onClick={logout}
          className={`flex w-full items-center gap-3 rounded-2xl px-3 py-3 text-sm font-semibold text-red-500 transition-all duration-200 hover:bg-red-50 ${
            isExpanded ? '' : 'justify-center'
          }`}
          title="Sair"
        >
          <LogOut className="h-5 w-5" />
          <span
            className={`transition-opacity duration-150 ${
              isExpanded ? 'opacity-100' : 'pointer-events-none opacity-0'
            }`}
          >
            Sair
          </span>
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;
