from flask import Flask, request, jsonify, send_file
from flask_jwt_extended import JWTManager, jwt_required, get_jwt_identity
from models import init_db
from auth import authenticate_user, register_user
from swapper_images import init_swapper_table, add_swapper_image, get_all_swapper_images, delete_swapper_image, get_swapper_image_by_id
from cinemas import init_cinemas_table, add_cinema, get_all_cinemas, get_cinema_by_id, update_cinema, delete_cinema, search_cinemas
import os
import uuid
from werkzeug.utils import secure_filename

app = Flask(__name__)

# 配置
app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET', 'your-secret-key-change-this')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = 86400  # 24小时

# 图片上传配置
app.config['UPLOAD_FOLDER'] = 'uploads/swapper'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB 最大文件大小
app.config['ALLOWED_EXTENSIONS'] = {'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'}

# 确保上传目录存在
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# 初始化扩展
jwt = JWTManager(app)

# 初始化数据库
print("正在初始化数据库...")
init_db()
init_swapper_table()
init_cinemas_table()

def allowed_file(filename):
    """检查文件扩展名是否允许"""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in app.config['ALLOWED_EXTENSIONS']

@app.route('/')
def home():
    return jsonify({
        'message': '用户认证系统、Swapper图像管理和影院管理API',
        'endpoints': {
            '用户认证': {
                '/api/login': '用户登录',
                '/api/register': '用户注册',
                '/api/protected': '受保护的测试端点'
            },
            '图片管理': {
                '/api/swapper/images': '获取所有swapper图像',
                '/api/swapper/upload': '上传swapper图像',
                '/api/swapper/image/<int:image_id>': '获取或删除特定图像'
            },
            '影院管理': {
                '/api/cinemas': '获取所有影院/创建影院',
                '/api/cinemas/<int:cinema_id>': '获取/更新/删除特定影院',
                '/api/cinemas/search': '搜索影院'
            }
        }
    })

# 用户认证路由
@app.route('/api/login', methods=['POST'])
def login():
    """用户登录接口"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'message': '请求数据格式错误，请使用application/json'
            }), 400
        
        username = data.get('username')
        password = data.get('password')
        
        if not username or not password:
            return jsonify({
                'success': False,
                'message': '用户名和密码不能为空'
            }), 400
        
        # 认证用户
        result = authenticate_user(username, password)
        status_code = 200 if result['success'] else 401
        
        return jsonify(result), status_code
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'服务器错误: {str(e)}'
        }), 500

@app.route('/api/register', methods=['POST'])
def register():
    """用户注册接口"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'message': '请求数据格式错误，请使用application/json'
            }), 400
        
        username = data.get('username')
        password = data.get('password')
        
        if not username or not password:
            return jsonify({
                'success': False,
                'message': '用户名和密码不能为空'
            }), 400
        
        if len(username) < 3:
            return jsonify({
                'success': False,
                'message': '用户名至少需要3个字符'
            }), 400
        
        if len(password) < 6:
            return jsonify({
                'success': False,
                'message': '密码至少需要6个字符'
            }), 400
        
        # 注册用户
        result = register_user(username, password)
        status_code = 201 if result['success'] else 400
        
        return jsonify(result), status_code
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'服务器错误: {str(e)}'
        }), 500

@app.route('/api/protected', methods=['GET'])
@jwt_required()
def protected():
    """受保护的端点，用于测试token"""
    current_user = get_jwt_identity()
    return jsonify({
        'success': True,
        'message': f'你好, {current_user}! 这是一个受保护的端点。',
        'current_user': current_user
    })

# Swapper图像管理路由
@app.route('/api/swapper/images', methods=['GET'])
def get_swapper_images():
    """获取所有swapper图像"""
    try:
        images = get_all_swapper_images()
        
        # 构建完整的URL
        base_url = request.host_url.rstrip('/')
        for image in images:
            image['imageURL'] = f"{base_url}/api/swapper/image/{image['id']}"
        
        return jsonify({
            'success': True,
            'images': images,
            'count': len(images)
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'获取图像列表失败: {str(e)}'
        }), 500

@app.route('/api/swapper/upload', methods=['POST'])
@jwt_required()
def upload_swapper_image():
    """上传swapper图像"""
    try:
        # 检查是否有文件部分
        if 'image' not in request.files:
            return jsonify({
                'success': False,
                'message': '没有上传文件'
            }), 400
        
        file = request.files['image']
        
        # 如果用户没有选择文件
        if file.filename == '':
            return jsonify({
                'success': False,
                'message': '没有选择文件'
            }), 400
        
        # 检查文件类型
        if file and allowed_file(file.filename):
            # 生成安全的文件名
            filename = secure_filename(file.filename)
            # 添加UUID防止重名
            unique_filename = f"{uuid.uuid4().hex}_{filename}"
            
            # 保存文件
            file_path = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
            file.save(file_path)
            
            # 添加到数据库
            image_id = add_swapper_image(file_path)
            
            # 构建完整的访问URL
            base_url = request.host_url.rstrip('/')
            image_url = f"{base_url}/api/swapper/image/{image_id}"
            
            return jsonify({
                'success': True,
                'message': '图像上传成功',
                'image_id': image_id,
                'imageURL': image_url
            }), 201
        else:
            return jsonify({
                'success': False,
                'message': '不支持的文件类型。支持的格式: png, jpg, jpeg, gif, bmp, webp'
            }), 400
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'上传失败: {str(e)}'
        }), 500

@app.route('/api/swapper/image/<int:image_id>', methods=['GET', 'DELETE'])
def swapper_image(image_id):
    """获取或删除特定swapper图像"""
    try:
        if request.method == 'GET':
            # 获取图像信息
            image_info = get_swapper_image_by_id(image_id)
            
            if not image_info:
                return jsonify({
                    'success': False,
                    'message': '图像不存在'
                }), 404
            
            # 返回图像文件
            return send_file(image_info['imageURL'])
            
        elif request.method == 'DELETE':
            # 删除图像
            current_user = get_jwt_identity()  # 验证JWT token
            
            success = delete_swapper_image(image_id)
            
            if success:
                return jsonify({
                    'success': True,
                    'message': '图像删除成功'
                })
            else:
                return jsonify({
                    'success': False,
                    'message': '图像不存在'
                }), 404
                
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'操作失败: {str(e)}'
        }), 500

# 影院管理路由
@app.route('/api/cinemas', methods=['GET', 'POST'])
@jwt_required()
def cinemas():
    """获取所有影院或创建新影院"""
    try:
        if request.method == 'GET':
            # 获取所有影院
            cinemas_list = get_all_cinemas()
            
            return jsonify({
                'success': True,
                'cinemas': cinemas_list,
                'count': len(cinemas_list)
            })
            
        elif request.method == 'POST':
            # 创建新影院
            data = request.get_json()
            
            if not data:
                return jsonify({
                    'success': False,
                    'message': '请求数据格式错误，请使用application/json'
                }), 400
            
            name = data.get('name')
            address = data.get('address')
            price = data.get('price')
            tags = data.get('tags', [])
            
            # 验证必填字段
            if not name or not address or price is None:
                return jsonify({
                    'success': False,
                    'message': '影院名称、地址和票价不能为空'
                }), 400
            
            # 验证票价是否为数字
            try:
                price = float(price)
                if price < 0:
                    raise ValueError("票价不能为负数")
            except (ValueError, TypeError):
                return jsonify({
                    'success': False,
                    'message': '票价必须是有效的数字'
                }), 400
            
            # 验证标签是否为列表
            if not isinstance(tags, list):
                return jsonify({
                    'success': False,
                    'message': '标签必须是数组格式'
                }), 400
            
            # 添加影院
            cinema_id = add_cinema(name, address, price, tags)
            
            return jsonify({
                'success': True,
                'message': '影院创建成功',
                'cinema_id': cinema_id
            }), 200
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'操作失败: {str(e)}'
        }), 500

@app.route('/api/cinemas/<int:cinema_id>', methods=['GET', 'PUT', 'DELETE'])
@jwt_required()
def cinema_detail(cinema_id):
    """获取、更新或删除特定影院"""
    try:
        if request.method == 'GET':
            # 获取影院详情
            cinema = get_cinema_by_id(cinema_id)
            
            if not cinema:
                return jsonify({
                    'success': False,
                    'message': '影院不存在'
                }), 404
            
            return jsonify({
                'success': True,
                'cinema': cinema
            })
            
        elif request.method == 'PUT':
            # 更新影院信息
            data = request.get_json()
            
            if not data:
                return jsonify({
                    'success': False,
                    'message': '请求数据格式错误，请使用application/json'
                }), 400
            
            # 检查影院是否存在
            existing_cinema = get_cinema_by_id(cinema_id)
            if not existing_cinema:
                return jsonify({
                    'success': False,
                    'message': '影院不存在'
                }), 404
            
            # 提取可更新字段
            name = data.get('name')
            address = data.get('address')
            price = data.get('price')
            tags = data.get('tags')
            
            # 验证票价
            if price is not None:
                try:
                    price = float(price)
                    if price < 0:
                        raise ValueError("票价不能为负数")
                except (ValueError, TypeError):
                    return jsonify({
                        'success': False,
                        'message': '票价必须是有效的数字'
                    }), 400
            
            # 更新影院
            success = update_cinema(cinema_id, name, address, price, tags)
            
            if success:
                return jsonify({
                    'success': True,
                    'message': '影院更新成功'
                })
            else:
                return jsonify({
                    'success': False,
                    'message': '影院更新失败'
                }), 400
                
        elif request.method == 'DELETE':
            # 删除影院
            success = delete_cinema(cinema_id)
            
            if success:
                return jsonify({
                    'success': True,
                    'message': '影院删除成功'
                })
            else:
                return jsonify({
                    'success': False,
                    'message': '影院不存在'
                }), 404
                
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'操作失败: {str(e)}'
        }), 500

@app.route('/api/cinemas/search', methods=['GET'])
def search_cinemas_route():
    """搜索影院"""
    try:
        # 获取查询参数
        keyword = request.args.get('keyword')
        min_price = request.args.get('min_price', type=float)
        max_price = request.args.get('max_price', type=float)
        tag = request.args.get('tag')
        
        # 搜索影院
        cinemas_list = search_cinemas(keyword, min_price, max_price, tag)
        
        return jsonify({
            'success': True,
            'cinemas': cinemas_list,
            'count': len(cinemas_list),
            'search_params': {
                'keyword': keyword,
                'min_price': min_price,
                'max_price': max_price,
                'tag': tag
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'搜索失败: {str(e)}'
        }), 500

# 调试端点
@app.route('/api/debug/tables', methods=['GET'])
def debug_tables():
    """调试端点：检查数据库表状态"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # 获取所有表
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = cursor.fetchall()
        
        table_list = []
        for table in tables:
            table_name = table['name']
            # 获取每个表的行数
            cursor.execute(f"SELECT COUNT(*) as count FROM {table_name}")
            count = cursor.fetchone()['count']
            table_list.append({
                'name': table_name,
                'row_count': count
            })
        
        conn.close()
        
        return jsonify({
            'success': True,
            'tables': table_list
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'检查表状态失败: {str(e)}'
        }), 500

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'success': False,
        'message': '端点不存在'
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        'success': False,
        'message': '服务器内部错误'
    }), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)