import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [healthStatus, setHealthStatus] = useState(null);
  const [models, setModels] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';
  const API_KEY = process.env.REACT_APP_LITELLM_API_KEY;
  useEffect(() => {
    fetchHealthStatus();
    fetchModels();
    // Refresh every 30 seconds
    const interval = setInterval(() => {
      fetchHealthStatus();
      fetchModels();
    }, 30000);
    return () => clearInterval(interval);
  }, []);

  const fetchHealthStatus = async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/health`, {
        headers: {
          Authorization: `Bearer ${API_KEY}`
        }
      });
      setHealthStatus(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch health status');
      console.error('Health check error:', err);
    }
  };
  
  const fetchModels = async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/models`, {
        headers: {
          Authorization: `Bearer ${API_KEY}`
        }
      });
      setModels(response.data.data || []);
      setLoading(false);
    } catch (err) {
      setError('Failed to fetch models');
      setLoading(false);
      console.error('Models fetch error:', err);
    }
  };

  const getHealthStatusText = () => {
    if (!healthStatus) return 'Unknown';
    if (healthStatus.healthy_endpoints && healthStatus.healthy_endpoints.length > 0) {
      return 'Healthy';
    }
    return 'Unhealthy';
  };

  const getHealthStatusClass = () => {
    const status = getHealthStatusText();
    return status === 'Healthy' ? 'status-healthy' : 'status-unhealthy';
  };

  return (
    <div className="App">
      <div className="header">
        <h1>🚀 LiteLLM Proxy Dashboard</h1>
        <p>Manage and monitor your LLM models</p>
      </div>

      <div className="container">
        {/* Health Status Card */}
        <div className="card">
          <h2>System Health</h2>
          {error ? (
            <div style={{ color: 'red' }}>{error}</div>
          ) : healthStatus ? (
            <div>
              <p>
                <span className={`status-indicator ${getHealthStatusClass()}`}></span>
                Status: <strong>{getHealthStatusText()}</strong>
              </p>
              <button className="button" onClick={fetchHealthStatus}>
                Refresh Health
              </button>
              <details style={{ marginTop: '10px' }}>
                <summary>Health Details</summary>
                <pre style={{ 
                  background: '#f8f9fa', 
                  padding: '10px', 
                  borderRadius: '4px',
                  overflow: 'auto',
                  maxHeight: '200px'
                }}>
                  {JSON.stringify(healthStatus, null, 2)}
                </pre>
              </details>
            </div>
          ) : (
            <p>Loading health status...</p>
          )}
        </div>

        {/* Models Card */}
        <div className="card">
          <h2>Available Models</h2>
          {loading ? (
            <p>Loading models...</p>
          ) : models.length > 0 ? (
            <div>
              <button className="button" onClick={fetchModels}>
                Refresh Models
              </button>
              <div style={{ marginTop: '15px' }}>
                {models.map((model, index) => (
                  <div key={index} style={{ 
                    border: '1px solid #ddd', 
                    padding: '10px', 
                    margin: '5px 0', 
                    borderRadius: '4px',
                    background: '#f9f9f9'
                  }}>
                    <strong>{model.id}</strong>
                    <br />
                    <small>Object: {model.object}</small>
                    <br />
                    <small>Created: {new Date(model.created * 1000).toLocaleString()}</small>
                    <br />
                    <small>Owned by: {model.owned_by}</small>
                  </div>
                ))}
              </div>
            </div>
          ) : (
            <p>No models available</p>
          )}
        </div>

        {/* API Endpoints Card */}
        <div className="card">
          <h2>API Endpoints</h2>
          <div>
            <p><strong>Health Check:</strong> <code>{API_BASE_URL}/health</code></p>
            <p><strong>Models:</strong> <code>{API_BASE_URL}/models</code></p>
            <p><strong>Chat Completions:</strong> <code>{API_BASE_URL}/v1/chat/completions</code></p>
            <p><strong>Completions:</strong> <code>{API_BASE_URL}/v1/completions</code></p>
          </div>
        </div>

        {/* Quick Actions Card */}
        <div className="card">
          <h2>Quick Actions</h2>
          <div>
            <button 
              className="button" 
              onClick={() => {
                fetchHealthStatus();
                fetchModels();
              }}
              style={{ marginRight: '10px' }}
            >
              Refresh All
            </button>
            <button 
              className="button" 
              onClick={() => window.open(`${API_BASE_URL}/health`, '_blank')}
            >
              Open Health API
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App; 