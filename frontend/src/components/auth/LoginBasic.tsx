import React from 'react';

const LoginBasic: React.FC = () => {
  return (
    <div style={{ 
      minHeight: '100vh', 
      backgroundColor: 'lightblue', 
      padding: '20px',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }}>
      <div style={{
        backgroundColor: 'white',
        padding: '40px',
        borderRadius: '10px',
        boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
        maxWidth: '400px',
        width: '100%'
      }}>
        <h1 style={{ color: '#FF6B35', textAlign: 'center', marginBottom: '20px' }}>
          Login Básico
        </h1>
        <form style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
          <input 
            type="email" 
            placeholder="Email"
            style={{
              padding: '12px',
              border: '2px solid #ddd',
              borderRadius: '6px',
              fontSize: '16px'
            }}
          />
          <input 
            type="password" 
            placeholder="Senha"
            style={{
              padding: '12px',
              border: '2px solid #ddd',
              borderRadius: '6px',
              fontSize: '16px'
            }}
          />
          <button 
            type="submit"
            style={{
              padding: '12px',
              backgroundColor: '#FF6B35',
              color: 'white',
              border: 'none',
              borderRadius: '6px',
              fontSize: '16px',
              cursor: 'pointer'
            }}
          >
            Entrar
          </button>
        </form>
        <p style={{ textAlign: 'center', marginTop: '20px', color: '#666' }}>
          Se você vê isso, o componente está funcionando!
        </p>
      </div>
    </div>
  );
};

export default LoginBasic;