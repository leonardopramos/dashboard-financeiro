import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';

// Versão simplificada para teste
const LoginSimple: React.FC = () => {
  return (
    <div style={{ padding: '20px', backgroundColor: 'blue', color: 'white' }}>
      <h1>LOGIN SIMPLES - TESTE</h1>
      <p>Se você vê isso, o componente Login está sendo renderizado!</p>
      <Link to="/register" style={{ color: 'yellow' }}>Ir para Registro</Link>
    </div>
  );
};

export default LoginSimple;