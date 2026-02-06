import React, { useState } from 'react';
import './ConfigForm.css';

const ConfigForm = ({ onGenerateXML, initialData }) => {
  const [formData, setFormData] = useState({
    application: {
      name: initialData?.application?.name || '',
      version: initialData?.application?.version || '',
      description: initialData?.application?.description || ''
    },
    environments: initialData?.environments || [
      {
        name: 'dev',
        services: [],
        variables: [],
        secrets: []
      }
    ]
  });

  const [activeEnvIndex, setActiveEnvIndex] = useState(0);

  const addEnvironment = () => {
    const envName = prompt('Nom de l\'environnement:');
    if (envName) {
      setFormData({
        ...formData,
        environments: [
          ...formData.environments,
          {
            name: envName,
            services: [],
            variables: [],
            secrets: []
          }
        ]
      });
      setActiveEnvIndex(formData.environments.length);
    }
  };

  const addService = (envIndex) => {
    const newService = {
      name: '',
      image: '',
      tag: '',
      ports: [],
      volumes: [],
      environment: [],
      depends_on: [],
      command: '',
      working_dir: '',
      replicas: ''
    };
    
    const updatedEnvs = [...formData.environments];
    updatedEnvs[envIndex].services.push(newService);
    setFormData({ ...formData, environments: updatedEnvs });
  };

  const updateService = (envIndex, serviceIndex, field, value) => {
    const updatedEnvs = [...formData.environments];
    updatedEnvs[envIndex].services[serviceIndex][field] = value;
    setFormData({ ...formData, environments: updatedEnvs });
  };

  const addPort = (envIndex, serviceIndex) => {
    const updatedEnvs = [...formData.environments];
    updatedEnvs[envIndex].services[serviceIndex].ports.push({
      host: '',
      container: '',
      protocol: 'tcp'
    });
    setFormData({ ...formData, environments: updatedEnvs });
  };

  const updatePort = (envIndex, serviceIndex, portIndex, field, value) => {
    const updatedEnvs = [...formData.environments];
    updatedEnvs[envIndex].services[serviceIndex].ports[portIndex][field] = value;
    setFormData({ ...formData, environments: updatedEnvs });
  };

  const addVariable = (envIndex, serviceIndex = null) => {
    const updatedEnvs = [...formData.environments];
    if (serviceIndex !== null) {
      updatedEnvs[envIndex].services[serviceIndex].environment.push({
        name: '',
        value: ''
      });
    } else {
      updatedEnvs[envIndex].variables.push({
        name: '',
        value: ''
      });
    }
    setFormData({ ...formData, environments: updatedEnvs });
  };

  const updateVariable = (envIndex, serviceIndex, varIndex, field, value) => {
    const updatedEnvs = [...formData.environments];
    if (serviceIndex !== null) {
      updatedEnvs[envIndex].services[serviceIndex].environment[varIndex][field] = value;
    } else {
      updatedEnvs[envIndex].variables[varIndex][field] = value;
    }
    setFormData({ ...formData, environments: updatedEnvs });
  };

  const generateXML = () => {
    let xml = '<?xml version="1.0" encoding="UTF-8"?>\n';
    xml += '<devops-config version="1.0">\n';
    
    // Application
    xml += '    <application>\n';
    xml += `        <name>${formData.application.name || 'my-app'}</name>\n`;
    xml += `        <version>${formData.application.version || '1.0.0'}</version>\n`;
    if (formData.application.description) {
      xml += `        <description>${formData.application.description}</description>\n`;
    }
    xml += '    </application>\n';
    
    // Environments
    xml += '    <environments>\n';
    formData.environments.forEach(env => {
      xml += `        <environment>\n`;
      xml += `            <name>${env.name}</name>\n`;
      xml += '            <services>\n';
      
      env.services.forEach(service => {
        xml += '                <service>\n';
        xml += `                    <name>${service.name}</name>\n`;
        xml += `                    <image>${service.image}</image>\n`;
        if (service.tag) {
          xml += `                    <tag>${service.tag}</tag>\n`;
        }
        
        if (service.ports && service.ports.length > 0) {
          xml += '                    <ports>\n';
          service.ports.forEach(port => {
            if (port.host && port.container) {
              xml += '                        <port>\n';
              xml += `                            <host>${port.host}</host>\n`;
              xml += `                            <container>${port.container}</container>\n`;
              if (port.protocol && port.protocol !== 'tcp') {
                xml += `                            <protocol>${port.protocol}</protocol>\n`;
              }
              xml += '                        </port>\n';
            }
          });
          xml += '                    </ports>\n';
        }
        
        if (service.environment && service.environment.length > 0) {
          xml += '                    <environment>\n';
          service.environment.forEach(v => {
            if (v.name && v.value) {
              xml += '                        <variable>\n';
              xml += `                            <name>${v.name}</name>\n`;
              xml += `                            <value>${v.value}</value>\n`;
              xml += '                        </variable>\n';
            }
          });
          xml += '                    </environment>\n';
        }
        
        if (service.command) {
          xml += `                    <command>${service.command}</command>\n`;
        }
        
        if (service.working_dir) {
          xml += `                    <working_dir>${service.working_dir}</working_dir>\n`;
        }
        
        if (service.replicas) {
          xml += `                    <replicas>${service.replicas}</replicas>\n`;
        }
        
        xml += '                </service>\n';
      });
      
      xml += '            </services>\n';
      
      if (env.variables && env.variables.length > 0) {
        xml += '            <variables>\n';
        env.variables.forEach(v => {
          if (v.name && v.value) {
            xml += '                <variable>\n';
            xml += `                    <name>${v.name}</name>\n`;
            xml += `                    <value>${v.value}</value>\n`;
            xml += '                </variable>\n';
          }
        });
        xml += '            </variables>\n';
      }
      
      xml += '        </environment>\n';
    });
    
    xml += '    </environments>\n';
    xml += '</devops-config>';
    
    if (onGenerateXML) {
      onGenerateXML(xml);
    }
  };

  const currentEnv = formData.environments[activeEnvIndex];

  return (
    <div className="config-form">
      <div className="form-header">
        <h2>Formulaire de Configuration</h2>
        <button className="btn btn-primary" onClick={generateXML}>
          Générer XML
        </button>
      </div>

      <div className="form-section">
        <h3>Application</h3>
        <div className="form-group">
          <label>Nom de l'application:</label>
          <input
            type="text"
            value={formData.application.name}
            onChange={(e) => setFormData({
              ...formData,
              application: { ...formData.application, name: e.target.value }
            })}
            placeholder="my-web-app"
          />
        </div>
        <div className="form-group">
          <label>Version:</label>
          <input
            type="text"
            value={formData.application.version}
            onChange={(e) => setFormData({
              ...formData,
              application: { ...formData.application, version: e.target.value }
            })}
            placeholder="1.0.0"
          />
        </div>
        <div className="form-group">
          <label>Description:</label>
          <textarea
            value={formData.application.description}
            onChange={(e) => setFormData({
              ...formData,
              application: { ...formData.application, description: e.target.value }
            })}
            placeholder="Description de l'application"
          />
        </div>
      </div>

      <div className="form-section">
        <div className="env-tabs">
          {formData.environments.map((env, idx) => (
            <button
              key={idx}
              className={`env-tab ${activeEnvIndex === idx ? 'active' : ''}`}
              onClick={() => setActiveEnvIndex(idx)}
            >
              {env.name}
            </button>
          ))}
          <button className="btn btn-secondary" onClick={addEnvironment}>
            + Ajouter
          </button>
        </div>

        <div className="env-content">
          <h3>Environnement: {currentEnv.name}</h3>

          <div className="services-section">
            <h4>Services</h4>
            {currentEnv.services.map((service, serviceIdx) => (
              <div key={serviceIdx} className="service-card">
                <h5>Service {serviceIdx + 1}</h5>
                <div className="form-row">
                  <div className="form-group">
                    <label>Nom:</label>
                    <input
                      type="text"
                      value={service.name}
                      onChange={(e) => updateService(activeEnvIndex, serviceIdx, 'name', e.target.value)}
                      placeholder="web"
                    />
                  </div>
                  <div className="form-group">
                    <label>Image:</label>
                    <input
                      type="text"
                      value={service.image}
                      onChange={(e) => updateService(activeEnvIndex, serviceIdx, 'image', e.target.value)}
                      placeholder="nginx"
                    />
                  </div>
                  <div className="form-group">
                    <label>Tag:</label>
                    <input
                      type="text"
                      value={service.tag}
                      onChange={(e) => updateService(activeEnvIndex, serviceIdx, 'tag', e.target.value)}
                      placeholder="alpine"
                    />
                  </div>
                </div>

                <div className="ports-section">
                  <h6>Ports</h6>
                  {service.ports.map((port, portIdx) => (
                    <div key={portIdx} className="form-row">
                      <input
                        type="number"
                        placeholder="Host"
                        value={port.host}
                        onChange={(e) => updatePort(activeEnvIndex, serviceIdx, portIdx, 'host', e.target.value)}
                      />
                      <input
                        type="number"
                        placeholder="Container"
                        value={port.container}
                        onChange={(e) => updatePort(activeEnvIndex, serviceIdx, portIdx, 'container', e.target.value)}
                      />
                      <select
                        value={port.protocol}
                        onChange={(e) => updatePort(activeEnvIndex, serviceIdx, portIdx, 'protocol', e.target.value)}
                      >
                        <option value="tcp">TCP</option>
                        <option value="udp">UDP</option>
                      </select>
                    </div>
                  ))}
                  <button
                    className="btn btn-small"
                    onClick={() => addPort(activeEnvIndex, serviceIdx)}
                  >
                    + Ajouter Port
                  </button>
                </div>

                <div className="variables-section">
                  <h6>Variables d'environnement</h6>
                  {service.environment.map((v, varIdx) => (
                    <div key={varIdx} className="form-row">
                      <input
                        type="text"
                        placeholder="Nom"
                        value={v.name}
                        onChange={(e) => updateVariable(activeEnvIndex, serviceIdx, varIdx, 'name', e.target.value)}
                      />
                      <input
                        type="text"
                        placeholder="Valeur"
                        value={v.value}
                        onChange={(e) => updateVariable(activeEnvIndex, serviceIdx, varIdx, 'value', e.target.value)}
                      />
                    </div>
                  ))}
                  <button
                    className="btn btn-small"
                    onClick={() => addVariable(activeEnvIndex, serviceIdx)}
                  >
                    + Ajouter Variable
                  </button>
                </div>

                <div className="form-row">
                  <div className="form-group">
                    <label>Command:</label>
                    <input
                      type="text"
                      value={service.command}
                      onChange={(e) => updateService(activeEnvIndex, serviceIdx, 'command', e.target.value)}
                      placeholder="python app.py"
                    />
                  </div>
                  <div className="form-group">
                    <label>Working Dir:</label>
                    <input
                      type="text"
                      value={service.working_dir}
                      onChange={(e) => updateService(activeEnvIndex, serviceIdx, 'working_dir', e.target.value)}
                      placeholder="/app"
                    />
                  </div>
                  <div className="form-group">
                    <label>Replicas:</label>
                    <input
                      type="number"
                      value={service.replicas}
                      onChange={(e) => updateService(activeEnvIndex, serviceIdx, 'replicas', e.target.value)}
                      placeholder="1"
                    />
                  </div>
                </div>
              </div>
            ))}
            <button
              className="btn btn-secondary"
              onClick={() => addService(activeEnvIndex)}
            >
              + Ajouter Service
            </button>
          </div>

          <div className="variables-section">
            <h4>Variables Globales</h4>
            {currentEnv.variables.map((v, varIdx) => (
              <div key={varIdx} className="form-row">
                <input
                  type="text"
                  placeholder="Nom"
                  value={v.name}
                  onChange={(e) => updateVariable(activeEnvIndex, null, varIdx, 'name', e.target.value)}
                />
                <input
                  type="text"
                  placeholder="Valeur"
                  value={v.value}
                  onChange={(e) => updateVariable(activeEnvIndex, null, varIdx, 'value', e.target.value)}
                />
              </div>
            ))}
            <button
              className="btn btn-small"
              onClick={() => addVariable(activeEnvIndex)}
            >
              + Ajouter Variable Globale
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ConfigForm;
