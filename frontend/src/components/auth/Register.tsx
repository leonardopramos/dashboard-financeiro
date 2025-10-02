import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';

const Register = () => {
  const { register, isLoading } = useAuth();
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    cpf: ''
  });
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    
    if (formData.password !== formData.confirmPassword) {
      setError('As senhas não coincidem');
      return;
    }

    try {
      await register({
        name: formData.name,
        email: formData.email,
        password: formData.password,
        cpf: formData.cpf
      });
    } catch (err: any) {
      setError(err.response?.data?.message || 'Erro ao criar conta');
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
      <div className="bg-white rounded-3xl shadow-2xl max-w-md w-full border border-gray-200 relative overflow-hidden p-8">
        {/* Barra laranja no topo */}
        <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-orange-500 to-orange-400 rounded-t-3xl"></div>
        
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-orange-500 to-orange-400 rounded-2xl text-white mb-6 shadow-lg text-2xl">
            ✨
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Crie sua conta</h1>
          <p className="text-gray-600 text-base">Junte-se a nós e comece sua jornada</p>
        </div>

        {error && (
          <div className="bg-red-50 border border-red-200 text-red-600 px-3 py-2 rounded-lg mb-6 text-sm mx-4">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-6 px-4">
          <div>
            <label className="font-medium text-gray-700 text-sm block mb-2">Nome completo</label>
            <input 
              type="text" 
              name="name"
              value={formData.name}
              onChange={handleChange}
              placeholder="Digite seu nome completo"
              required
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl text-base transition-all duration-200 bg-white focus:border-orange-500 focus:ring-2 focus:ring-orange-100 focus:outline-none"
            />
          </div>

          <div>
            <label className="font-medium text-gray-700 text-sm block mb-2">CPF</label>
            <input 
              type="text" 
              name="cpf"
              value={formData.cpf}
              onChange={handleChange}
              placeholder="000.000.000-00"
              required
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl text-base transition-all duration-200 bg-white focus:border-orange-500 focus:ring-2 focus:ring-orange-100 focus:outline-none"
            />
          </div>

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

          <div>
            <label className="font-medium text-gray-700 text-sm block mb-2">Confirmar senha</label>
            <input 
              type="password" 
              name="confirmPassword"
              value={formData.confirmPassword}
              onChange={handleChange}
              placeholder="Confirme sua senha"
              required
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl text-base transition-all duration-200 bg-white focus:border-orange-500 focus:ring-2 focus:ring-orange-100 focus:outline-none"
            />
          </div>

          <button 
            type="submit"
            disabled={isLoading}
            className="w-full py-3.5 px-6 bg-gradient-to-r from-orange-500 to-orange-400 text-white border-none rounded-xl text-base font-semibold cursor-pointer shadow-md hover:shadow-lg transition-all duration-200 mt-2 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isLoading ? '⏳ Criando conta...' : '✨ Criar conta'}
          </button>
        </form>

        <div className="text-center mt-8 pt-8 border-t border-gray-200 px-4">
          <p className="text-gray-600 text-sm">
            Já tem uma conta?{' '}
            <Link to="/login" className="text-orange-500 no-underline font-medium hover:text-orange-600 transition-colors">
              Faça login aqui
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Register;