import React from 'react';
import FlowCanvas from './components/FlowCanvas';
import Sidebar from './components/Sidebar';
import './styles/layout.css';
import './styles/controls.css';

function App() {
  return (
    <div className="layout-container">
      <Sidebar />
      <FlowCanvas />
    </div>
  );
}

export default App;
