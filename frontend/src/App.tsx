import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';
import Login from './components/auth/Login';
import Register from './components/auth/Register';
import VerifyEmail from './components/auth/VerifyEmail';
import AppLayout from './components/layout/AppLayout';
import Dashboard from './pages/Dashboard';
import Profile from './pages/Profile';
import BankAccounts from './pages/BankAccounts';
import Transactions from './pages/Transactions';
import Categories from './pages/Categories';
import Goals from './pages/Goals';
import Education from './pages/Education';

const InitialRoute = () => {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div
        style={{
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          height: '100vh',
          backgroundColor: '#f9fafb',
        }}
      >
        <div
          style={{
            padding: '2rem',
            backgroundColor: 'white',
            borderRadius: '1rem',
            boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
            textAlign: 'center',
          }}
        >
          <div
            style={{
              width: '3rem',
              height: '3rem',
              border: '4px solid #FF6B35',
              borderTop: '4px solid transparent',
              borderRadius: '50%',
              animation: 'spin 1s linear infinite',
              margin: '0 auto 1rem',
            }}
          ></div>
          <p style={{ color: '#6b7280', margin: 0 }}>Carregando...</p>
        </div>
      </div>
    );
  }

  return <Navigate to={isAuthenticated ? '/app' : '/login'} replace />;
};

function App() {
  return (
    <div className="App">
      <AuthProvider>
        <Router>
          <Routes>
            <Route path="/" element={<InitialRoute />} />

            {/* Rotas públicas */}
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            <Route path="/verify-email" element={<VerifyEmail />} />

            {/* Área autenticada com layout e rotas filhas */}
            <Route
              path="/app"
              element={
                <ProtectedRoute>
                  <AppLayout />
                </ProtectedRoute>
              }
            >
              <Route index element={<Dashboard />} />
              <Route path="perfil" element={<Profile />} />
              <Route path="contas" element={<BankAccounts />} />
              <Route path="transacoes" element={<Transactions />} />
              <Route path="categorias" element={<Categories />} />
              <Route path="metas" element={<Goals />} />
              <Route path="educacao" element={<Education />} />
            </Route>

            {/* Rota 404 - redireciona para login */}
            <Route path="*" element={<Navigate to="/login" replace />} />
          </Routes>
        </Router>
      </AuthProvider>
    </div>
  );
}

export default App;
