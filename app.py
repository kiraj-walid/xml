from flask import Flask, request, jsonify, send_file, send_from_directory
from flask_cors import CORS
from lxml import etree
import os
import tempfile
import yaml
from io import BytesIO
import json

app = Flask(__name__)
CORS(app)

# Chemins des fichiers
XSD_SCHEMA_PATH = os.path.join(os.path.dirname(__file__), 'schemas', 'config.xsd')
DOCKER_COMPOSE_XSLT = os.path.join(os.path.dirname(__file__), 'xslt', 'docker-compose.xslt')
KUBERNETES_XSLT = os.path.join(os.path.dirname(__file__), 'xslt', 'kubernetes.xslt')
HELM_XSLT = os.path.join(os.path.dirname(__file__), 'xslt', 'helm.xslt')
JSON_XSLT = os.path.join(os.path.dirname(__file__), 'xslt', 'json.xslt')
EXAMPLES_DIR = os.path.join(os.path.dirname(__file__), 'examples')

@app.route('/examples/<filename>')
def serve_example(filename):
    """Sert les fichiers d'exemple"""
    return send_from_directory(EXAMPLES_DIR, filename)


def validate_xml(xml_content):
    """Valide le XML contre le schéma XSD"""
    try:
        # Parser le XML
        xml_doc = etree.parse(BytesIO(xml_content.encode('utf-8')))
        
        # Charger le schéma XSD
        xsd_doc = etree.parse(XSD_SCHEMA_PATH)
        xsd_schema = etree.XMLSchema(xsd_doc)
        
        # Valider
        is_valid = xsd_schema.validate(xml_doc)
        
        if is_valid:
            return {'valid': True, 'message': 'Le fichier XML est valide'}
        else:
            errors = []
            for error in xsd_schema.error_log:
                errors.append({
                    'line': error.line,
                    'message': error.message,
                    'level': error.level_name,
                    'column': getattr(error, 'column', None)
                })
            return {
                'valid': False,
                'message': 'Le fichier XML contient des erreurs',
                'errors': errors
            }
    except etree.XMLSyntaxError as e:
        return {
            'valid': False,
            'message': f'Erreur de syntaxe XML: {str(e)}',
            'errors': [{'line': e.lineno, 'message': str(e), 'column': e.offset}]
        }
    except Exception as e:
        return {
            'valid': False,
            'message': f'Erreur lors de la validation: {str(e)}',
            'errors': [{'message': str(e)}]
        }


def transform_xml(xml_content, xslt_path, environment='dev'):
    """Transforme le XML en utilisant XSLT"""
    try:
        # Parser le XML
        xml_doc = etree.parse(BytesIO(xml_content.encode('utf-8')))
        
        # Charger le XSLT
        xslt_doc = etree.parse(xslt_path)
        xslt_transformer = etree.XSLT(xslt_doc)
        
        # Appliquer la transformation avec le paramètre environment
        result = xslt_transformer(xml_doc, environment=etree.XSLT.strparam(environment))
        
        return {
            'success': True,
            'content': str(result),
            'message': 'Transformation réussie'
        }
    except Exception as e:
        return {
            'success': False,
            'content': None,
            'message': f'Erreur lors de la transformation: {str(e)}'
        }


@app.route('/api/validate', methods=['POST'])
def validate():
    """Endpoint pour valider un fichier XML"""
    try:
        data = request.get_json()
        xml_content = data.get('xml', '')
        
        if not xml_content:
            return jsonify({
                'valid': False,
                'message': 'Aucun contenu XML fourni'
            }), 400
        
        result = validate_xml(xml_content)
        return jsonify(result)
    except Exception as e:
        return jsonify({
            'valid': False,
            'message': f'Erreur serveur: {str(e)}'
        }), 500


@app.route('/api/transform/docker-compose', methods=['POST'])
def transform_docker_compose():
    """Endpoint pour transformer XML en Docker Compose YAML"""
    try:
        data = request.get_json()
        xml_content = data.get('xml', '')
        environment = data.get('environment', 'dev')
        
        if not xml_content:
            return jsonify({
                'success': False,
                'message': 'Aucun contenu XML fourni'
            }), 400
        
        # Valider d'abord
        validation = validate_xml(xml_content)
        if not validation['valid']:
            return jsonify({
                'success': False,
                'message': 'Le XML n\'est pas valide',
                'validation_errors': validation.get('errors', [])
            }), 400
        
        # Transformer
        result = transform_xml(xml_content, DOCKER_COMPOSE_XSLT, environment)
        return jsonify(result)
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Erreur serveur: {str(e)}'
        }), 500


@app.route('/api/transform/kubernetes', methods=['POST'])
def transform_kubernetes():
    """Endpoint pour transformer XML en Kubernetes YAML"""
    try:
        data = request.get_json()
        xml_content = data.get('xml', '')
        environment = data.get('environment', 'dev')
        
        if not xml_content:
            return jsonify({
                'success': False,
                'message': 'Aucun contenu XML fourni'
            }), 400
        
        # Valider d'abord
        validation = validate_xml(xml_content)
        if not validation['valid']:
            return jsonify({
                'success': False,
                'message': 'Le XML n\'est pas valide',
                'validation_errors': validation.get('errors', [])
            }), 400
        
        # Transformer
        result = transform_xml(xml_content, KUBERNETES_XSLT, environment)
        return jsonify(result)
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Erreur serveur: {str(e)}'
        }), 500


@app.route('/api/transform/helm', methods=['POST'])
def transform_helm():
    """Endpoint pour transformer XML en Helm Chart"""
    try:
        data = request.get_json()
        xml_content = data.get('xml', '')
        environment = data.get('environment', 'dev')
        
        if not xml_content:
            return jsonify({
                'success': False,
                'message': 'Aucun contenu XML fourni'
            }), 400
        
        # Valider d'abord
        validation = validate_xml(xml_content)
        if not validation['valid']:
            return jsonify({
                'success': False,
                'message': 'Le XML n\'est pas valide',
                'validation_errors': validation.get('errors', [])
            }), 400
        
        # Transformer (si le fichier XSLT existe)
        if os.path.exists(HELM_XSLT):
            result = transform_xml(xml_content, HELM_XSLT, environment)
            return jsonify(result)
        else:
            return jsonify({
                'success': False,
                'message': 'Support Helm Charts non encore implémenté'
            }), 501
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Erreur serveur: {str(e)}'
        }), 500


@app.route('/api/transform/json', methods=['POST'])
def transform_json():
    """Endpoint pour transformer XML en JSON"""
    try:
        data = request.get_json()
        xml_content = data.get('xml', '')
        environment = data.get('environment', 'dev')
        
        if not xml_content:
            return jsonify({
                'success': False,
                'message': 'Aucun contenu XML fourni'
            }), 400
        
        # Valider d'abord
        validation = validate_xml(xml_content)
        if not validation['valid']:
            return jsonify({
                'success': False,
                'message': 'Le XML n\'est pas valide',
                'validation_errors': validation.get('errors', [])
            }), 400
        
        # Transformer en JSON via XSLT
        if os.path.exists(JSON_XSLT):
            result = transform_xml(xml_content, JSON_XSLT, environment)
            if result['success']:
                # Parser le JSON pour valider
                try:
                    json_data = json.loads(result['content'])
                    return jsonify({
                        'success': True,
                        'content': json.dumps(json_data, indent=2),
                        'data': json_data,
                        'message': 'Transformation réussie'
                    })
                except json.JSONDecodeError:
                    return jsonify({
                        'success': False,
                        'message': 'Erreur lors du parsing JSON généré'
                    }), 500
            return jsonify(result)
        else:
            # Fallback: utiliser l'endpoint export
            return export_config()
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Erreur serveur: {str(e)}'
        }), 500


@app.route('/api/environments', methods=['POST'])
def get_environments():
    """Récupère la liste des environnements depuis le XML"""
    try:
        data = request.get_json()
        xml_content = data.get('xml', '')
        
        if not xml_content:
            return jsonify({'environments': []}), 200
        
        # Parser le XML
        xml_doc = etree.parse(BytesIO(xml_content.encode('utf-8')))
        
        # Extraire les noms d'environnements
        environments = xml_doc.xpath('//environment/name/text()')
        
        return jsonify({'environments': environments})
    except Exception as e:
        return jsonify({
            'environments': [],
            'error': str(e)
        }), 500


@app.route('/api/compare', methods=['POST'])
def compare_environments():
    """Compare deux environnements"""
    try:
        data = request.get_json()
        xml_content = data.get('xml', '')
        env1 = data.get('environment1', '')
        env2 = data.get('environment2', '')
        
        if not xml_content or not env1 or not env2:
            return jsonify({
                'success': False,
                'message': 'Paramètres manquants'
            }), 400
        
        xml_doc = etree.parse(BytesIO(xml_content.encode('utf-8')))
        
        # Extraire les services de chaque environnement
        env1_services = xml_doc.xpath(f'//environment[name="{env1}"]/services/service/name/text()')
        env2_services = xml_doc.xpath(f'//environment[name="{env2}"]/services/service/name/text()')
        
        # Comparer
        only_in_env1 = set(env1_services) - set(env2_services)
        only_in_env2 = set(env2_services) - set(env1_services)
        common = set(env1_services) & set(env2_services)
        
        # Comparer les détails des services communs
        differences = []
        for service_name in common:
            env1_service = xml_doc.xpath(f'//environment[name="{env1}"]/services/service[name="{service_name}"]')[0]
            env2_service = xml_doc.xpath(f'//environment[name="{env2}"]/services/service[name="{service_name}"]')[0]
            
            env1_image = env1_service.xpath('image/text()')[0] if env1_service.xpath('image/text()') else ''
            env2_image = env2_service.xpath('image/text()')[0] if env2_service.xpath('image/text()') else ''
            
            if env1_image != env2_image:
                differences.append({
                    'service': service_name,
                    'field': 'image',
                    'env1_value': env1_image,
                    'env2_value': env2_image
                })
        
        return jsonify({
            'success': True,
            'comparison': {
                'only_in_env1': list(only_in_env1),
                'only_in_env2': list(only_in_env2),
                'common': list(common),
                'differences': differences
            }
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Erreur lors de la comparaison: {str(e)}'
        }), 500


@app.route('/api/export', methods=['POST'])
def export_config():
    """Exporte la configuration au format JSON"""
    try:
        data = request.get_json()
        xml_content = data.get('xml', '')
        
        if not xml_content:
            return jsonify({
                'success': False,
                'message': 'Aucun contenu XML fourni'
            }), 400
        
        xml_doc = etree.parse(BytesIO(xml_content.encode('utf-8')))
        
        # Convertir en structure JSON
        config = {
            'application': {
                'name': xml_doc.xpath('//application/name/text()')[0] if xml_doc.xpath('//application/name/text()') else '',
                'version': xml_doc.xpath('//application/version/text()')[0] if xml_doc.xpath('//application/version/text()') else '',
                'description': xml_doc.xpath('//application/description/text()')[0] if xml_doc.xpath('//application/description/text()') else ''
            },
            'environments': []
        }
        
        for env in xml_doc.xpath('//environment'):
            env_name = env.xpath('name/text()')[0]
            env_config = {
                'name': env_name,
                'services': [],
                'variables': []
            }
            
            for service in env.xpath('.//service'):
                service_config = {
                    'name': service.xpath('name/text()')[0] if service.xpath('name/text()') else '',
                    'image': service.xpath('image/text()')[0] if service.xpath('image/text()') else '',
                    'tag': service.xpath('tag/text()')[0] if service.xpath('tag/text()') else ''
                }
                env_config['services'].append(service_config)
            
            for var in env.xpath('.//variables/variable'):
                var_config = {
                    'name': var.xpath('name/text()')[0] if var.xpath('name/text()') else '',
                    'value': var.xpath('value/text()')[0] if var.xpath('value/text()') else ''
                }
                env_config['variables'].append(var_config)
            
            config['environments'].append(env_config)
        
        return jsonify({
            'success': True,
            'config': config
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Erreur lors de l\'export: {str(e)}'
        }), 500


@app.route('/api/download/<format_type>', methods=['POST'])
def download_file(format_type):
    """Télécharge le fichier généré"""
    try:
        data = request.get_json()
        content = data.get('content', '')
        environment = data.get('environment', 'dev')
        filename = data.get('filename', f'config-{environment}')
        
        if not content:
            return jsonify({'error': 'Aucun contenu fourni'}), 400
        
        # Créer un fichier temporaire
        suffix = '.yaml' if format_type in ['docker-compose', 'kubernetes', 'helm'] else '.txt'
        temp_file = tempfile.NamedTemporaryFile(mode='w', delete=False, suffix=suffix, encoding='utf-8')
        temp_file.write(content)
        temp_file.close()
        
        return send_file(
            temp_file.name,
            as_attachment=True,
            download_name=f'{filename}{suffix}',
            mimetype='text/yaml'
        )
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/health', methods=['GET'])
def health():
    """Endpoint de santé"""
    return jsonify({'status': 'ok', 'message': 'API fonctionnelle'})


if __name__ == '__main__':
    app.run(debug=True, port=5000)
