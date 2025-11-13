from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token
from models import get_user_by_username, add_user, user_exists
from datetime import timedelta

def authenticate_user(username, password):
    """验证用户身份"""
    user = get_user_by_username(username)
    
    if not user:
        # 用户不存在
        return {
            'success': False,
            'message': '用户不存在，请先注册'
        }
    
    if user and check_password_hash(user['password'], password):
        # 密码正确，生成token
        access_token = create_access_token(
            identity=username,
            expires_delta=timedelta(hours=24)
        )
        return {
            'success': True,
            'message': '登录成功',
            'token': access_token,
            'username': username
        }
    else:
        # 密码错误
        return {
            'success': False,
            'message': '密码错误'
        }

def register_user(username, password):
    """注册新用户"""
    if user_exists(username):
        return {
            'success': False,
            'message': '用户名已存在'
        }
    
    try:
        hashed_password = generate_password_hash(password)
        user_id = add_user(username, hashed_password)
        return {
            'success': True,
            'message': '用户注册成功',
            'user_id': user_id,
            'username': username
        }
    except Exception as e:
        return {
            'success': False,
            'message': f'注册失败: {str(e)}'
        }