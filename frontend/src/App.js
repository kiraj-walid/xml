import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Editor from '@monaco-editor/react';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import ConfigForm from './components/ConfigForm';
import './index.css';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

function App() {
  const [activeTab, setActiveTab] = useState('editor');
  const [viewMode, setViewMode] = useState('xml'); // 'xml' or 'form'
  const [xmlContent, setXmlContent] = useState('');
  const [validationResult, setValidationResult] = useState(null);
  const [environments, setEnvironments] = useState([]);
  const [selectedEnvironment, setSelectedEnvironment] = useState('dev');
  const [generatedContent, setGeneratedContent] = useState(null);
  const [generatedType, setGeneratedType] = useState(null);
  const [loading, setLoading] = useState(false);

  // Charger l'exemple XML au démarrage
  useEffect(() => {
    loadExample();
  }, []);

  const loadExample = async () => {
    try {
      // Charger depuis le backend ou utiliser un exemple intégré
      const response = await fetch(`${API_BASE_URL.replace('/api', '')}/examples/sample-config.xml`);
      if (response.ok) {
        const text = await response.text();
        setXmlContent(text);
      } else {
        // Exemple par défaut si le fichier n'est pas accessible
        setXmlContent(`<?xml version="1.0" encoding="UTF-8"?>
<devops-config version="1.0">
    <application>
        <name>my-app</name>
        <version>1.0.0</version>
        <description>Application exemple</description>
    </application>
    <environments>
        <environment>
            <name>dev</name>
            <services>
                <service>
                    <name>web</name>
                    <image>nginx</image>
                    <tag>alpine</tag>
                    <ports>
                        <port>
                            <host>8080</host>
                            <container>80</container>
                        </port>
                    </ports>
                </service>
            </services>
        </environment>
    </environments>
</devops-config>`);
      }
    } catch (error) {
      console.error('Erreur lors du chargement de l\'exemple:', error);
      // Charger un exemple minimal en cas d'erreur
      setXmlContent(`<?xml version="1.0" encoding="UTF-8"?>
<devops-config version="1.0">
    <application>
        <name>my-app</name>
        <version>1.0.0</version>
    </application>
    <environments>
        <environment>
            <name>dev</name>
            <services>
                <service>
                    <name>web</name>
                    <image>nginx</image>
                </service>
            </services>
        </environment>
    </environments>
</devops-config>`);
    }
  };

  const validateXML = async () => {
    if (!xmlContent.trim()) {
      toast.error('Veuillez saisir du contenu XML');
      return;
    }

    setLoading(true);
    try {
      const response = await axios.post(`${API_BASE_URL}/validate`, {
        xml: xmlContent
      });

      setValidationResult(response.data);

      if (response.data.valid) {
        toast.success('Validation réussie !');
        // Charger les environnements disponibles
        loadEnvironments();
      } else {
        toast.error('Erreurs de validation détectées');
      }
    } catch (error) {
      toast.error('Erreur lors de la validation: ' + (error.response?.data?.message || error.message));
      setValidationResult({
        valid: false,
        message: 'Erreur lors de la validation',
        errors: []
      });
    } finally {
      setLoading(false);
    }
  };

  const loadEnvironments = async () => {
    try {
      const response = await axios.post(`${API_BASE_URL}/environments`, {
        xml: xmlContent
      });
      if (response.data.environments && response.data.environments.length > 0) {
        setEnvironments(response.data.environments);
        setSelectedEnvironment(response.data.environments[0]);
      }
    } catch (error) {
      console.error('Erreur lors du chargement des environnements:', error);
    }
  };

  const generateDockerCompose = async () => {
    if (!xmlContent.trim()) {
      toast.error('Veuillez saisir du contenu XML');
      return;
    }

    setLoading(true);
    try {
      const response = await axios.post(`${API_BASE_URL}/transform/docker-compose`, {
        xml: xmlContent,
        environment: selectedEnvironment
      });

      if (response.data.success) {
        setGeneratedContent(response.data.content);
        setGeneratedType('docker-compose');
        setActiveTab('preview');
        toast.success('Fichier Docker Compose généré avec succès !');
      } else {
        toast.error(response.data.message || 'Erreur lors de la génération');
      }
    } catch (error) {
      toast.error('Erreur: ' + (error.response?.data?.message || error.message));
    } finally {
      setLoading(false);
    }
  };

  const generateKubernetes = async () => {
    if (!xmlContent.trim()) {
      toast.error('Veuillez saisir du contenu XML');
      return;
    }

    setLoading(true);
    try {
      const response = await axios.post(`${API_BASE_URL}/transform/kubernetes`, {
        xml: xmlContent,
        environment: selectedEnvironment
      });

      if (response.data.success) {
        setGeneratedContent(response.data.content);
        setGeneratedType('kubernetes');
        setActiveTab('preview');
        toast.success('Fichier Kubernetes généré avec succès !');
      } else {
        toast.error(response.data.message || 'Erreur lors de la génération');
      }
    } catch (error) {
      toast.error('Erreur: ' + (error.response?.data?.message || error.message));
    } finally {
      setLoading(false);
    }
  };

  const generateGitHubActions = async () => {
    if (!xmlContent.trim()) {
      toast.error('Veuillez saisir du contenu XML');
      return;
    }

    setLoading(true);
    try {
      const response = await axios.post(`${API_BASE_URL}/transform/github-actions`, {
        xml: xmlContent,
        environment: selectedEnvironment
      });

      if (response.data.success) {
        setGeneratedContent(response.data.content);
        setGeneratedType('github-actions');
        setActiveTab('preview');
        toast.success('Workflow GitHub Actions généré avec succès !');
      } else {
        toast.error(response.data.message || 'Erreur lors de la génération');
      }
    } catch (error) {
      toast.error('Erreur: ' + (error.response?.data?.message || error.message));
    } finally {
      setLoading(false);
    }
  };

  const generateJenkins = async () => {
    if (!xmlContent.trim()) {
      toast.error('Veuillez saisir du contenu XML');
      return;
    }

    setLoading(true);
    try {
      const response = await axios.post(`${API_BASE_URL}/transform/jenkins`, {
        xml: xmlContent,
        environment: selectedEnvironment
      });

      if (response.data.success) {
        setGeneratedContent(response.data.content);
        setGeneratedType('jenkins');
        setActiveTab('preview');
        toast.success('Pipeline Jenkins généré avec succès !');
      } else {
        toast.error(response.data.message || 'Erreur lors de la génération');
      }
    } catch (error) {
      toast.error('Erreur: ' + (error.response?.data?.message || error.message));
    } finally {
      setLoading(false);
    }
  };

  const downloadFile = async () => {
    if (!generatedContent) {
      toast.error('Aucun contenu à télécharger');
      return;
    }

    try {
      const response = await axios.post(
        `${API_BASE_URL}/download/${generatedType}`,
        {
          content: generatedContent,
          environment: selectedEnvironment,
          filename: `config-${selectedEnvironment}`
        },
        { responseType: 'blob' }
      );

      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `config-${selectedEnvironment}.yaml`);
      document.body.appendChild(link);
      link.click();
      link.remove();

      toast.success('Fichier téléchargé avec succès !');
    } catch (error) {
      toast.error('Erreur lors du téléchargement: ' + error.message);
    }
  };

  return (
    <div className="container">
      <ToastContainer position="top-right" autoClose={3000} />

      <div className="header">
        <h1>🚀 DevOps Config Manager</h1>
        <p>Gestion centralisée des configurations multi-environnements</p>
      </div>

      <div className="info-box">
        <h3>📋 Guide d'utilisation</h3>
        <ul>
          <li>Saisissez ou importez votre configuration XML dans l'éditeur</li>
          <li>Validez la configuration XML contre le schéma XSD</li>
          <li>Générez les fichiers Docker Compose ou Kubernetes pour l'environnement sélectionné</li>
          <li>Visualisez et téléchargez les fichiers générés</li>
        </ul>
      </div>

      <div className="tabs">
        <div className="view-mode-selector">
          <button
            className={`btn btn-small ${viewMode === 'xml' ? 'btn-primary' : 'btn-secondary'}`}
            onClick={() => setViewMode('xml')}
          >
            📝 Mode XML
          </button>
          <button
            className={`btn btn-small ${viewMode === 'form' ? 'btn-primary' : 'btn-secondary'}`}
            onClick={() => setViewMode('form')}
          >
            📋 Mode Formulaire
          </button>
        </div>
        <button
          className={`tab ${activeTab === 'editor' ? 'active' : ''}`}
          onClick={() => setActiveTab('editor')}
        >
          {viewMode === 'xml' ? '📝 Éditeur XML' : '📋 Formulaire'}
        </button>
        <button
          className={`tab ${activeTab === 'preview' ? 'active' : ''}`}
          onClick={() => setActiveTab('preview')}
          disabled={!generatedContent}
        >
          👁️ Aperçu
        </button>
        <button
          className={`tab ${activeTab === 'compare' ? 'active' : ''}`}
          onClick={() => setActiveTab('compare')}
        >
          🔍 Comparer
        </button>
      </div>

      {activeTab === 'editor' && (
        <div className="tab-content active">
          {viewMode === 'xml' ? (
            <div className="editor-container">
              <h2>Configuration XML</h2>
              <div className="controls">
                <button className="btn btn-secondary" onClick={loadExample}>
                  📄 Charger l'exemple
                </button>
                <button className="btn btn-primary" onClick={validateXML} disabled={loading}>
                  {loading ? '⏳ Validation...' : '✓ Valider XML'}
                </button>
                {environments.length > 0 && (
                  <>
                    <select
                      className="select"
                      value={selectedEnvironment}
                      onChange={(e) => setSelectedEnvironment(e.target.value)}
                    >
                      {environments.map((env) => (
                        <option key={env} value={env}>
                          {env}
                        </option>
                      ))}
                    </select>
                    <button
                      className="btn btn-success"
                      onClick={generateDockerCompose}
                      disabled={loading || !validationResult?.valid}
                    >
                      🐳 Générer Docker Compose
                    </button>
                    <button
                      className="btn btn-success"
                      onClick={generateKubernetes}
                      disabled={loading || !validationResult?.valid}
                    >
                      ☸️ Générer Kubernetes
                    </button>
                    <button
                      className="btn btn-success"
                      onClick={async () => {
                        if (!xmlContent.trim()) {
                          toast.error('Veuillez saisir du contenu XML');
                          return;
                        }
                        setLoading(true);
                        try {
                          const response = await axios.post(`${API_BASE_URL}/transform/helm`, {
                            xml: xmlContent,
                            environment: selectedEnvironment
                          });
                          if (response.data.success) {
                            setGeneratedContent(response.data.content);
                            setGeneratedType('helm');
                            setActiveTab('preview');
                            toast.success('Fichier Helm Chart généré avec succès !');
                          } else {
                            toast.error(response.data.message || 'Erreur lors de la génération');
                          }
                        } catch (error) {
                          toast.error('Erreur: ' + (error.response?.data?.message || error.message));
                        } finally {
                          setLoading(false);
                        }
                      }}
                      disabled={loading || !validationResult?.valid}
                    >
                      🎯 Générer Helm Chart
                    </button>
                    <button
                      className="btn btn-info"
                      onClick={generateGitHubActions}
                      disabled={loading || !validationResult?.valid}
                    >
                      🔄 Générer GitHub Actions
                    </button>
                    <button
                      className="btn btn-info"
                      onClick={generateJenkins}
                      disabled={loading || !validationResult?.valid}
                    >
                      🔧 Générer Jenkins Pipeline
                    </button>
                  </>
                )}
              </div>

              <div className="editor-wrapper">
                <Editor
                  height="500px"
                  defaultLanguage="xml"
                  value={xmlContent}
                  onChange={(value) => setXmlContent(value || '')}
                  theme="vs-light"
                  options={{
                    minimap: { enabled: true },
                    fontSize: 14,
                    wordWrap: 'on',
                    automaticLayout: true,
                  }}
                />
              </div>

              {validationResult && (
                <div className={`validation-result ${validationResult.valid ? 'success' : 'error'}`}>
                  <strong>{validationResult.valid ? '✓' : '✗'}</strong> {validationResult.message}
                  {validationResult.errors && validationResult.errors.length > 0 && (
                    <ul className="validation-errors">
                      {validationResult.errors.map((error, index) => (
                        <li key={index}>
                          {error.line && `Ligne ${error.line}: `}
                          {error.message}
                        </li>
                      ))}
                    </ul>
                  )}
                </div>
              )}
            </div>
          ) : (
            <ConfigForm
              onGenerateXML={(xml) => {
                setXmlContent(xml);
                setViewMode('xml');
                toast.success('XML généré depuis le formulaire !');
                // Valider automatiquement après génération
                setTimeout(() => {
                  validateXML();
                }, 500);
              }}
            />
          )}
        </div>
      )}

      {activeTab === 'compare' && (
        <div className="tab-content active">
          <div className="editor-container">
            <h2>Comparer les environnements</h2>
            {environments.length >= 2 ? (
              <div className="compare-section">
                <div className="form-row">
                  <select
                    className="select"
                    value={selectedEnvironment}
                    onChange={(e) => setSelectedEnvironment(e.target.value)}
                  >
                    {environments.map((env) => (
                      <option key={env} value={env}>
                        {env}
                      </option>
                    ))}
                  </select>
                  <span>vs</span>
                  <select
                    className="select"
                    id="env2-select"
                  >
                    {environments.map((env) => (
                      <option key={env} value={env}>
                        {env}
                      </option>
                    ))}
                  </select>
                  <button
                    className="btn btn-primary"
                    onClick={async () => {
                      const env2 = document.getElementById('env2-select').value;
                      try {
                        const response = await axios.post(`${API_BASE_URL}/compare`, {
                          xml: xmlContent,
                          environment1: selectedEnvironment,
                          environment2: env2
                        });
                        if (response.data.success) {
                          const comp = response.data.comparison;
                          alert(`Comparaison:\n\nSeulement dans ${selectedEnvironment}: ${comp.only_in_env1.join(', ') || 'Aucun'}\nSeulement dans ${env2}: ${comp.only_in_env2.join(', ') || 'Aucun'}\nCommuns: ${comp.common.join(', ')}\nDifférences: ${comp.differences.length}`);
                        }
                      } catch (error) {
                        toast.error('Erreur lors de la comparaison');
                      }
                    }}
                  >
                    Comparer
                  </button>
                </div>
              </div>
            ) : (
              <p>Au moins 2 environnements sont nécessaires pour comparer</p>
            )}
          </div>
        </div>
      )}

      {activeTab === 'preview' && generatedContent && (
        <div className="tab-content active">
          <div className="preview-container">
            <h2>
              Fichier {
                generatedType === 'docker-compose' ? 'Docker Compose' :
                  generatedType === 'kubernetes' ? 'Kubernetes' :
                    generatedType === 'helm' ? 'Helm Chart' :
                      generatedType === 'github-actions' ? 'GitHub Actions Workflow' :
                        generatedType === 'jenkins' ? 'Jenkins Pipeline' : 'Généré'
              }
              {' '}({selectedEnvironment})
            </h2>
            <div className="controls">
              <button className="btn btn-primary" onClick={downloadFile}>
                💾 Télécharger
              </button>
              <button className="btn btn-secondary" onClick={() => setActiveTab('editor')}>
                ← Retour à l'éditeur
              </button>
            </div>
            <div className="preview-content">
              {generatedContent}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
