import { useAuth } from '../contexts/AuthContext';

const Dashboard = () => {
  const { user, logout } = useAuth();
  
  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-6xl mx-auto bg-white rounded-2xl p-8 shadow-lg">
        <div className="flex justify-between items-center mb-8 pb-4 border-b-2 border-primary-500">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-2">🎉 Dashboard</h1>
            <p className="text-gray-600">Bem-vindo, {user?.name}!</p>
          </div>
          <button 
            onClick={logout}
            className="px-6 py-3 bg-primary-500 text-white rounded-xl font-semibold shadow-md hover:bg-primary-600 transition-colors"
          >
            🚪 Logout
          </button>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="p-6 bg-gray-50 rounded-xl border border-gray-200">
            <h3 className="text-xl font-semibold text-gray-900 mb-4">📊 Informações da Conta</h3>
            <div className="space-y-2">
              <p className="text-gray-600"><strong className="text-gray-800">Nome:</strong> {user?.name}</p>
              <p className="text-gray-600"><strong className="text-gray-800">Email:</strong> {user?.email}</p>
              <p className="text-gray-600"><strong className="text-gray-800">ID:</strong> {user?.id}</p>
            </div>
          </div>
          
          <div className="p-6 bg-green-50 rounded-xl border border-green-200">
            <h3 className="text-xl font-semibold text-green-800 mb-4">✅ Status</h3>
            <p className="text-green-700 mb-2">Autenticação funcionando perfeitamente!</p>
            <p className="text-green-600 text-sm">
              Backend conectado em localhost:8080
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;