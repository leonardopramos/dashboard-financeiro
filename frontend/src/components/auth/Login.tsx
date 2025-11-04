import { useEffect, useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { PENDING_EMAIL_KEY } from '../../services/api';

const Login = () => {
  const { login, isLoading } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [formData, setFormData] = useState(() => ({
    email: sessionStorage.getItem(PENDING_EMAIL_KEY) ?? '',
    password: '',
  }));
  const [error, setError] = useState('');
  const [info, setInfo] = useState('');

  useEffect(() => {
    if (!location.state) {
      return;
    }

    const state = location.state as { email?: string; verified?: boolean };
    if (state.email) {
      setFormData((prev) => ({ ...prev, email: state.email ?? '' }));
      sessionStorage.setItem(PENDING_EMAIL_KEY, state.email ?? '');
    }
    if (state.verified) {
      setInfo('E-mail verificado com sucesso! Faça login para continuar.');
    }
    navigate('/login', { replace: true });
  }, [location.state, navigate]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setInfo('');

    try {
      await login(formData);
      sessionStorage.removeItem(PENDING_EMAIL_KEY);
      navigate('/app', { replace: true });
    } catch (err: any) {
      const detail = err.response?.data?.detail ?? err.response?.data?.message ?? 'Erro ao fazer login';
      if (detail?.toLowerCase().includes('e-mail não verificado')) {
        sessionStorage.setItem(PENDING_EMAIL_KEY, formData.email.trim());
        navigate('/verify-email', {
          replace: true,
          state: { email: formData.email.trim() },
        });
        return;
      }
      setError(detail);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-3xl shadow-2xl max-w-md w-full border border-gray-200 relative overflow-hidden">
        {/* Barra laranja no topo */}
        <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-orange-500 to-orange-400 rounded-t-3xl"></div>

        {/* Conteúdo do formulário */}
        <div className="p-10 text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-orange-500 to-orange-400 rounded-2xl text-white mb-6 shadow-lg text-2xl">
            👤
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Bem-vindo de volta!</h1>
          <p className="text-gray-600 text-base">Entre na sua conta para continuar</p>
        </div>

        {error && (
          <div className="bg-red-50 border border-red-200 text-red-600 px-3 py-2 rounded-lg mb-6 text-sm mx-10">
            {error}
          </div>
        )}

        {info && !error && (
          <div className="bg-green-50 border border-green-200 text-green-700 px-3 py-2 rounded-lg mb-6 text-sm mx-10">
            {info}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-6 px-10">
          <div>
            <label className="font-medium text-gray-700 text-sm block mb-2">Email</label>
            <input 
              type="email" 
              name="email"
              value={formData.email}
              onChange={handleChange}
              placeholder="Digite seu email"
              required
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl text-base transition-all duration-200 bg-white focus:border-orange-500 focus:ring-2 focus:ring-orange-100 focus:outline-none"
            />
          </div>

          <div>
            <label className="font-medium text-gray-700 text-sm block mb-2">Senha</label>
            <input 
              type="password" 
              name="password"
              value={formData.password}
              onChange={handleChange}
              placeholder="Digite sua senha"
              required
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl text-base transition-all duration-200 bg-white focus:border-orange-500 focus:ring-2 focus:ring-orange-100 focus:outline-none"
            />
          </div>

          <button 
            type="submit"
            disabled={isLoading}
            className="w-full py-3.5 px-6 bg-gradient-to-r from-orange-500 to-orange-400 text-white border-none rounded-xl text-base font-semibold cursor-pointer shadow-md hover:shadow-lg transition-all duration-200 mt-2 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isLoading ? '⏳ Entrando...' : '🚀 Entrar'}
          </button>
        </form>

        <div className="text-center mt-8 pt-8 border-t border-gray-200 px-10">
          <p className="text-gray-600 text-sm">
            Não tem uma conta?{' '}
            <Link to="/register" className="text-orange-500 no-underline font-medium hover:text-orange-600 transition-colors">
              Cadastre-se aqui
            </Link>
          </p>
        </div>

        <div className="mt-6 p-4 bg-gray-50 rounded-xl border-l-4 border-orange-500 mx-10 mb-6">
          <p className="text-xs text-gray-600 mb-2">
            <strong className="text-gray-700">Feito por: Leonardo Preczevski Ramos</strong>
          </p>
          <p className="text-xs text-gray-600">
            Dashboard Financeiro - Trabalho de Conclusão de curso - Bacharel em Sistemas de Informação
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;
